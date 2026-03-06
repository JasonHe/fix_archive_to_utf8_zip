# Fix Archive Filename Encoding

English | [中文说明](README_cn.md)

A lightweight Windows script that automatically fixes garbled filenames in compressed archives (especially Chinese ZIP archives created on legacy systems) and repacks them into a clean UTF-8 encoded ZIP file.

This tool is designed for situations where archives created on Chinese Windows systems (GBK encoding) appear with corrupted filenames on English Windows systems.

The script extracts the archive using the best detected encoding and repacks everything into a standard UTF-8 ZIP file.

---

## Features

- Fixes garbled filenames from legacy encoded ZIP archives
- Automatically repacks archives into **UTF-8 encoded ZIP**
- Supports many archive formats
- Automatically detects the correct filename encoding for ZIP files
- Handles encrypted archives with a password popup
- Supports multi-volume archives
- Prevents overwriting existing output files
- No temporary log files generated
- Cleans temporary files automatically
- Works with Chinese / Unicode filenames
- Supports special characters in filenames such as `&`

---

## Supported Archive Formats

| Format | Supported |
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

## Multi‑Volume Archive Support

The script automatically detects and processes common split archives such as:

```
archive.7z.001
archive.zip.001
archive.part1.rar
archive.part01.rar
archive.part001.rar
archive.r00
archive.z01
```

You can drag **any part** of the archive onto the script and it will automatically locate the first volume.

---

## Encrypted Archives

If the archive is password‑protected, a Windows popup will appear asking for the password.

After entering the password, extraction and conversion will continue automatically.

---

## Usage

### Drag & Drop

Drag an archive onto:

```
fix_archive_to_utf8_zip.bat
```

The script will:

1. Extract the archive  
2. Fix filename encoding  
3. Repack the contents  
4. Output a clean UTF‑8 ZIP file

### Command Line

```
fix_archive_to_utf8_zip.bat archive.zip
```

---

## Requirements

- Windows 10 / Windows 11
- 7‑Zip installed

Default expected path:

```
C:\Program Files\7-Zip\7z.exe
```

If 7‑Zip is installed elsewhere, edit this line in the script:

```
set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
```

---

## License

MIT License
