use crate::frb_generated::StreamSink;
use futures_lite::StreamExt as _;
use serde::{Deserialize, Serialize};
use std::ascii::AsciiExt;
use std::fs;
use std::path::Path;
use std::process::{self, Command, Stdio};
use std::thread::sleep;
use std::time::Duration;
use tokio::{fs::File, io::AsyncWriteExt as _};

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
        let file_name = download_url.split("/").last().unwrap().to_string();
        let updateinfo = UpdateInfo {
            version: update_info.version.clone(),
            changelog: update_info.changelog.clone(),
            download_url,
            file_name,
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

    let mut file = match File::create(&path).await {
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

        if let Err(e) = file.write_all(&chunk).await {
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
pub fn close_old_app() -> anyhow::Result<()> {
    #[cfg(target_os = "windows")]
    {
        let mut cmd = Command::new("taskkill");
        cmd.arg("/F").arg("/IM").arg("my_app.exe").spawn()?.wait()?;
    }
    #[cfg(target_os = "macos")]
    {
        let app_name = "my_app"; // 你的App名字
        let script = format!(r#"tell application "{}" to quit"#, app_name);

        Command::new("osascript")
            .arg("-e")
            .arg(script)
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
            .expect("Failed to close old app");
    }
    #[cfg(target_os = "linux")]
    {
        let mut cmd = Command::new("killall");
        cmd.arg("my_app").spawn()?.wait()?;
    }
    Ok(())
}

pub fn replace_appimage(new_appimage_path: &str) -> anyhow::Result<()> {
    #[cfg(target_os = "linux")]
    {
        let target_path = shellexpand::tilde("~/.local/bin/MyApp.AppImage").to_string();
        if Path::new(&target_path).exists() {
            std::fs::remove_file(&target_path)?;
        }
        std::fs::copy(new_appimage_path, &target_path)?;
        std::process::Command::new("chmod")
            .args(["+x", &target_path])
            .status()?;
    }
    #[cfg(target_os = "macos")]
    {
        let app_path = "/Applications/my_app.app";
        let new_app_path = format!("{}/my_app.app", new_appimage_path);

        if !Path::new(&new_app_path).exists() {
            return Err(anyhow::anyhow!("New app not found at {}", new_app_path));
        }

        if Path::new(app_path).exists() {
            fs::remove_dir_all(app_path)?;
        }

        Command::new("cp")
            .args(["-r", &new_app_path, app_path])
            .status()
            .map_err(|e| anyhow::anyhow!("Failed to copy new app: {}", e))?;
    }
    Ok(())
}

pub fn run_installer(installer_path: &str) -> anyhow::Result<()> {
    Command::new(installer_path)
        .spawn()
        .expect("Failed to run installer");
    process::exit(0)
}
pub fn mount_dmg(dmg_path: &str) -> anyhow::Result<String> {
    let output = Command::new("hdiutil")
        .args(["attach", dmg_path])
        .output()
        .map_err(|e| anyhow::anyhow!("Failed to mount dmg: {}", e))?;

    let output_str = String::from_utf8_lossy(&output.stdout);
    for line in output_str.lines() {
        if line.contains("/Volumes/") {
            let mount_point = line.split('\t').last().unwrap_or("").trim().to_string();
            return Ok(mount_point);
        }
    }
    Err(anyhow::anyhow!("Failed to find mount point"))
}
pub fn unmount_dmg(mount_point: &str) {
    Command::new("hdiutil")
        .args(["detach", mount_point])
        .status()
        .expect("Failed to unmount dmg");
}

// 安装更新（执行安装包）
pub fn install_update(file_path: String) -> anyhow::Result<()> {
    #[cfg(target_os = "windows")]
    run_installer(&file_path)?;
    close_old_app()?;
    Command::new("cmd")
        .arg("/c")
        .arg("start")
        .arg("my_app.exe")
        .spawn()?
        .wait()?;

    #[cfg(target_os = "macos")]
    {  // 启动新的进程来进行替换操作和启动新应用
        launch_update_process(file_path);
    }

    #[cfg(target_os = "linux")]
    {
        replace_appimage(&file_path)?;
        close_old_app()?;
        let app_path = shellexpand::tilde("~/.local/bin/MyApp.AppImage").to_string();
        Command::new(&app_path).spawn()?.wait()?;
    }

    process::exit(0)
}
pub fn launch_update_process(new_appimage_path: String) -> anyhow::Result<()> {
    // 启动一个新的进程来执行后续任务
    std::thread::spawn(move || {
        // 关闭旧应用
        if let Err(e) = close_old_app() {
            eprintln!("Error closing old app: {}", e);
            return;
        }

        // 等待旧应用退出
        sleep(Duration::from_secs(2));
        let mount_point = mount_dmg(&new_appimage_path).unwrap();
        // 处理替换和安装操作
        if let Err(e) = replace_appimage(&mount_point) {
            eprintln!("Error replacing app image: {}", e);
            return;
        }
        unmount_dmg(&mount_point);
        // 启动新的应用
        if let Err(e) = Command::new("open")
            .arg("/Applications/my_app.app")
            .spawn()
            {
            eprintln!("Failed to start new app: {}", e);
        }
    });

    // 退出当前程序
    std::process::exit(0);
}