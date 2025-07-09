#!/bin/bash

# Gemini CLI Tool for Termux
# A comprehensive CLI interface for Google Gemini AI
# Made with ❤️ by team PrabodhNandini

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/gemini-cli"
HISTORY_FILE="$CONFIG_DIR/history.txt"
CONFIG_FILE="$CONFIG_DIR/config.json"
EXPORT_DIR="$HOME/gemini-exports"
TEMP_DIR="/tmp/gemini-cli"

# Default settings
DEFAULT_MODEL="gemini-pro"
DEFAULT_THEME="dark"
API_KEY=""
CURRENT_THEME="dark"

# Create necessary directories
mkdir -p "$CONFIG_DIR" "$EXPORT_DIR" "$TEMP_DIR"

# Initialize configuration
init_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << EOF
{
    "api_key": "",
    "default_model": "$DEFAULT_MODEL",
    "theme": "$DEFAULT_THEME",
    "auto_naming": true,
    "notifications": true,
    "export_dir": "$EXPORT_DIR"
}
EOF
    fi
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        API_KEY=$(jq -r '.api_key // ""' "$CONFIG_FILE")
        CURRENT_THEME=$(jq -r '.theme // "dark"' "$CONFIG_FILE")
        AUTO_NAMING=$(jq -r '.auto_naming // true' "$CONFIG_FILE")
        NOTIFICATIONS=$(jq -r '.notifications // true' "$CONFIG_FILE")
        EXPORT_DIR=$(jq -r '.export_dir // "'"$HOME/gemini-exports"'"' "$CONFIG_FILE")
    fi
}

# Save configuration
save_config() {
    local key="$1"
    local value="$2"
    local temp_file=$(mktemp)
    jq --arg key "$key" --arg value "$value" '.[$key] = $value' "$CONFIG_FILE" > "$temp_file"
    mv "$temp_file" "$CONFIG_FILE"
}

# Theme management
apply_theme() {
    if [[ "$CURRENT_THEME" == "light" ]]; then
        # Light theme colors
        PRIMARY='\033[0;30m'     # Black
        SECONDARY='\033[0;37m'   # White
        ACCENT='\033[0;34m'      # Blue
        SUCCESS='\033[0;32m'     # Green
        WARNING='\033[0;33m'     # Yellow
        ERROR='\033[0;31m'       # Red
        BG='\033[47m'            # White background
    else
        # Dark theme colors (default)
        PRIMARY='\033[1;37m'     # Bright White
        SECONDARY='\033[0;37m'   # White
        ACCENT='\033[0;36m'      # Cyan
        SUCCESS='\033[0;32m'     # Green
        WARNING='\033[1;33m'     # Bright Yellow
        ERROR='\033[0;31m'       # Red
        BG='\033[40m'            # Black background
    fi
}

# Animated startup banner
show_startup_animation() {
    clear
    echo -e "${MAGENTA}${BOLD}"
    
    # Animation frames
    local frames=(
        "    ╔════════════════════════════════════════╗"
        "    ║                                        ║"
        "    ║           🚀 GEMINI CLI 🚀              ║"
        "    ║                                        ║"
        "    ║        Made with ❤️  by team           ║"
        "    ║         PrabodhNandini                 ║"
        "    ║                                        ║"
        "    ╚════════════════════════════════════════╝"
    )
    
    # Typewriter effect
    for frame in "${frames[@]}"; do
        echo -e "${CYAN}$frame${RESET}"
        sleep 0.1
    done
    
    echo -e "\n${GREEN}${BOLD}Initializing Gemini CLI...${RESET}"
    
    # Progress bar animation
    local progress="▓"
    echo -n "["
    for i in {1..40}; do
        echo -n "$progress"
        sleep 0.05
    done
    echo "] 100%"
    
    sleep 0.5
    echo -e "\n${SUCCESS}${BOLD}✅ Ready to assist you!${RESET}\n"
    sleep 1
}

