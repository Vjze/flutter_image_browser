use crate::frb_generated::StreamSink;
use tokio_stream::StreamExt;
use serde::{Deserialize, Serialize};
use std::{env, fs};
use std::path::{Path, PathBuf};
use std::process::{self, Command};
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
fn get_downloads_path() -> PathBuf {
    // 获取当前用户的主目录
    let home_dir = env::var("HOME") // Linux/macOS
        .or_else(|_| env::var("USERPROFILE")) // Windows
        .expect("无法获取用户主目录");

    // 拼接 Downloads 路径
    let mut downloads_path = PathBuf::from(home_dir);
    downloads_path.push("Downloads");

    // 如果 Downloads 文件夹不存在，创建它
    if !downloads_path.exists() {
        fs::create_dir_all(&downloads_path).expect("无法创建 Downloads 文件夹");
    }

    downloads_path
}
// 下载更新文件（带进度回传）
pub async fn download_update(
    url: String,
    file_name: String,
    progress_sink: StreamSink<DownloadEvent>,
) -> anyhow::Result<()> {
    let mut file_path = get_downloads_path();
    file_path.push(file_name);
    let client = reqwest::Client::new();
    let response = match client.get(&url).send().await {
        Ok(r) => r,
        Err(e) => {
            let _ = progress_sink.add(DownloadEvent::Error(format!("网络请求失败: {e}")));
            return Err(e.into());
        }
    };
    
    let total_size = response.content_length().unwrap_or(0);
    let path = std::path::Path::new(&file_path);

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

async fn unzip_file(zip_path: &Path) -> anyhow::Result<PathBuf> {
    let dest_folder = zip_path.with_extension(""); // 创建一个与 ZIP 同名的文件夹作为解压目录
    if !dest_folder.exists() {
        fs::create_dir_all(&dest_folder)?;
    }

    let file = std::fs::File::open(zip_path)?;
    let mut archive = zip::ZipArchive::new(file)?;

    for i in 0..archive.len() {
        let mut file = archive.by_index(i)?;
        let file_path = dest_folder.join(file.name());

        if file.name().ends_with('/') {
            fs::create_dir_all(&file_path)?;
        } else {
            if let Some(parent) = file_path.parent() {
                if !parent.exists() {
                    fs::create_dir_all(parent)?;
                }
            }
            let mut output = std::fs::File::create(&file_path)?;
            std::io::copy(&mut file, &mut output)?;
        }
    }

    Ok(dest_folder)
}




pub fn run_installer(installer_path: &str) -> anyhow::Result<()> {
    Command::new(installer_path)
        .spawn()
        .expect("Failed to run installer");
    process::exit(0)
}

// 安装更新（执行安装包）
pub async fn install_update(file_name: String) -> anyhow::Result<()> {
    let mut file_path = get_downloads_path();
    file_path.push(file_name);
    #[cfg(target_os = "windows")]
    {   
        
        run_installer(file_path.display().to_string())?;
        let mut cmd = Command::new("taskkill");
        cmd.arg("/F").arg("/IM").arg("my_app.exe").spawn()?.wait()?;
        Command::new("cmd")
            .arg("/c")
            .arg("start")
            .arg("my_app.exe")
            .spawn()?
            .wait()?;}

    #[cfg(target_os = "macos")]
    {  // 启动新的进程来进行替换操作和启动新应用
        println!("path = {}", file_path.display().to_string());
        // unzip_file(&file_path);
        launch_update_process(file_path).await?;
    }

    #[cfg(target_os = "linux")]
    {   close_old_app()?;
        // replace_appimage(&file_path.display().to_string())?;
        
        let app_path = shellexpand::tilde("~/.local/bin/MyApp.AppImage").to_string();
        Command::new(&app_path).spawn()?.wait()?;
    }

    process::exit(0)
}
async fn launch_update_process(new_zip_path: PathBuf) -> anyhow::Result<()> {
    // 解压 ZIP 文件并返回解压后的文件夹路径
    let dest_folder= unzip_file(Path::new(&new_zip_path)).await?;

    // 获取解压后的文件夹路径
    let update_script = dest_folder.join("update.sh");
    println!("检查脚本路径: {:?}", update_script); // 输出脚本路径

    if !update_script.exists() {
        return Err(anyhow::anyhow!("找不到 update.sh 脚本"));
    }

    // 执行 update.sh 脚本
    let status = Command::new("sh")
        .arg(update_script)
        .current_dir(dest_folder) // 进入解压后的文件夹
        .spawn();

    match status {
        Ok(_) => {
            println!("Update process started.");
        }
        Err(e) => {
            eprintln!("Failed to start update process: {}", e);
        }
    }

    // 退出当前程序
    process::exit(0); // 退出当前程序
}
