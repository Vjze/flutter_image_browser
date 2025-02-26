use flutter_rust_bridge::frb;
use image::{self, GenericImageView};
use std::{path::Path, vec};

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
// pub async fn get_data(p: String) -> Option<ImageInfo> {
//     match Path::new(&p).file_name(){
//         Some(file_name) => {
//             let name = file_name.to_str().unwrap().to_string();
//             let (width, height) = image::open(p.clone()).unwrap().dimensions();
//             let info = ImageInfo {
//                 name,
//                 width,
//                 height,
//             };
//             Some(info)
//         },
//         None => return None,
//     }

// }

pub async fn get_image_info(path: String) -> Option<ImageInfo> {
    if let Some(file_name) = Path::new(&path).file_name() {
        if let Some(name) = file_name.to_str() {
            let (width, height) = image::open(path.clone()).unwrap().dimensions();
            let info = ImageInfo {
                path: path.clone(),
                name: name.to_string(),
                width,
                height,
            };
            return Some(info);
        };
    }
    None
}
pub async fn list_images(p: String) -> anyhow::Result<Vec<ImageInfo>> {
    let mut tasks = vec![];
    for path in walkdir::WalkDir::new(p)
        .into_iter()
        .filter_map(Result::ok)
        .filter(|e| is_image_file(e.file_name().to_str().unwrap().to_string()))
    {
        // let file_name = path.file_name().to_str().unwrap().to_string();
        let file_path = path.path().display().to_string();
        tasks.push(tokio::spawn(async move { get_image_info(file_path).await }));
        // list.push(file_path);
    }
    let mut list = vec![];
    for task in tasks {
        if let Some(info) = task.await.unwrap() {
            list.push(info);
        }
    }
    Ok(list)
}
// pub async fn list_images(p: String) -> anyhow::Result<Vec<String>> {
//     let mut list = vec![];
//     for path in walkdir::WalkDir::new(p)
//         .into_iter()
//         .filter_map(Result::ok)
//         .filter(|e| is_image_file(e.file_name().to_str().unwrap().to_string()))
//     {
//         // let file_name = path.file_name().to_str().unwrap().to_string();
//         let file_path = path.path().display().to_string();

//         list.push(file_path);
//     }
//     Ok(list)
// }
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
