use async_walkdir::WalkDir;
use flutter_rust_bridge::frb;
use image::ImageReader;
use std::{io::Cursor, sync::Mutex};
use std::path::Path;
use tokio::sync::{mpsc, Semaphore};
use std::sync::{Arc, atomic::{AtomicBool, Ordering}};
use anyhow;
use futures_lite::stream::StreamExt;
use crate::frb_generated::StreamSink;

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Debug, Clone)]
pub struct ImageInfo {
    pub path: String,
    pub name: String,
    pub width: u32,
    pub height: u32,
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
    if let Some(file_name) = Path::new(&path).file_name() {
        if let Some(name) = file_name.to_str() {
            let data = tokio::fs::read(&path).await.ok()?;
            let img = ImageReader::new(Cursor::new(data))
                .with_guessed_format()
                .ok()?
                .decode()
                .ok()?;
            return Some(ImageInfo {
                path: path.clone(),
                name: name.to_string(),
                width: img.width(),
                height: img.height(),
            });
        }
    }
    None
}
// 扫描阶段：收集图片路径并返回总数
pub async fn scan_images(p: String) -> anyhow::Result<Vec<String>> {
    let mut entries = WalkDir::new(p);
    let mut paths = vec![];
    loop {
        match entries.next().await {
            Some(Ok(entry)) => {
                let path = entry.path().display().to_string();
                let mut v = |p: String|{
                    if is_image_file(p.clone()) {
                        paths.push(p);
                    }
                };
                v(path.clone())
            },
            Some(Err(e)) => {
                eprintln!("error: {}", e);
                break;
            }
            None => break,
        }
    }
    Ok(paths)
}
// 添加停止跟踪器和进度跟踪器
lazy_static::lazy_static! {
    static ref SHOULD_STOP: Arc<AtomicBool> = Arc::new(AtomicBool::new(false));
    static ref SCAN_PROGRESS: Arc<Mutex<(usize, usize)>> = Arc::new(Mutex::new((0, 0))); // (processed, total)
}

pub async fn list_images(paths: Vec<String>, sink: StreamSink<ImageInfo>) -> anyhow::Result<()> {
    // 使用逻辑线程数设置并发
    let concurrency = num_cpus::get(); // 获取 CPU 逻辑线程数
    let semaphore = Arc::new(Semaphore::new(concurrency));
    let (tx, mut rx) = mpsc::channel::<String>(100); // 任务队列

    // 初始化进度
    {
        let mut progress = SCAN_PROGRESS.lock().unwrap();
        *progress = (0, paths.len());
    }
    SHOULD_STOP.store(false, Ordering::SeqCst);
    // 将路径发送到任务队列
    tokio::spawn(async move {
        for file_path in paths {
            if SHOULD_STOP.load(Ordering::SeqCst) {
                println!("停止信号触发，退出文件分发");
                break;
            }
            if tx.send(file_path).await.is_err() {
                break; // 如果接收端关闭，退出
            }
        }
    });

    // 处理任务
    while let Some(file_path) = rx.recv().await {
        if SHOULD_STOP.load(Ordering::SeqCst) {
            println!("停止信号触发，退出任务处理");
            break; // 停止信号后退出
        }

        let permit = semaphore.clone().acquire_owned().await?;
        let sink = sink.clone();

        tokio::spawn(async move {
            if let Some(info) = get_image_info(file_path).await {
                let _ = sink.add(info);
                // 更新进度
                let mut progress = SCAN_PROGRESS.lock().unwrap();
                progress.0 += 1;
            }
            drop(permit); // 释放信号量
        });
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
        ".png", ".jpeg", ".webp", ".pnm", ".ico", ".avif", ".jpg", ".gif",
        ".JPG", ".GIF", ".PNG", ".JPEG", ".WEBP", ".PNM", ".ICO", ".AVIF",
    ];
    images_exts.iter().any(|ext| f.ends_with(ext))
}