# Check dependencies
check_dependencies() {
    local deps=("curl" "jq" "base64")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${ERROR}Missing dependencies: ${missing[*]}${RESET}"
        echo -e "${YELLOW}Please install them using:${RESET}"
        echo -e "${CYAN}pkg install ${missing[*]}${RESET}"
        exit 1
    fi
}

# API key management
setup_api_key() {
    if [[ -z "$API_KEY" ]]; then
        echo -e "${WARNING}Gemini API key not found!${RESET}"
        echo -e "${CYAN}Please enter your Gemini API key:${RESET}"
        read -s -p "API Key: " API_KEY
        echo
        
        if [[ -n "$API_KEY" ]]; then
            save_config "api_key" "$API_KEY"
            echo -e "${SUCCESS}✅ API key saved successfully!${RESET}"
        else
            echo -e "${ERROR}❌ API key cannot be empty!${RESET}"
            exit 1
        fi
    fi
}

# Send notification
send_notification() {
    local message="$1"
    if [[ "$NOTIFICATIONS" == "true" ]] && command -v termux-notification &> /dev/null; then
        termux-notification --title "Gemini CLI" --content "$message"
    fi
}

# Copy to clipboard
copy_to_clipboard() {
    local content="$1"
    if command -v termux-clipboard-set &> /dev/null; then
        echo "$content" | termux-clipboard-set
        echo -e "${SUCCESS}✅ Copied to clipboard!${RESET}"
    else
        echo -e "${WARNING}⚠️  Clipboard not available${RESET}"
    fi
}

# Generate filename
generate_filename() {
    local prompt="$1"
    local extension="$2"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    
    if [[ "$AUTO_NAMING" == "true" ]]; then
        # Create meaningful filename from prompt
        local clean_prompt=$(echo "$prompt" | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_' | cut -c1-30)
        echo "${clean_prompt}_${timestamp}.${extension}"
    else
        echo "gemini_response_${timestamp}.${extension}"
    fi
}

# Extract code blocks
extract_code_blocks() {
    local response="$1"
    echo "$response" | grep -Pzo '(?s)```[\w]*\n\K.*?(?=\n```)' | tr -d '\0'
}

# Export functions
export_markdown() {
    local content="$1"
    local filename="$2"
    local filepath="$EXPORT_DIR/$filename"
    
    echo "$content" > "$filepath"
    echo -e "${SUCCESS}✅ Exported to: $filepath${RESET}"
    send_notification "Response exported to $filename"
}

export_custom_format() {
    local content="$1"
    local filename="$2"
    local filepath="$EXPORT_DIR/$filename"
    
    echo "$content" > "$filepath"
    echo -e "${SUCCESS}✅ Exported to: $filepath${RESET}"
    send_notification "Response exported to $filename"
}

export_code_only() {
    local content="$1"
    local filename="$2"
    local filepath="$EXPORT_DIR/$filename"
    
    local code_blocks=$(extract_code_blocks "$content")
    if [[ -n "$code_blocks" ]]; then
        echo "$code_blocks" > "$filepath"
        echo -e "${SUCCESS}✅ Code exported to: $filepath${RESET}"
        send_notification "Code exported to $filename"
    else
        echo -e "${WARNING}⚠️  No code blocks found in response${RESET}"
    fi
}

# Add to history
add_to_history() {
    local prompt="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $prompt" >> "$HISTORY_FILE"
}

# Show history
show_history() {
    if [[ -f "$HISTORY_FILE" ]]; then
        echo -e "${ACCENT}${BOLD}📜 Prompt History:${RESET}\n"
        local count=1
        while read -r line; do
            echo -e "${DIM}$count.${RESET} $line"
            ((count++))
        done < "$HISTORY_FILE"
        echo
    else
        echo -e "${WARNING}📜 No history found${RESET}"
    fi
}

# Clear history
clear_history() {
    rm -f "$HISTORY_FILE"
    echo -e "${SUCCESS}✅ History cleared${RESET}"
}

# Make API call to Gemini
call_gemini_api() {
    local prompt="$1"
    local model="${2:-$DEFAULT_MODEL}"
    
    local json_payload=$(jq -n \
        --arg prompt "$prompt" \
        '{
            contents: [{
                parts: [{
                    text: $prompt
                }]
            }]
        }')
    
    local response=$(curl -s \
        -H "Content-Type: application/json" \
        -H "x-goog-api-key: $API_KEY" \
        -d "$json_payload" \
        "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent")
    
    echo "$response"
}

# Process and display response
process_response() {
    local raw_response="$1"
    
    # Check for errors
    if echo "$raw_response" | jq -e '.error' &> /dev/null; then
        local error_msg=$(echo "$raw_response" | jq -r '.error.message')
        echo -e "${ERROR}❌ Error: $error_msg${RESET}"
        return 1
    fi
    
    # Extract content
    local content=$(echo "$raw_response" | jq -r '.candidates[0].content.parts[0].text // "No response generated"')
    
    # Display response with syntax highlighting
    echo -e "${SUCCESS}${BOLD}🤖 Gemini Response:${RESET}\n"
    echo -e "${PRIMARY}$content${RESET}"
    
    # Return content for further processing
    echo "$content"
}

# Interactive chat mode
interactive_chat() {
    echo -e "${ACCENT}${BOLD}💬 Interactive Chat Mode${RESET}"
    echo -e "${DIM}Type 'exit' to quit, 'help' for commands${RESET}\n"
    
    while true; do
        echo -ne "${CYAN}You: ${RESET}"
        read -r user_input
        
        case "$user_input" in
            "exit"|"quit"|"q")
                echo -e "${SUCCESS}👋 Goodbye!${RESET}"
                break
                ;;
            "help"|"h")
                show_chat_help
                continue
                ;;
            "history")
                show_history
                continue
                ;;
            "clear")
                clear
                continue
                ;;
            "theme")
                toggle_theme
                continue
                ;;
            "")
                continue
                ;;
            *)
                echo -e "${DIM}🤔 Thinking...${RESET}"
                add_to_history "$user_input"
                
                local response=$(call_gemini_api "$user_input")
                local processed_response=$(process_response "$response")
                
                if [[ $? -eq 0 ]]; then
                    echo -e "\n${DIM}Would you like to export this response? (y/n/c for clipboard):${RESET}"
                    read -r export_choice
                    
                    case "$export_choice" in
                        "y"|"Y")
                            export_menu "$processed_response" "$user_input"
                            ;;
                        "c"|"C")
                            copy_to_clipboard "$processed_response"
                            ;;
                    esac
                fi
                echo
                ;;
        esac
    done
}

