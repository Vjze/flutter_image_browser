use futures_lite::StreamExt as _;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::{env, fs::File, io::Write, path::Path, process::Command, time::Instant};

use crate::frb_generated::StreamSink;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct UpdateInfo {
    pub version: String,
    pub changelog: String,
    pub download_url: String,
    pub file_name: String,
    pub date: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct UpdateInfos {
    pub version: String,
    pub changelog: String,
    pub plattform: Platform,
    pub file_name: String,
    pub date: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Platform {
    pub windows: String,
    pub macos: String,
    pub linux: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DownloadProgress {
    pub downloaded_bytes: u64,
    pub total_bytes: u64,
    pub speed: f64,
    pub progress: f64,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "type", content = "data")]
pub enum DownloadEvent {
    Progress(DownloadProgress),
    Error(String),
}

// 获取更新信息
pub async fn check_update() -> anyhow::Result<Option<UpdateInfo>> {
    let url = "http://tingan.sbs/latest.json"; // 你的版本信息地址
    let response = reqwest::get(url).await?.text().await?;
    let update_info: UpdateInfos = serde_json::from_str(&response)?;
    let current_version = env!("CARGO_PKG_VERSION");

    if update_info.version != current_version {
        // 根据平台选下载链接
        #[cfg(target_os = "windows")]
        let download_url = update_info.plattform.windows.clone();

        #[cfg(target_os = "macos")]
        let download_url = update_info.plattform.macos.clone();

        #[cfg(target_os = "linux")]
        let download_url = update_info.plattform.linux.clone();
        let updateinfo = UpdateInfo {
            version: update_info.version.clone(),
            changelog: update_info.changelog.clone(),
            download_url,
            file_name: update_info.file_name.clone(),
            date: update_info.date.clone(),
        };
        Ok(Some(updateinfo))
    } else {
        Ok(None)
    }
}

// 下载更新文件（带进度回传）
pub async fn download_update(
    url: String,
    dest_path: String,
    progress_sink: StreamSink<DownloadEvent>,
) -> anyhow::Result<()> {
    let client = reqwest::Client::new();
    let response = match client.get(&url).send().await {
        Ok(r) => r,
        Err(e) => {
            let _ = progress_sink.add(DownloadEvent::Error(format!("网络请求失败: {e}")));
            return Err(e.into());
        }
    };

    let total_size = response.content_length().unwrap_or(0);
    let path = std::path::Path::new(&dest_path);

    let mut file = match std::fs::File::create(&path) {
        Ok(f) => f,
        Err(e) => {
            let _ = progress_sink.add(DownloadEvent::Error(format!("文件创建失败: {e}")));
            return Err(e.into());
        }
    };

    let mut downloaded: u64 = 0;
    let mut stream = response.bytes_stream();
    let start = std::time::Instant::now();

    while let Some(chunk) = stream.next().await {
        let chunk = match chunk {
            Ok(c) => c,
            Err(e) => {
                let _ = progress_sink.add(DownloadEvent::Error(format!("网络读取失败: {e}")));
                return Err(e.into());
            }
        };

        if let Err(e) = file.write_all(&chunk) {
            let _ = progress_sink.add(DownloadEvent::Error(format!("文件写入失败: {e}")));
            return Err(e.into());
        }

        downloaded += chunk.len() as u64;
        let elapsed = start.elapsed().as_secs_f64();
        let speed = if elapsed > 0.0 {
            (downloaded as f64 / 1024.0) / elapsed
        } else {
            0.0
        };
        let progress = if total_size > 0 {
            downloaded as f64 / total_size as f64
        } else {
            0.0
        };

        let _ = progress_sink.add(DownloadEvent::Progress(DownloadProgress {
            downloaded_bytes: downloaded,
            total_bytes: total_size,
            speed,
            progress,
        }));
    }

    Ok(())
}

// 安装更新（执行安装包）
pub fn install_update(file_path: String) -> anyhow::Result<()> {
    #[cfg(target_os = "windows")]
    Command::new("cmd").arg("/c").arg(file_path).spawn()?;

    #[cfg(target_os = "macos")]
    Command::new("open").arg(file_path).spawn()?;

    #[cfg(target_os = "linux")]
    Command::new("sh").arg(file_path).spawn()?;

    Ok(())
}
