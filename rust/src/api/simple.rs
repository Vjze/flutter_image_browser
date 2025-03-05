use crate::frb_generated::StreamSink;
use anyhow;
use async_walkdir::WalkDir;
use flutter_rust_bridge::frb;
use futures_lite::stream::StreamExt;
use std::{
    path::Path,
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc, Mutex,
    },
};
use tokio::sync::Semaphore;

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Debug, Clone)]
pub struct ImageInfo {
    pub path: String,
    pub name: String,
    pub width: usize,
    pub height: usize,
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
                },
                
                Err(_) => None,
            }
        } else {
            None
        }
    } else {
        None
    }
}

lazy_static::lazy_static! {
    static ref SHOULD_STOP: Arc<AtomicBool> = Arc::new(AtomicBool::new(false));
    static ref SCAN_PROGRESS: Arc<Mutex<(usize, usize)>> = Arc::new(Mutex::new((0, 0))); // (processed, total)
}

// 扫描阶段：异步收集图片路径并返回总数

pub async fn scan_images(p: String) -> anyhow::Result<u32> {
    let mut entries = WalkDir::new(p);
    let mut count = 0;
    while let Some(entry) = entries.next().await {
        match entry {
            Ok(entry) => {
                let path = entry.path().display().to_string();
                if is_image_file(path) {
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
    let concurrency = num_cpus::get();
    let semaphore = Arc::new(Semaphore::new(concurrency));
    let total = l as usize;

    // 初始化进度
    {
        let mut progress = SCAN_PROGRESS.lock().unwrap();
        *progress = (0, total);
    }
    SHOULD_STOP.store(false, Ordering::SeqCst);

    let mut entries = WalkDir::new(p);
    let mut tasks = Vec::new();

    while let Some(entry) = entries.next().await {
        if SHOULD_STOP.load(Ordering::SeqCst) {
            break;
        }

        match entry {
            Ok(entry) => {
                let path = entry.path().display().to_string();
                if is_image_file(path.clone()) {
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
        let mut progress = SCAN_PROGRESS.lock().unwrap();
        progress.0 = processed;
    }

    // 重置进度
    {
        let mut progress = SCAN_PROGRESS.lock().unwrap();
        *progress = (0, 0);
    }
    Ok(())
}

#[frb(sync)]
pub fn stop_scan() {
    SHOULD_STOP.store(true, Ordering::SeqCst);
}

pub fn get_scan_progress() -> f32 {
    let progress = SCAN_PROGRESS.lock().unwrap();
    if progress.1 == 0 {
        0.0
    } else {
        (progress.0 as f32 / progress.1 as f32) * 100.0
    }
}

fn is_image_file(f: String) -> bool {
    let images_exts: Vec<&str> = vec![
        ".png", ".jpeg", ".webp", ".pnm", ".ico", ".avif", ".jpg", ".gif", ".JPG", ".GIF", ".PNG",
        ".JPEG", ".WEBP", ".PNM", ".ICO", ".AVIF",
    ];
    images_exts.iter().any(|ext| f.ends_with(ext))
}
