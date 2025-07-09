# 🚀 PN_CLIGemini — Gemini AI Terminal Client for Developers & Power Users

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](LICENSE)
[![Platform: Termux](https://img.shields.io/badge/Platform-Termux-informational)](https://termux.dev)
[![Status: Production Ready](https://img.shields.io/badge/status-production--ready-brightgreen.svg)]()
[![Made with ❤️ by Team PrabodhNandini](https://img.shields.io/badge/Made%20With-%E2%9D%A4-red)]()

> An advanced, blazing-fast, interactive Gemini AI CLI tool for Termux and Linux shells. Built from scratch using Bash and Gemini's **paid** API — tailored for developers, automation junkies, and terminal aficionados.

---

## ✨ Features

- 🔒 Uses **Google Gemini's paid API** (via `x-goog-api-key`)
- 🎨 Fully **theme-aware** (Light/Dark)
- 📤 Multiple export modes:
  - Markdown (`.md`)
  - Custom file format (`.txt`, `.html`, etc.)
  - **Code-only** extraction
  - Clipboard copy
  - 📄 PDF (coming soon)
- 🔁 Prompt history logging + viewing
- 📋 Smart file auto-naming & timestamping
- 🧠 Built-in interactive and single-query modes
- 🔧 Configurable API key, export path, and behavior
- 🛎️ Termux notification support
- ✂️ Extract code blocks from any Gemini response
- 🛠️ No dependencies beyond `curl`, `jq`, `base64`

---

## ⚙️ Installation

### 📥 1. Clone the repository

```bash
git clone https://github.com/PN-Projects/PN_CLIGemini
cd PN_CLIGemini
````

### 📲 2. Install required dependencies (on Termux)

```bash
pkg update && pkg install -y curl jq termux-api
```

> Optional: For PDF export (upcoming), install `pandoc`:

```bash
pkg install pandoc
```

### 🗝️ 3. Set your Gemini API Key

Your script will ask for the API key at first run, or you can manually add it to the config:

```bash
nano ~/.config/gemini-cli/config.json
# Add your "api_key": "YOUR_API_KEY_HERE"
```

### ▶️ 4. Run the CLI

```bash
chmod +x gemini.sh
./gemini.sh
```

---

## 📂 Export System

All exported files are stored in:

```
~/gemini-exports/
```

Export options include:

* 📄 Full response in markdown
* 🧾 Custom file with extension
* 🧑‍💻 Code-only (extracted from code blocks)
* 📋 Direct copy to clipboard (`termux-clipboard-set`)

---

## 🖥️ Modes of Usage

### 💬 Interactive Chat

```bash
> Select option [1] from main menu
> Talk continuously to Gemini
```

### 📝 Single Prompt

```bash
> Select option [2]
> Enter a one-shot question
```

---

## 🔧 Settings Menu

* 🌐 API Key: Add / change
* 🎨 Toggle Dark/Light theme
* 🏷️ Enable/disable auto file naming
* 🔔 Enable/disable notifications
* 📁 Set your preferred export directory
* 👁️ View current config values

---

## 🧪 Roadmap

* [x] Markdown export
* [x] Code extraction
* [x] Theming support
* [x] Notifications
* [x] Export directory customization
* [x] Interactive chat loop
* [ ] **PDF export** support via `pandoc`
* [ ] Voice-to-text input (Termux + Google Speech)
* [ ] Gemini vision/image support

---

## 📜 License

This project is licensed under the **GNU AGPL v3.0**. See [`LICENSE`](LICENSE) for more.

---

## 🧠 Credits

Developed and maintained by **Team PrabodhNandini**

> *“Crafted with care. Shipped with ❤️.”*

---

## 🧵 Contributing

Pull requests, ideas, and discussions welcome!
Please follow standard GitHub etiquette and open an issue for major changes.

---


## ✅ Tested On

* Termux (Android 10+)
* Linux (Ubuntu 22.04)
* GitHub Codespaces
* Kali Linux (Terminal only)