# Export menu
export_menu() {
    local content="$1"
    local prompt="$2"
    
    echo -e "${ACCENT}${BOLD}📤 Export Options:${RESET}"
    echo -e "${DIM}1.${RESET} Export as Markdown"
    echo -e "${DIM}2.${RESET} Export as custom format"
    echo -e "${DIM}3.${RESET} Export code only"
    echo -e "${DIM}4.${RESET} Copy to clipboard"
    echo -e "${DIM}5.${RESET} Cancel"
    
    echo -ne "${CYAN}Choose option (1-5): ${RESET}"
    read -r choice
    
    case "$choice" in
        1)
            local filename=$(generate_filename "$prompt" "md")
            export_markdown "$content" "$filename"
            ;;
        2)
            echo -ne "${CYAN}Enter filename with extension: ${RESET}"
            read -r custom_filename
            export_custom_format "$content" "$custom_filename"
            ;;
        3)
            echo -ne "${CYAN}Enter filename for code: ${RESET}"
            read -r code_filename
            export_code_only "$content" "$code_filename"
            ;;
        4)
            copy_to_clipboard "$content"
            ;;
        5)
            echo -e "${DIM}Export cancelled${RESET}"
            ;;
        *)
            echo -e "${ERROR}Invalid option${RESET}"
            ;;
    esac
}

