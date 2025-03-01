use futures_lite::StreamExt as _;
use serde::{Deserialize, Serialize};
use tokio::{fs::File, io::AsyncWriteExt as _};
use std::process::Command;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct UpdateInfo {
    pub version: String,
    pub changelog: String,
    pub download_url: String,
}

pub async fn check_update(current_version: &str) -> Option<UpdateInfo> {
    let url = "http://tingan.sbs/update.json"; // 替换成你的服务器地址
    let response = reqwest::get(url).await.ok()?.text().await.ok()?;
    let update_info: UpdateInfo = serde_json::from_str(&response).ok()?;
    if *update_info.version > *current_version {
        Some(update_info)
    } else {
        None
    }
}

pub async fn download_and_install(update_info: &UpdateInfo) -> bool {
    let download_url = &update_info.download_url;
    let file_name = if cfg!(target_os = "windows") {
        "update_installer.exe"
    } else if cfg!(target_os = "macos") {
        "update_installer.dmg"
    } else {
        "update_installer.tar.gz"
    };

    let response = reqwest::get(download_url).await.ok().unwrap();
    let mut file = File::create(file_name).await.ok().unwrap();
    let mut stream = response.bytes_stream();
    while let Some(chunk) = stream.next().await {
        let chunk = chunk.unwrap();
        file.write_all(&chunk).await.unwrap();
        // downloaded += chunk.len() as f32;
        // let progress = (downloaded / total_size) * 100.0;
        // progress_sink.add(progress);
        // println!("下载进度: {:.1}%", progress);
    };

    // 自动启动安装
    if cfg!(target_os = "windows") {
        Command::new(file_name).spawn().ok().unwrap();
    } else if cfg!(target_os = "macos") {
        Command::new("open").arg(file_name).spawn().ok().unwrap();
    } else {
        Command::new("tar").arg("-xzf").arg(file_name).spawn().ok().unwrap();
        Command::new("./install.sh").spawn().ok().unwrap();
    }

    true
}
