use flutter_rust_bridge::frb;
use image::{self, GenericImageView, ImageReader};
use tokio::sync::Semaphore;
use std::{io::Cursor, path::Path, sync::Arc, vec};

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
#[derive(Debug)]
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
pub async fn get_image_info(path: String) -> Option<ImageInfo> {
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
        };
    }
    None
}
pub async fn list_images(p: String) -> anyhow::Result<Vec<ImageInfo>> {
    let mut tasks = vec![];
     // 并行扫描
     let semaphore = Arc::new(Semaphore::new(16)); // 限制并发
    for path in walkdir::WalkDir::new(p)
        .into_iter()
        .filter_map(Result::ok)
        .filter(|e| is_image_file(e.file_name().to_str().unwrap().to_string()))
    {
        let _permit = semaphore.clone().acquire_owned().await?;
        let file_path = path.path().display().to_string();
        tasks.push(tokio::spawn(async move { get_image_info(file_path).await }));
    }
    let mut list = vec![];
    for task in tasks {
        if let Some(info) = task.await.unwrap() {
            list.push(info);
        }
    }
    Ok(list)
}

fn is_image_file(f: String) -> bool {
    let images_exts: Vec<&str> = vec![
        ".png", ".jpeg", ".webp", ".pnm", ".ico", ".avif", ".jpg", ".gif", ".JPG", ".GIF", ".PNG",
        ".JPRG", ".WEBP", ".PNM", ".ICO", ".AVIF",
    ];
    for x in &images_exts {
        if f.ends_with(x) {
            return true;
        }
    }
    return false;
}
