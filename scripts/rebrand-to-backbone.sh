#!/bin/bash
# Rebrand Sunshine to Backbone PC Streaming
# Run from the Fuji-Sunshine root directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

echo "=== Rebranding Sunshine to Backbone PC Streaming ==="
echo "Root directory: $ROOT_DIR"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${YELLOW}→${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# ============================================
# 1. CMakeLists.txt - Project identity
# ============================================
info "Updating CMakeLists.txt..."

sed -i '' 's/project(Sunshine/project(BackbonePCStreaming/g' CMakeLists.txt
sed -i '' 's/"Self-hosted game stream host for Moonlight"/"Backbone PC Streaming"/g' CMakeLists.txt
sed -i '' 's|"https://app.lizardbyte.dev/Sunshine"|"https://playbackbone.com"|g' CMakeLists.txt
sed -i '' 's/"dev.lizardbyte.app.Sunshine"/"com.backbone.pcstreaming"/g' CMakeLists.txt
sed -i '' 's/"GameStream host for Moonlight"/"Backbone PC Streaming"/g' CMakeLists.txt

success "CMakeLists.txt updated"

# ============================================
# 2. System tray menu text
# ============================================
info "Updating system tray menu..."

sed -i '' 's/"Open Sunshine"/"Open Backbone"/g' src/system_tray.cpp

success "System tray updated"

# ============================================
# 3. Web UI files
# ============================================
info "Updating web UI files..."

# index.html - remove Sunshine references
sed -i '' 's/console.log("Hello, Sunshine!")/console.log("Backbone PC Streaming")/g' src_assets/common/assets/web/index.html

# welcome.html - change default username
sed -i '' 's/newUsername: "sunshine"/newUsername: "backbone"/g' src_assets/common/assets/web/welcome.html

# General.vue - change placeholder
sed -i '' 's/placeholder="Sunshine"/placeholder="Backbone"/g' src_assets/common/assets/web/configs/tabs/General.vue

success "Web UI files updated"

# ============================================
# 4. All locale files (22 languages)
# ============================================
info "Updating locale files..."

LOCALE_DIR="src_assets/common/assets/web/public/assets/locale"

for file in "$LOCALE_DIR"/*.json; do
    if [ -f "$file" ]; then
        # Update greeting
        sed -i '' 's/"Welcome to Sunshine!"/"Welcome to Backbone PC Streaming!"/g' "$file"
        sed -i '' 's/"Welcome back, Sunshine!"/"Welcome to Backbone PC Streaming!"/g' "$file"

        # Update any remaining "Sunshine" user-facing strings (careful not to touch technical strings)
        sed -i '' 's/": "Sunshine"/": "Backbone PC Streaming"/g' "$file"
        sed -i '' 's/"Restart Sunshine"/"Restart Backbone PC Streaming"/g' "$file"
        sed -i '' 's/"If Sunshine isn'\''t/"If Backbone PC Streaming isn'\''t/g' "$file"
        sed -i '' 's/"Sunshine is restarting"/"Backbone PC Streaming is restarting"/g' "$file"

        # Update descriptions that mention Sunshine by name
        sed -i '' 's/by Sunshine/by Backbone PC Streaming/g' "$file"
        sed -i '' 's/from Sunshine/from Backbone PC Streaming/g' "$file"
        sed -i '' 's/to Sunshine/to Backbone PC Streaming/g' "$file"
    fi
done

success "Locale files updated ($(ls -1 "$LOCALE_DIR"/*.json | wc -l | tr -d ' ') files)"

# ============================================
# 5. Windows service scripts
# ============================================
info "Updating Windows service scripts..."

WINDOWS_MISC="src_assets/windows/misc"

# Service scripts
sed -i '' 's/sunshinesvc/backbonesvc/g' "$WINDOWS_MISC/service/install-service.bat"
sed -i '' 's/sunshinesvc/backbonesvc/g' "$WINDOWS_MISC/service/uninstall-service.bat"

# Firewall scripts
sed -i '' 's/sunshine.exe/backbone.exe/g' "$WINDOWS_MISC/firewall/add-firewall-rule.bat"

# Note: Not changing config filenames to avoid breaking existing installs
# Migration would need to be handled separately

success "Windows scripts updated"

# ============================================
# 6. Rename icon files (create copies with new names)
# ============================================
info "Setting up icon files..."

WEB_IMAGES="src_assets/common/assets/web/public/images"

# Create backbone variants from backlight if they don't exist
if [ -f "$WEB_IMAGES/backlight.ico" ]; then
    cp "$WEB_IMAGES/backlight.ico" "$WEB_IMAGES/backbone.ico" 2>/dev/null || true
    cp "$WEB_IMAGES/backlight-logo.png" "$WEB_IMAGES/backbone-logo.png" 2>/dev/null || true
fi

# Root level icons - copy existing sunshine icons as backbone (to be replaced with real assets later)
if [ -f "sunshine.ico" ] && [ ! -f "backbone.ico" ]; then
    cp sunshine.ico backbone.ico
fi
if [ -f "sunshine.png" ] && [ ! -f "backbone.png" ]; then
    cp sunshine.png backbone.png
fi
if [ -f "sunshine.svg" ] && [ ! -f "backbone.svg" ]; then
    cp sunshine.svg backbone.svg
fi
if [ -f "sunshine.icns" ] && [ ! -f "backbone.icns" ]; then
    cp sunshine.icns backbone.icns
fi

success "Icon files set up"

# ============================================
# 7. Update references to use new icon names
# ============================================
info "Updating icon references..."

# Note: system_tray.cpp already uses backlight.ico, no changes needed there

success "Icon references updated"

# ============================================
# 8. C++ source comments (optional, cosmetic)
# ============================================
info "Updating source comments..."

# Update file header comments (cosmetic only)
# Skipping to avoid breaking anything - these are just comments

success "Source comments (skipped - cosmetic only)"

# ============================================
# Summary
# ============================================
echo ""
echo "=== Rebranding Complete ==="
echo ""
echo "Changes made:"
echo "  • CMakeLists.txt - Project name, description, URLs"
echo "  • System tray - Menu text"
echo "  • Web UI - Greetings, placeholders, console logs"
echo "  • Locale files - All 22 language files"
echo "  • Windows scripts - Service and firewall names"
echo "  • Icon files - Created backbone.* copies"
echo ""
echo -e "${YELLOW}Manual steps still needed:${NC}"
echo "  1. Replace backbone.ico/png/svg with actual Backbone branding assets"
echo "  2. Replace sunshine-playing/pausing/locked icons with Backbone variants"
echo "  3. Update GitHub API URLs in index.html if you want version checking"
echo "  4. Test build: mkdir build && cd build && cmake .. && make"
echo ""
echo -e "${YELLOW}Config file migration (optional):${NC}"
echo "  If you want to rename sunshine.conf → backbone.conf:"
echo "  1. Update src/config.cpp default paths"
echo "  2. Create migration script for existing users"
echo ""