# Settings menu
settings_menu() {
    while true; do
        clear
        echo -e "${ACCENT}${BOLD}⚙️  Settings Menu${RESET}\n"
        echo -e "${DIM}1.${RESET} Change API Key"
        echo -e "${DIM}2.${RESET} Toggle Theme (Current: $CURRENT_THEME)"
        echo -e "${DIM}3.${RESET} Toggle Auto-naming (Current: $AUTO_NAMING)"
        echo -e "${DIM}4.${RESET} Toggle Notifications (Current: $NOTIFICATIONS)"
        echo -e "${DIM}5.${RESET} Change Export Directory"
        echo -e "${DIM}6.${RESET} View Current Settings"
        echo -e "${DIM}7.${RESET} Back to Main Menu"
        
        echo -ne "\n${CYAN}Choose option (1-7): ${RESET}"
        read -r choice
        
        case "$choice" in
            1)
                echo -ne "${CYAN}Enter new API key: ${RESET}"
                read -s new_api_key
                echo
                save_config "api_key" "$new_api_key"
                API_KEY="$new_api_key"
                echo -e "${SUCCESS}✅ API key updated${RESET}"
                ;;
            2)
                toggle_theme
                ;;
            3)
                AUTO_NAMING=$(if [[ "$AUTO_NAMING" == "true" ]]; then echo "false"; else echo "true"; fi)
                save_config "auto_naming" "$AUTO_NAMING"
                echo -e "${SUCCESS}✅ Auto-naming toggled${RESET}"
                ;;
            4)
                NOTIFICATIONS=$(if [[ "$NOTIFICATIONS" == "true" ]]; then echo "false"; else echo "true"; fi)
                save_config "notifications" "$NOTIFICATIONS"
                echo -e "${SUCCESS}✅ Notifications toggled${RESET}"
                ;;
            5)
                echo -ne "${CYAN}Enter new export directory: ${RESET}"
                read -r new_export_dir
                mkdir -p "$new_export_dir"
                save_config "export_dir" "$new_export_dir"
                EXPORT_DIR="$new_export_dir"
                echo -e "${SUCCESS}✅ Export directory updated${RESET}"
                ;;
            6)
                view_settings
                ;;
            7)
                break
                ;;
            *)
                echo -e "${ERROR}Invalid option${RESET}"
                ;;
        esac
        
        if [[ "$choice" != "7" ]]; then
            echo -e "\n${DIM}Press Enter to continue...${RESET}"
            read
        fi
    done
}

# View current settings
view_settings() {
    clear
    echo -e "${ACCENT}${BOLD}📋 Current Settings${RESET}\n"
    echo -e "${DIM}API Key:${RESET} ${API_KEY:0:8}..."
    echo -e "${DIM}Theme:${RESET} $CURRENT_THEME"
    echo -e "${DIM}Auto-naming:${RESET} $AUTO_NAMING"
    echo -e "${DIM}Notifications:${RESET} $NOTIFICATIONS"
    echo -e "${DIM}Export Directory:${RESET} $EXPORT_DIR"
    echo -e "${DIM}Config File:${RESET} $CONFIG_FILE"
    echo -e "${DIM}History File:${RESET} $HISTORY_FILE"
}

# Toggle theme
toggle_theme() {
    if [[ "$CURRENT_THEME" == "dark" ]]; then
        CURRENT_THEME="light"
    else
        CURRENT_THEME="dark"
    fi
    
    save_config "theme" "$CURRENT_THEME"
    apply_theme
    echo -e "${SUCCESS}✅ Theme changed to $CURRENT_THEME${RESET}"
}

# Show chat help
show_chat_help() {
    echo -e "${ACCENT}${BOLD}💡 Chat Commands:${RESET}"
    echo -e "${DIM}exit/quit/q${RESET} - Exit chat mode"
    echo -e "${DIM}help/h${RESET} - Show this help"
    echo -e "${DIM}history${RESET} - Show prompt history"
    echo -e "${DIM}clear${RESET} - Clear screen"
    echo -e "${DIM}theme${RESET} - Toggle theme"
    echo
}

