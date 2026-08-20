# Encry

A simple command-line tool for encrypting and decrypting files.

## Usage

```text
encry -e <file>   # Encrypt a file
encry -d <file>   # Decrypt a file
```

## Installing a build

The installers expect a compiled binary. Example builds:

```bash
# macOS (run on the target Mac)
GOOS=darwin GOARCH=$(go env GOARCH) go build -o build/encry .

# Windows build from macOS/Linux
GOOS=windows GOARCH=amd64 go build -o build/encry.exe .
```

### macOS

The macOS ZIP file should contain:

```text
encry-macos/
├── encry
└── install-macos.sh
```

After extracting the ZIP file, run:

```bash
cd encry-macos
chmod +x install-macos.sh
./install-macos.sh
```

The installer uses `/usr/local/bin`. If that directory is not writable, it offers a
per-user installation in `~/.local/bin`.

### Windows PowerShell

The Windows ZIP file should contain:

```text
encry-win/
├── encry.exe
└── install-windows.ps1
```

After extracting the ZIP file, run this in PowerShell:

```powershell
.\install-windows.ps1
```

By default, the installer copies `encry.exe` to `$HOME\.local\bin` and adds that
directory to the user `PATH`. Open a new terminal afterwards.
