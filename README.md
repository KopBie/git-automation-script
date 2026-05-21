# Git Manager - Bash Automation Script

A powerful and interactive Bash script designed to automate daily Git workflows. This script simplifies repository initialization, configuration, pushing local assignments, and managing remote files on GitHub directly from the Linux terminal.

## 🚀 Features

* **Interactive Menu:** Clean and user-friendly CLI navigation.
* **Repository Linker/Switcher:** Automates `git init`, branch setting to `main`, remote configuration, and global user identities.
* **Smart Push & Sync:** Automatically pulls latest changes to prevent conflicts, displays status shortlists, and auto-generates timestamped commit messages if left blank.
* **Advanced File/Folder Eraser:** Offers dual deletion modes:
    1.  **Remote-Only:** Deletes files from the GitHub repository while keeping the local files safe (`git rm --cached`).
    2.  **Total Wipe:** Permanently deletes files from both local storage and GitHub.

## 📋 Prerequisites

* Linux Environment (Tested on Ubuntu/Zsh)
* Git installed and configured
* Executable permissions granted to the script

## 🛠️ Installation & Usage

1. Clone this repository or download the `git-manager.sh` file:
   ```bash
   git clone https://github.com/KopBie/git-automation-script.git
   cd git-manager
2. Grant executable permission to the script:
   ```bash
   chmod +x git-manager.sh
3. Run the script:
   ```bash
   ./git-manager.sh

## ⚙️ How It Works
The script contains a centralized interactive loop:
* Option 1: Initializes Git and configures remote URLs dynamically.
* Option 2: Performs safe staging, displays status summaries, and pushes securely.
* Option 3: Reads dynamic arrays of local directory contents, allowing targeted deletion without manual command typing.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
