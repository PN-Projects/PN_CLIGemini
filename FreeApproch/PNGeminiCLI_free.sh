
#!/data/data/com.termux/files/usr/bin/bash

# Gemini CLI Tool (FREE CLI VERSION)
# Made with ❤️ by team PrabodhNandini

# Paths and config
CONFIG_DIR="$HOME/.config/gemini-cli"
HISTORY_FILE="$CONFIG_DIR/history.txt"
CONFIG_FILE="$CONFIG_DIR/config.json"
EXPORT_DIR="$HOME/gemini-exports"
mkdir -p "$CONFIG_DIR" "$EXPORT_DIR"

# Colors
BOLD='\033[1m'; DIM='\033[2m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'
RED='\033[0;31m'; YELLOW='\033[1;33m'; RESET='\033[0m'

# Default config
DEFAULT_THEME="dark"
CURRENT_THEME="dark"
AUTO_NAMING="true"
NOTIFICATIONS="true"

# Load config
load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    CURRENT_THEME=$(jq -r '.theme // "dark"' "$CONFIG_FILE")
    AUTO_NAMING=$(jq -r '.auto_naming // true' "$CONFIG_FILE")
    NOTIFICATIONS=$(jq -r '.notifications // true' "$CONFIG_FILE")
    EXPORT_DIR=$(jq -r '.export_dir // "'"$EXPORT_DIR"'"' "$CONFIG_FILE")
  fi
}

save_config() {
  jq --arg key "$1" --argjson val "$2" '.[$key] = $val' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
}

init_config() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<EOF
{
  "theme": "$DEFAULT_THEME",
  "auto_naming": true,
  "notifications": true,
  "export_dir": "$EXPORT_DIR"
}
EOF
  fi
}

# Theme
apply_theme() {
  [[ "$CURRENT_THEME" == "light" ]] && PRIMARY='\033[0;30m' || PRIMARY='\033[1;37m'
}

# Startup
show_intro() {
  clear
  echo -e "${CYAN}${BOLD}"
  echo "╔═══════════════════════════════════════╗"
  echo "║           🚀 GEMINI CLI FREE          ║"
  echo "║     Made with ❤️ by PrabodhNandini     ║"
  echo "╚═══════════════════════════════════════╝"
  echo -e "${RESET}"
  sleep 1
}

check_deps() {
  for dep in jq gemini; do
    command -v "$dep" &>/dev/null || {
      echo -e "${RED}Missing: $dep. Run: pkg install $dep${RESET}"
      exit 1
    }
  done
}

# Gemini CLI
call_gemini_cli() {
  local prompt="$1"
  gemini "$prompt"
}

# Response parser
process_response() {
  local raw="$1"
  echo -e "${GREEN}${BOLD}🤖 Gemini Response:${RESET}\n"
  echo -e "$raw"
  echo "$raw"
}

generate_filename() {
  local prompt="$1" ext="$2"
  local time=$(date '+%Y%m%d_%H%M%S')
  [[ "$AUTO_NAMING" == "true" ]] && echo "$(echo $prompt | tr -cd '[:alnum:]_' | cut -c1-20)_$time.$ext" || echo "gemini_output_$time.$ext"
}

copy_to_clipboard() {
  command -v termux-clipboard-set &>/dev/null && echo "$1" | termux-clipboard-set && echo "📋 Copied!" || echo "⚠️ No clipboard support"
}

send_notification() {
  [[ "$NOTIFICATIONS" == "true" && $(command -v termux-notification) ]] && termux-notification --title "Gemini CLI" --content "$1"
}

