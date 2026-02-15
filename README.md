# Windows Internet Stability Test

This script is designed to test the stability of the internet connection on a Windows machine with an easily manageable and minimal setup.

## Prerequisites

- Windows PowerShell (comes pre-installed on Windows 10 and Windows 11)

## How to download

You can download the internettest.ps1 and internettest.bat files to the same folder. You can download the repository as a zip file and extract it to the desired location, clone the repository to the desired location with git. It will also work by simply downloading or copy/pasting the file names and contents into the same folder.

**git clone command**

```bash
git clone https://github.com/yourusername/windows-internet-stability-test.git
```

**ZIP file command** (you can also use the "Download ZIP" option from the <> Code ⏷ button above and extract the zip file to the desired location through your file explorer)

```bash
curl -L -o windows-internet-stability-test.zip https://github.com/yourusername/windows-internet-stability-test/archive/refs/heads/main.zip
unzip windows-internet-stability-test.zip
```

## General usage

1. Adjust any timings, target, etc. in the internettest.ps1 file if you want to change the default settings.

The default settings are:

- Target: 8.8.8.8 (Google DNS)
- Ping interval: 1 second (1 second = 60 pings/minute)
- Summary interval: 3600 seconds (3600 seconds = 1 hour)

2. Run the internettest.bat file.
3. The script will run in a new PowerShell window and print a summary of the results to the console every interval.
4. The script will run indefinitely until the user closes the PowerShell window or stops it with Ctrl+C.
