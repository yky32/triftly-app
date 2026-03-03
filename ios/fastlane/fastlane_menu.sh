#!/bin/bash

# Fastlane Interactive Menu Script
# Shows all available Fastlane lanes and allows selection by number

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FASTLANE_DIR="$SCRIPT_DIR"
IOS_DIR="$(dirname "$FASTLANE_DIR")"

# Check if we're in the right directory
if [ ! -f "$FASTLANE_DIR/Fastfile" ]; then
    echo -e "${RED}Error: Fastfile not found. Please run this script from the ios/fastlane directory.${NC}"
    exit 1
fi

# Change to iOS directory for fastlane commands
cd "$IOS_DIR" || exit 1

# Arrays to store lanes
declare -a lane_numbers
declare -a lane_commands
declare -a lane_descriptions

counter=1

clear
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}          ${BOLD}Fastlane Menu - Depozio${NC}                    ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}${YELLOW}📱 iOS Lanes${NC}"
echo -e "${YELLOW}────────────────────────────────────────────────────────────${NC}"
echo ""

# iOS Lanes
lane_numbers[$counter]=$counter
lane_commands[$counter]="ios build_debug"
lane_descriptions[$counter]="Build iOS app for development (Debug)"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}ios build_debug${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="ios build_release"
lane_descriptions[$counter]="Build iOS app for release"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}ios build_release${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="ios build_ipa"
lane_descriptions[$counter]="Build iOS app and create IPA (development)"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}ios build_ipa${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="ios build_ipa export_method:app-store"
lane_descriptions[$counter]="Build iOS app and create IPA (app-store)"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}ios build_ipa (app-store)${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="ios upload_testflight"
lane_descriptions[$counter]="Build IPA and upload to TestFlight"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}ios upload_testflight${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="ios increment_build"
lane_descriptions[$counter]="Increment build number"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}ios increment_build${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="ios clean"
lane_descriptions[$counter]="Clean iOS build artifacts"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}ios clean${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

echo -e "${BOLD}${MAGENTA}🤖 Android Lanes${NC}"
echo -e "${MAGENTA}────────────────────────────────────────────────────────────${NC}"
echo ""

lane_numbers[$counter]=$counter
lane_commands[$counter]="android build_debug"
lane_descriptions[$counter]="Build Android app for development (Debug)"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}android build_debug${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="android build_release_apk"
lane_descriptions[$counter]="Build Android app for release (APK)"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}android build_release_apk${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="android build_release_bundle"
lane_descriptions[$counter]="Build Android app for release (App Bundle)"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}android build_release_bundle${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="android clean"
lane_descriptions[$counter]="Clean Android build artifacts"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}android clean${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

echo -e "${BOLD}${BLUE}🔧 Common Lanes${NC}"
echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
echo ""

lane_numbers[$counter]=$counter
lane_commands[$counter]="get_dependencies"
lane_descriptions[$counter]="Get Flutter dependencies"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}get_dependencies${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="test"
lane_descriptions[$counter]="Run Flutter tests"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}test${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

lane_numbers[$counter]=$counter
lane_commands[$counter]="clean_all"
lane_descriptions[$counter]="Clean all build artifacts"
echo -e "  ${GREEN}[$counter]${NC} ${BOLD}clean_all${NC}"
echo -e "      ${CYAN}→${NC} ${lane_descriptions[$counter]}"
echo ""
((counter++))

max_option=$((counter - 1))

echo -e "${BOLD}${CYAN}────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}${YELLOW}[0]${NC} Exit"
echo ""
echo -e "${BOLD}${CYAN}Enter your choice [0-$max_option]:${NC} "
read -r choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input. Please enter a number.${NC}"
    exit 1
fi

if [ "$choice" -eq 0 ]; then
    echo -e "${YELLOW}Exiting...${NC}"
    exit 0
fi

if [ "$choice" -lt 1 ] || [ "$choice" -gt "$max_option" ]; then
    echo -e "${RED}Invalid choice. Please select a number between 1 and $max_option.${NC}"
    exit 1
fi

# Get the selected lane
selected_lane="${lane_commands[$choice]}"
selected_desc="${lane_descriptions[$choice]}"

# Special handling for option 5 (upload_testflight) - ask for environment
if [ "$choice" -eq 5 ]; then
    echo ""
    echo -e "${BOLD}${CYAN}Select Environment:${NC}"
    echo -e "${YELLOW}────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} ${BOLD}dev${NC}     - Development environment (env/.env.dev)"
    echo -e "  ${GREEN}[2]${NC} ${BOLD}stag${NC}   - Staging environment (env/.env.stag)"
    echo -e "  ${GREEN}[3]${NC} ${BOLD}prod${NC}   - Production environment (env/.env.prod) ${BOLD}[Default for TestFlight]${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}Enter environment choice [1-3] (default: 3 for prod):${NC} "
    read -r env_choice
    
    # Default to prod if empty or invalid
    if [ -z "$env_choice" ] || ! [[ "$env_choice" =~ ^[1-3]$ ]]; then
        env_choice=3
        echo -e "${YELLOW}Using default: prod${NC}"
    fi
    
    case $env_choice in
        1)
            env_value="dev"
            ;;
        2)
            env_value="stag"
            ;;
        3)
            env_value="prod"
            ;;
        *)
            env_value="prod"
            ;;
    esac
    
    echo ""
    echo -e "${BOLD}${GREEN}Environment selected:${NC} ${BOLD}$env_value${NC}"
    echo -e "${CYAN}Will use:${NC} env/.env.$env_value"
    echo ""
    
    # Add env parameter to the lane command
    selected_lane="$selected_lane env:$env_value"
fi

echo ""
echo -e "${BOLD}${GREEN}Selected:${NC} ${BOLD}$selected_lane${NC}"
echo -e "${CYAN}Description:${NC} $selected_desc"
echo ""
echo -e "${YELLOW}Running fastlane $selected_lane...${NC}"
echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
echo ""

# Execute the selected lane
bundle exec fastlane $selected_lane
exit_code=$?

# Check if the command failed and if it's option 5 (upload_testflight)
# Automatically fix CocoaPods and retry for option 5
# Note: env parameter is already included in selected_lane if option 5 was chosen
if [ $exit_code -ne 0 ] && [ "$choice" -eq 5 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Build failed. Attempting to fix CocoaPods issue...${NC}"
    echo ""
    
    # Run pod install to fix CocoaPods
    echo -e "${CYAN}Running pod install...${NC}"
    cd "$IOS_DIR" || exit 1
    pod install --repo-update
    
    pod_exit_code=$?
    
    if [ $pod_exit_code -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ CocoaPods fixed successfully!${NC}"
        echo -e "${YELLOW}🔄 Retrying fastlane command...${NC}"
        echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
        echo ""
        
        # Retry the fastlane command
        bundle exec fastlane $selected_lane
        exit_code=$?
    else
        echo ""
        echo -e "${RED}❌ Failed to fix CocoaPods. Please fix manually.${NC}"
        echo -e "${YELLOW}Try running: cd ios && pod install --repo-update${NC}"
    fi
fi

echo ""
echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
if [ $exit_code -eq 0 ]; then
    echo -e "${BOLD}${GREEN}✅ Lane completed successfully!${NC}"
else
    echo -e "${BOLD}${RED}❌ Lane failed with exit code $exit_code${NC}"
fi
echo ""

