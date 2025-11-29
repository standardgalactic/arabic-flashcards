#!/usr/bin/env bash
set -e

echo "==============================================="
echo " Arabic Font Installer for WSL + LuaLaTeX"
echo "==============================================="

# -------- CONFIG --------
FONTNAMES=("NotoNaskhArabic-Regular.ttf" "NotoNaskhArabic-VariableFont_wght.ttf")

# Source directory: default to current directory unless specified.
SRCDIR="${1:-$(pwd)}"

echo "Source directory: $SRCDIR"
echo "Checking for font files..."

MISSING=false
for f in "${FONTNAMES[@]}"; do
    if [ ! -f "$SRCDIR/$f" ]; then
        echo " ❌ Missing: $f (expected at $SRCDIR/$f)"
        MISSING=true
    else
        echo " ✔ Found: $f"
    fi
done

if [ "$MISSING" = true ]; then
    echo "ERROR: Required font files are missing."
    echo "Place them in this directory or specify a path:"
    echo "   ./install-arabic-fonts.sh /path/to/fonts"
    exit 1
fi

echo ""
echo "-----------------------------------------------"
echo " Installing fonts to ~/.local/share/fonts ..."
echo "-----------------------------------------------"

mkdir -p ~/.local/share/fonts

for f in "${FONTNAMES[@]}"; do
    cp "$SRCDIR/$f" ~/.local/share/fonts/
    echo " ✔ Installed: $f → ~/.local/share/fonts/"
done

echo ""
echo "-----------------------------------------------"
echo " Updating fontconfig ..."
echo "-----------------------------------------------"
fc-cache -f -v > /dev/null

echo " ✔ fontconfig cache rebuilt"

echo ""
echo "-----------------------------------------------"
echo " Installing fallback to ~/texmf (TeX local tree)"
echo "-----------------------------------------------"

mkdir -p ~/texmf/fonts/opentype/local

for f in "${FONTNAMES[@]}"; do
    cp "$SRCDIR/$f" ~/texmf/fonts/opentype/local/
    echo " ✔ Copied to TeX local tree: $f"
done

echo ""
echo "-----------------------------------------------"
echo " Updating luaotfload font database ..."
echo "-----------------------------------------------"
luaotfload-tool -u

echo " ✔ luaotfload database updated"

echo ""
echo "-----------------------------------------------"
echo " Verifying installation ..."
echo "-----------------------------------------------"

fc-list | grep -i "Noto Naskh" || {
    echo " ❌ fc-list could not find Noto Naskh Arabic"
    echo " Something is wrong — contact ChatGPT for debugging."
    exit 1
}

echo " ✔ Fontconfig sees the font"

luaotfload-tool --find="Noto Naskh Arabic" >/dev/null 2>&1 && \
echo " ✔ LuaLaTeX sees the font" || {
    echo " ❌ luaotfload cannot find 'Noto Naskh Arabic'"
    echo " Try compiling again OR run:"
    echo "     luaotfload-tool --update --force"
    exit 1
}

echo ""
echo "==============================================="
echo " SUCCESS! Arabic fonts installed correctly."
echo " You may now use:"
echo ""
echo "   \\newfontfamily\\arabicfont[Script=Arabic]{Noto Naskh Arabic}"
echo ""
echo " or with exact file path:"
echo ""
echo "   \\newfontfamily\\arabicfont[Script=Arabic]{~/.local/share/fonts/NotoNaskhArabic-Regular.ttf}"
echo "==============================================="

