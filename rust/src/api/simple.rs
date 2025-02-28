use flutter_rust_bridge::frb;
use image::ImageReader;
use std::io::Cursor;
use std::path::Path;
use tokio::sync::Semaphore;
use std::sync::{Arc, Mutex};
use anyhow;

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

// 添加一个全局进度跟踪器
lazy_static::lazy_static! {
    static ref SCAN_PROGRESS: Arc<Mutex<(usize, usize)>> = Arc::new(Mutex::new((0, 0))); // (scanned, total)
}

#[frb]
pub async fn list_images(p: String) -> anyhow::Result<Vec<ImageInfo>> {
    let mut tasks = Vec::new();
    let semaphore = Arc::new(Semaphore::new(32)); // 限制并发

    // 计算总文件数
    let image_files: Vec<_> = walkdir::WalkDir::new(&p)
        .into_iter()
        .filter_map(Result::ok)
        .filter(|e| is_image_file(e.file_name().to_str().unwrap_or("").to_string()))
        .collect();
    let total_files = image_files.len();

    // 初始化进度
    {
        let mut progress = SCAN_PROGRESS.lock().unwrap();
        *progress = (0, total_files);
    }

    for entry in image_files {
        let file_path = entry.path().display().to_string();
        let _permit = semaphore.clone().acquire_owned().await?;
        let progress = SCAN_PROGRESS.clone();
        tasks.push(tokio::spawn(async move {
            let result = get_image_info(file_path).await;
            {
                let mut progress = progress.lock().unwrap();
                progress.0 += 1; // 更新已扫描文件数
            }
            result
        }));
    }

    let mut list = Vec::new();
    for task in tasks {
        if let Some(info) = task.await.unwrap() {
            list.push(info);
        }
    }

    // 扫描完成后重置进度
    {
        let mut progress = SCAN_PROGRESS.lock().unwrap();
        *progress = (0, 0);
    }
    Ok(list)
}

#[frb(sync)]
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