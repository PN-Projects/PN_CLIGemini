# 🚀 Gemini CLI — Free AI Assistant for Your Terminal

[![Shell](https://img.shields.io/badge/built_with-shell-blue?style=for-the-badge&logo=gnubash)](https://www.gnu.org/software/bash/)
[![Gemini CLI](https://img.shields.io/badge/powered%20by-Google%20Gemini-brightgreen?style=for-the-badge&logo=google)](https://www.npmjs.com/package/@google/gemini-cli)
[![Free Forever](https://img.shields.io/badge/pricing-100%25%20free-success?style=for-the-badge)](https://open.google.com/)
[![Termux Tested](https://img.shields.io/badge/termux-tested-lightgrey?style=for-the-badge&logo=android)](https://termux.dev)
[![License: AGPL](https://img.shields.io/github/license/PN-PROJECTS/PN_CLIGemini?style=for-the-badge)](LICENSE)

---

## 📚 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Installation](#-installation-termux-or-linux)
- [Usage](#-usage-guide)
- [Settings & Config](#-settings--configuration)
- [Prompt History](#-prompt-history)
- [Future Enhancements](#-future-enhancements)
- [Credits](#-credits)
- [License](#-license)
- [Contact](#-contact)

---

## 💡 Overview

**Gemini CLI** is a powerful, feature-rich, interactive AI assistant that runs completely in your terminal — no OpenAI, no API keys, and no costs.

🔋 Built on Google’s [Gemini CLI](https://www.npmjs.com/package/@google/gemini-cli), this tool supports:

- Free Gemini Pro 2.5 access via login
- Export, clipboard, notifications, theming
- Chat + single prompt support
- Full configuration system

---

## ✨ Features

| Feature                        | Description                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| ✅ Free to use                 | No API key, no billing — uses Gemini CLI via Google login                   |
| 💬 Interactive Chat Mode       | Back-and-forth conversations                                               |
| 📝 Single Prompt Mode          | One-shot questions or code generation                                      |
| 🧾 Export Options              | Markdown, custom text, code-only, or clipboard                             |
| 📂 Export Directory Management | Change where responses are saved                                           |
| 🧠 Prompt History              | View, persist, and clear prompt history                                    |
| 🎨 Theme Toggle                | Light and Dark modes                                                       |
| 🔔 Termux Notifications        | Push notifications after exports                                           |
| 📋 Clipboard Integration       | One-tap export to system clipboard via Termux                              |

---

## 🛠 Installation (Termux or Linux)

### 1. Install Dependencies

```bash
pkg update && pkg install nodejs jq termux-api -y
````

### 2. Install Gemini CLI (Google)

```bash
npm install -g @google/gemini-cli
```

### 3. Authenticate Gemini CLI

```bash
gemini login
```

> Login in your browser with a Google account.
> You’ll gain **1000+ free requests/day** using Gemini 2.5 Pro!

### 4. Get This Repo

```bash
git clone https://github.com/your-org/gemini-cli
cd gemini-cli
chmod +x gemini_cli_freemode.sh
```

### 5. Run the Tool

```bash
./gemini_cli_freemode.sh
```

---

## 💻 Usage Guide

### Modes

* `1️⃣ Interactive Chat` — Enter multiple prompts in a live session
* `2️⃣ Single Prompt` — Ask one question or generate one file
* Export response after each session

### Export Options

* Full Markdown response
* Code blocks only
* Custom file export (e.g., `.java`, `.txt`)
* Copy to clipboard (if supported)

All exported files are saved under:

```
~/gemini-exports/
```

You can change this via Settings.

---

## ⚙ Settings & Configuration

Configuration is stored in:

```
~/.config/gemini-cli/config.json
```

Options include:

| Key             | Type   | Description                       |
| --------------- | ------ | --------------------------------- |
| `theme`         | string | `"dark"` or `"light"`             |
| `auto_naming`   | bool   | `true` or `false`                 |
| `notifications` | bool   | Toggle Termux notification alerts |
| `export_dir`    | string | Output path for saving responses  |

Configure everything via the **Settings Menu** inside the tool.

---

## 📜 Prompt History

Gemini CLI automatically stores every prompt you submit to:

```
~/.config/gemini-cli/history.txt
```

Use in-tool menu options to:

* 🔍 View your entire prompt history
* 🧹 Clear saved history

---

## 🔔 Notifications & Clipboard

| Feature       | Tool                   | Required                 |
| ------------- | ---------------------- | ------------------------ |
| Notifications | `termux-notification`  | `pkg install termux-api` |
| Clipboard     | `termux-clipboard-set` | `pkg install termux-api` |

These are optional but improve UX on Termux-based systems.

---

## 🔮 Future Enhancements

* [ ] Export to PDF via `pandoc`
* [ ] TTS (text-to-speech) output mode
* [ ] Telegram/Email integrations
* [ ] History search & autocomplete
* [ ] Offline LLM fallback (e.g., Mistral, Code Llama)

---

## 🙌 Credits

Crafted with care by **Team PrabodhNandini**
Thanks to Google for open access to [Gemini CLI](https://github.com/google/gemini-cli)
Built to empower developers, students, and researchers with terminal-first AI access.

---

## 🛡 License

This project is licensed under the [AGPL License](LICENSE).
Feel free to fork, customize, or distribute with attribution.

---

## 📬 Contact

Have feedback, issues, or contributions?

* 📧 Email: [teamprabodhnandini@gmail.com](mailto:teamprabodhnandini@gmail.com)
* 🐙 GitHub: [github.com/PN-projects](https://github.com/PN-projects)
* 🙋‍♀️ PRs and Issues: Always welcome!
