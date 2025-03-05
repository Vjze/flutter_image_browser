
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ImageScanError {
    #[error("未选择文件夹")]
    NoFolderSelected,
    #[error("文件夹扫描失败")]
    FolderError,
    #[error("文件操作失败")]
    FileError,
    #[error("图片解析失败: {0}")]
    ImageError(#[from] imagesize::ImageError),
    #[error("任务执行失败: {0}")]
    TaskError(#[from] tokio::task::JoinError),
}