# Main menu
main_menu() {
    while true; do
        clear
        apply_theme
        
        echo -e "${ACCENT}${BOLD}🚀 Gemini CLI - Main Menu${RESET}\n"
        echo -e "${DIM}1.${RESET} 💬 Interactive Chat"
        echo -e "${DIM}2.${RESET} 📝 Single Query"
        echo -e "${DIM}3.${RESET} 📜 View History"
        echo -e "${DIM}4.${RESET} 🗑️  Clear History"
        echo -e "${DIM}5.${RESET} ⚙️  Settings"
        echo -e "${DIM}6.${RESET} 📁 Open Export Directory"
        echo -e "${DIM}7.${RESET} ❓ Help"
        echo -e "${DIM}8.${RESET} 🚪 Exit"
        
        echo -ne "\n${CYAN}Choose option (1-8): ${RESET}"
        read -r choice
        
        case "$choice" in
            1)
                interactive_chat
                ;;
            2)
                single_query
                ;;
            3)
                show_history
                echo -e "\n${DIM}Press Enter to continue...${RESET}"
                read
                ;;
            4)
                clear_history
                sleep 1
                ;;
            5)
                settings_menu
                ;;
            6)
                if command -v termux-open &> /dev/null; then
                    termux-open "$EXPORT_DIR"
                else
                    echo -e "${INFO}Export directory: $EXPORT_DIR${RESET}"
                fi
                echo -e "\n${DIM}Press Enter to continue...${RESET}"
                read
                ;;
            7)
                show_help
                ;;
            8)
                echo -e "${SUCCESS}👋 Thank you for using Gemini CLI!${RESET}"
                echo -e "${DIM}Made with ❤️ by team PrabodhNandini${RESET}"
                exit 0
                ;;
            *)
                echo -e "${ERROR}Invalid option. Please try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Single query mode
single_query() {
    echo -e "${ACCENT}${BOLD}📝 Single Query Mode${RESET}"
    echo -ne "${CYAN}Enter your query: ${RESET}"
    read -r query
    
    if [[ -n "$query" ]]; then
        echo -e "${DIM}🤔 Processing...${RESET}"
        add_to_history "$query"
        
        local response=$(call_gemini_api "$query")
        local processed_response=$(process_response "$response")
        
        if [[ $? -eq 0 ]]; then
            echo -e "\n${DIM}Export this response? (y/n/c for clipboard):${RESET}"
            read -r export_choice
            
            case "$export_choice" in
                "y"|"Y")
                    export_menu "$processed_response" "$query"
                    ;;
                "c"|"C")
                    copy_to_clipboard "$processed_response"
                    ;;
            esac
        fi
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${RESET}"
    read
}

# Show help
show_help() {
    clear
    echo -e "${ACCENT}${BOLD}❓ Gemini CLI Help${RESET}\n"
    echo -e "${SUCCESS}Features:${RESET}"
    echo -e "• Interactive chat with Gemini AI"
    echo -e "• Export responses in multiple formats"
    echo -e "• Prompt history management"
    echo -e "• Auto-naming for exported files"
    echo -e "• Clipboard integration"
    echo -e "• Dark/Light theme toggle"
    echo -e "• Termux notifications"
    echo -e "• Code block extraction"
    echo -e ""
    echo -e "${SUCCESS}Export Options:${RESET}"
    echo -e "• Markdown format (.md)"
    echo -e "• Custom format (user-defined extension)"
    echo -e "• Code-only export"
    echo -e "• Clipboard copy"
    echo -e ""
    echo -e "${SUCCESS}Requirements:${RESET}"
    echo -e "• curl, jq, base64 packages"
    echo -e "• Valid Gemini API key"
    echo -e "• Termux (for notifications and clipboard)"
    echo -e ""
    echo -e "${DIM}Made with ❤️ by team PrabodhNandini${RESET}"
    echo -e "\n${DIM}Press Enter to continue...${RESET}"
    read
}

# Main execution
main() {
    # Initialize
    init_config
    load_config
    apply_theme
    
    # Check dependencies
    check_dependencies
    
    # Show startup animation
    show_startup_animation
    
    # Setup API key if needed
    setup_api_key
    
    # Start main menu
    main_menu
}

# Run main function
main "$@"
