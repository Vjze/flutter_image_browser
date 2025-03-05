use super::error::ImageScanError;
use crate::frb_generated::StreamSink;
use anyhow;
use async_walkdir::WalkDir;
use flutter_rust_bridge::frb;
use futures_lite::stream::StreamExt;
use imagesize::size;
use std::{
    path::Path,
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc, Mutex,
    },
    time::Duration,
};
use tokio::{
    sync::{OnceCell, Semaphore},
    time::interval,
};

#[derive(Debug, Clone)]
pub struct ImageInfo {
    pub path: String,
    pub name: String,
    pub width: usize,
    pub height: usize,
}
struct ScanState {
    should_stop: Arc<AtomicBool>,
    progress: Arc<Mutex<(usize, usize)>>, // (processed, total)
}

static SCAN_STATE: OnceCell<ScanState> = OnceCell::const_new();

#[frb(sync)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

async fn get_scan_state() -> &'static ScanState {
    SCAN_STATE
        .get_or_init(async move || ScanState {
            should_stop: Arc::new(AtomicBool::new(false)),
            progress: Arc::new(Mutex::new((0, 0))),
        })
        .await
}

#[frb(sync)]
pub fn get_path() -> anyhow::Result<String, ImageScanError> {
    let path = rfd::FileDialog::new().set_title("选择文件夹").pick_folder();
    path.map(|p| p.as_path().display().to_string())
        .ok_or(ImageScanError::NoFolderSelected)
}

async fn get_image_info(path: String) -> Result<ImageInfo, ImageScanError> {
    if let Some(file_name) = Path::new(&path.clone()).file_name() {
        if let Some(name) = file_name.to_str() {
            let size = size(&path).map_err(ImageScanError::ImageError)?;
            println!("Parsed image {}: {}x{}", path, size.width, size.height);
            Ok(ImageInfo {
                path,
                name: name.to_string(),
                width: size.width,
                height: size.height,
            })
        } else {
            println!("Invalid file name for: {}", path);
            Err(ImageScanError::FileError)
        }
    } else {
        println!("Invalid path: {}", path);
        Err(ImageScanError::FileError)
    }
}

pub async fn scan_images(p: String) -> Result<u32, ImageScanError> {
    let mut entries = WalkDir::new(&p);
    let mut count = 0;
    while let Some(entry) = entries.next().await {
        let entry = entry.map_err(|_| ImageScanError::FolderError)?;
        let path = entry.path().display().to_string();
        if is_image_file(&path) {
            count += 1;
        }
    }
    println!("Scanned {} images in {}", count, p);
    Ok(count)
}

// 扫描阶段：异步收集图片路径并返回总数
pub async fn list_images(
    p: String,
    l: u32,
    sink: StreamSink<ImageInfo>,
) -> Result<(), ImageScanError> {
    let state = get_scan_state().await;
    let concurrency = num_cpus::get();
    let semaphore = Arc::new(Semaphore::new(concurrency));
    let mut entries = WalkDir::new(&p);
    let total = l as usize;
    let mut tasks = Vec::new();

    state.should_stop.store(false, Ordering::SeqCst);
    {
        let mut progress = state.progress.lock().unwrap();
        *progress = (0, total);
    }

    let mut batch = Vec::new();
    while let Some(entry) = entries.next().await {
        if state.should_stop.load(Ordering::SeqCst) {
            break;
        }
        let entry = entry.map_err(|_| ImageScanError::FolderError)?;
        let path = entry.path().display().to_string();
        if is_image_file(&path) {
            batch.push(path);
            if batch.len() >= 100 {
                spawn_batch(&batch, &semaphore, &sink, &mut tasks).await?;
                batch.clear();
            }
        }
    }
    if !batch.is_empty() {
        spawn_batch(&batch, &semaphore, &sink, &mut tasks).await?;
    }

    let mut processed = 0;
    let mut interval = interval(Duration::from_millis(100)); // 与 Flutter 的 100ms 同步
    for task in tasks {
        task.await.map_err(ImageScanError::TaskError)?;
        processed += 1;
        interval.tick().await; // 等待下一次滴答
        let mut progress = state.progress.lock().unwrap();
        progress.0 = processed;
    }

    let mut progress = state.progress.lock().unwrap();
    *progress = (processed, total);
    println!("Loaded {} out of {} images", processed, total);
    Ok(())
}

async fn spawn_batch(
    batch: &[String],
    semaphore: &Arc<Semaphore>,
    sink: &StreamSink<ImageInfo>,
    tasks: &mut Vec<tokio::task::JoinHandle<Result<(), ImageScanError>>>,
) -> Result<(), ImageScanError> {
    for path in batch {
        let _permit = semaphore
            .clone()
            .acquire_owned()
            .await
            .map_err(|_| ImageScanError::FileError)?;
        let sink = sink.clone();
        let path = path.clone();
        let task = tokio::spawn(async move {
            match get_image_info(path).await {
                Ok(info) => {
                    let _ = sink.add(info);
                    Ok(())
                }
                Err(e) => Err(e),
            }
        });
        tasks.push(task);
    }
    Ok(())
}

#[frb(sync)]
pub fn stop_scan() {
    if let Some(state) = SCAN_STATE.get() {
        state.should_stop.store(true, Ordering::SeqCst);
    }
}

pub fn get_scan_progress() -> f32 {
    if let Some(state) = SCAN_STATE.get() {
        let progress = state.progress.lock().unwrap();
        if progress.1 == 0 {
            0.0
        } else {
            (progress.0 as f32 / progress.1 as f32) * 100.0
        }
    } else {
        0.0
    }
}

fn is_image_file(f: &str) -> bool {
    // 定义一个更全面的图片扩展名列表（小写）
    let image_exts: &[&str] = &[
        // 常见位图格式
        "png", "jpg", "jpeg", "gif", "bmp", "webp", "ico", "pnm", "avif",
        // TIFF 和相关格式
        "tiff", "tif",
        // 高效率图像格式 (HEIF/HEIC)
        "heif", "heic",
        // RAW 格式（常见相机原始文件）
        "cr2", "nef", "arw", "dng", "raf", "orf",
        // 其他较少见但仍使用的格式
        "tga", "pcx", "psd", "exr", "hdr", "jxl", // JXL 是 JPEG XL
        // 矢量格式（视需求可选）
        "svg",
    ];

    // 转换为小写并检查扩展名
    f.to_lowercase()
        .split('.')
        .last()
        .map(|ext| image_exts.contains(&ext))
        .unwrap_or(false)
}