export_response() {
  local data="$1" prompt="$2"
  echo -e "${CYAN}${BOLD}📤 Export Options:${RESET}"
  echo "1. Export as Markdown"
  echo "2. Custom file"
  echo "3. Code only"
  echo "4. Copy to clipboard"
  echo "5. Cancel"
  read -p "Choose (1-5): " opt
  case "$opt" in
    1)
      fn=$(generate_filename "$prompt" "md")
      echo "$data" > "$EXPORT_DIR/$fn" && echo "✅ Saved: $fn";;
    2)
      read -p "Filename (with ext): " fn
      echo "$data" > "$EXPORT_DIR/$fn" && echo "✅ Saved: $fn";;
    3)
      read -p "Code filename: " fn
      echo "$data" | awk '/```/{f=!f;next}f' > "$EXPORT_DIR/$fn" && echo "✅ Code saved: $fn";;
    4) copy_to_clipboard "$data" ;;
    *) echo "❌ Cancelled." ;;
  esac
}

show_history() {
  [[ -f "$HISTORY_FILE" ]] && cat "$HISTORY_FILE" || echo "📭 No history"
}

add_to_history() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$HISTORY_FILE"
}

clear_history() {
  rm -f "$HISTORY_FILE" && echo "🗑️ History cleared."
}

settings_menu() {
  while true; do
    clear
    echo -e "${CYAN}${BOLD}⚙️ Settings Menu${RESET}"
    echo "1. Toggle Theme (Current: $CURRENT_THEME)"
    echo "2. Toggle Auto-naming ($AUTO_NAMING)"
    echo "3. Toggle Notifications ($NOTIFICATIONS)"
    echo "4. Change Export Directory"
    echo "5. Back"
    read -p "Choose (1-5): " ch
    case $ch in
      1) [[ "$CURRENT_THEME" == "dark" ]] && CURRENT_THEME="light" || CURRENT_THEME="dark"
         save_config "theme" "\"$CURRENT_THEME\"";;
      2) [[ "$AUTO_NAMING" == "true" ]] && AUTO_NAMING="false" || AUTO_NAMING="true"
         save_config "auto_naming" "$AUTO_NAMING";;
      3) [[ "$NOTIFICATIONS" == "true" ]] && NOTIFICATIONS="false" || NOTIFICATIONS="true"
         save_config "notifications" "$NOTIFICATIONS";;
      4) read -p "New directory: " newd
         mkdir -p "$newd" && EXPORT_DIR="$newd" && save_config "export_dir" "\"$EXPORT_DIR\"";;
      5) break ;;
    esac
  done
}

interactive_chat() {
  echo -e "${CYAN}${BOLD}💬 Chat Mode (type 'exit' to quit)${RESET}"
  while true; do
    echo -ne "${YELLOW}You: ${RESET}"
    read -r prompt
    [[ "$prompt" == "exit" ]] && break
    add_to_history "$prompt"
    echo -e "${DIM}Thinking...${RESET}"
    resp=$(call_gemini_cli "$prompt")
    final=$(process_response "$resp")
    read -p "Export this? (y/n/c for clipboard): " ch
    [[ "$ch" == "y" ]] && export_response "$final" "$prompt"
    [[ "$ch" == "c" ]] && copy_to_clipboard "$final"
  done
}

single_query() {
  read -p "Enter query: " prompt
  [[ -z "$prompt" ]] && return
  add_to_history "$prompt"
  echo -e "${DIM}Processing...${RESET}"
  resp=$(call_gemini_cli "$prompt")
  final=$(process_response "$resp")
  read -p "Export this? (y/n/c for clipboard): " ch
  [[ "$ch" == "y" ]] && export_response "$final" "$prompt"
  [[ "$ch" == "c" ]] && copy_to_clipboard "$final"
}

main_menu() {
  while true; do
    echo -e "\n${CYAN}${BOLD}🚀 GEMINI CLI - MAIN MENU${RESET}"
    echo "1. Chat Mode"
    echo "2. Single Query"
    echo "3. View History"
    echo "4. Clear History"
    echo "5. Settings"
    echo "6. Exit"
    read -p "Choose (1-6): " opt
    case "$opt" in
      1) interactive_chat ;;
      2) single_query ;;
      3) show_history ;;
      4) clear_history ;;
      5) settings_menu ;;
      6) echo -e "${GREEN}👋 Exiting. Bye!${RESET}"; exit ;;
    esac
  done
}

# Run
init_config
load_config
apply_theme
show_intro
check_deps
main_menu
