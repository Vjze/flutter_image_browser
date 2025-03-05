use crate::frb_generated::StreamSink;
use anyhow;
use async_walkdir::WalkDir;
use flutter_rust_bridge::frb;
use std::{
    path::Path,
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc, Mutex,
    },
};
use tokio::sync::{OnceCell, Semaphore};
use tokio_stream::StreamExt;

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

async fn get_scan_state() -> &'static ScanState {
    SCAN_STATE
        .get_or_init(|| async move {
            ScanState {
                should_stop: Arc::new(AtomicBool::new(false)),
                progress: Arc::new(Mutex::new((0, 0))),
            }
        })
        .await
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[frb(sync)]
pub fn get_path() -> anyhow::Result<String> {
    let path = rfd::FileDialog::new().set_title("选择文件夹").pick_folder();
    match path {
        Some(p) => Ok(p.as_path().display().to_string()),
        None => Err(anyhow::anyhow!("未选择文件夹")),
    }
}

async fn get_image_info(path: String) -> Option<ImageInfo> {
    if let Some(file_name) = Path::new(&path.clone()).file_name() {
        if let Some(name) = file_name.to_str() {
            match imagesize::size(path.clone()) {
                Ok(size) => {
                    let width = size.width;
                    let height = size.height;
                    Some(ImageInfo {
                        path,
                        name: name.to_string(),
                        width,
                        height,
                    })
                }

                Err(_) => None,
            }
        } else {
            None
        }
    } else {
        None
    }
}

// 扫描阶段：异步收集图片路径并返回总数
pub async fn scan_images(p: String) -> anyhow::Result<u32> {
    let mut entries = WalkDir::new(p);
    let mut count = 0;
    while let Some(entry) = entries.next().await {
        match entry {
            Ok(entry) => {
                let path = entry.path().display().to_string();
                if is_image_file(&path) {
                    count += 1;
                }
            }
            Err(e) => {
                eprintln!("扫描错误: {}", e);
                break;
            }
        }
    }
    Ok(count)
}

// 读取阶段：加载图片并流式返回
pub async fn list_images(p: String, l: u32, sink: StreamSink<ImageInfo>) -> anyhow::Result<()> {
    let state = get_scan_state().await;
    let concurrency = num_cpus::get();
    let semaphore = Arc::new(Semaphore::new(concurrency));
    let total = l as usize;

    // 初始化进度
    state.should_stop.store(false, Ordering::SeqCst);
    {
        let mut progress = state.progress.lock().unwrap();
        *progress = (0, total);
    }

    let mut entries = WalkDir::new(p);
    let mut tasks = Vec::new();

    while let Some(entry) = entries.next().await {
        if state.should_stop.load(Ordering::SeqCst) {
            break;
        }

        match entry {
            Ok(entry) => {
                let path = entry.path().display().to_string();
                if is_image_file(&path) {
                    let permit = semaphore.clone().acquire_owned().await?;
                    let sink = sink.clone();

                    let task = tokio::spawn(async move {
                        if let Some(info) = get_image_info(path).await {
                            let _ = sink.add(info);
                        }
                        drop(permit);
                    });
                    tasks.push(task);
                }
            }
            Err(e) => {
                eprintln!("扫描错误: {}", e);
                break;
            }
        }
    }

    // 等待所有任务完成并更新进度
    let mut processed = 0;
    for task in tasks {
        task.await?;
        processed += 1;
        let mut progress = state.progress.lock().unwrap();
        progress.0 = processed;
    }

    // 重置进度
    {
        let mut progress = state.progress.lock().unwrap();
        *progress = (processed, total);
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
        "tiff", "tif", // 高效率图像格式 (HEIF/HEIC)
        "heif", "heic", // RAW 格式（常见相机原始文件）
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
