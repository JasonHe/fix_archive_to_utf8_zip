# 压缩包文件名乱码修复工具

[English](README.md) | 中文说明

这是一个 Windows 脚本，用于自动修复压缩包中的乱码文件名（尤其是中国 Windows 系统 GBK 编码生成的 ZIP 文件），并重新打包为 UTF‑8 编码的 ZIP 文件。

该工具适用于：

在英文 Windows 系统中打开中国系统创建的压缩包时出现 **文件名乱码** 的情况。

脚本会自动尝试正确的编码方式解压，并重新打包为标准 UTF‑8 ZIP。

---

## 功能特性

- 修复 ZIP 压缩包文件名乱码
- 自动重新打包为 **UTF‑8 编码 ZIP**
- 支持多种压缩格式
- 自动检测 ZIP 文件名编码
- 支持密码压缩包（弹窗输入密码）
- 支持分卷压缩包
- 自动避免覆盖已有输出文件
- 不生成临时 log 文件
- 自动清理临时目录
- 支持中文文件名
- 支持 `&` 等特殊字符

---

## 支持的压缩格式

| 格式 | 支持 |
|------|------|
| `.zip` | ✔ |
| `.rar` | ✔ |
| `.7z` | ✔ |
| `.tar` | ✔ |
| `.tar.gz` / `.tgz` | ✔ |
| `.tar.bz2` / `.tbz2` | ✔ |
| `.tar.xz` / `.txz` | ✔ |
| `.gz` | ✔ |
| `.bz2` | ✔ |
| `.xz` | ✔ |

---

## 分卷压缩支持

脚本可以自动识别常见分卷压缩包，例如：

```
archive.7z.001
archive.zip.001
archive.part1.rar
archive.part01.rar
archive.part001.rar
archive.r00
archive.z01
```

拖动 **任意一个分卷文件** 到脚本上即可自动处理。

---

## 加密压缩包

如果压缩包带密码，程序会弹出输入框：

```
请输入压缩包密码
```

输入密码后脚本会继续自动解压并转换。

---

## 使用方法

### 拖拽使用

将压缩包拖到：

```
fix_archive_to_utf8_zip.bat
```

脚本会自动：

1. 解压压缩包  
2. 修复文件名编码  
3. 重新打包  
4. 输出 UTF‑8 ZIP

### 命令行

```
fix_archive_to_utf8_zip.bat archive.zip
```

---

## 运行环境

- Windows 10 / Windows 11
- 已安装 7‑Zip

默认路径：

```
C:\Program Files\7-Zip\7z.exe
```

如果安装路径不同，请修改脚本中的：

```
set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
```

---

## License

MIT License
