#!/bin/bash

if [[ "$1" == "-s" ]]; then
    # Create /usr/sbin/update-grub if missing
    if [[ ! -f /usr/sbin/update-grub ]]; then
        echo "Creating /usr/sbin/update-grub with pkexec..."
        pkexec bash -c 'cat > /usr/sbin/update-grub <<EOF
#!/bin/sh
set -e
exec grub-mkconfig -o /boot/grub/grub.cfg "$@"
EOF
chmod +x /usr/sbin/update-grub'
        USERNAME=$(whoami)
        echo "Adding sudoers rule for $USERNAME to run /usr/sbin/update-grub without password..."
        pkexec bash -c "echo '$USERNAME ALL=(ALL) NOPASSWD: /usr/sbin/update-grub' > /etc/sudoers.d/update-grub && chmod 440 /etc/sudoers.d/update-grub"
    else
        echo "/usr/sbin/update-grub already exists, nothing to do."
    fi

    # Edit /etc/default/grub to set GRUB_THEME
    echo "Modifying /etc/default/grub to set GRUB_THEME..."
        pkexec bash -c '
        GRUB_FILE="/etc/default/grub"
        THEME_LINE="GRUB_THEME=\"/usr/share/grub/themes/hyde/theme.txt\""
        # Remove any existing GRUB_THEME lines (commented or not)
        sed -i "/^#\?GRUB_THEME=/d" "$GRUB_FILE"
        # Add the correct GRUB_THEME line
        echo "$THEME_LINE" >> "$GRUB_FILE"
    '
    exit 0
fi

INPUT_DIR="$HOME/.config/hyde/wallbash/grub-theme/hyde-input"
OUTPUT_DIR="$HOME/.config/hyde/wallbash/grub-theme/hyde"
HIGHLIGHT_FILE="$HOME/.cache/hyde/wallbash/grub.txt"
PY_SCRIPT="$HOME/.config/hyde/wallbash/scripts/recolor.py"
input_wall="$HOME/.cache/hyde/wall.set.png"
output_path="$HOME/.config/hyde/wallbash/grub-theme/hyde/background.png"

USED_COLORS=( "#313244" )

# Validate input wallpaper
if [[ ! -f "$input_wall" ]]; then
    echo "Error: Input wallpaper not found at $input_wall"
    exit 1
fi

# Load replacement colors
mapfile -t REPLACEMENT_COLORS < <(
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$HIGHLIGHT_FILE" | \
    grep -E '^#?[0-9a-fA-F]{6}$' | \
    head -n ${#USED_COLORS[@]}
)

if [[ ${#REPLACEMENT_COLORS[@]} -eq 0 ]]; then
    echo "No replacement colors!"
    exit 1
fi

if [[ ${#REPLACEMENT_COLORS[@]} -lt ${#USED_COLORS[@]} ]]; then
    echo "Not enough replacement colors in $HIGHLIGHT_FILE"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Helper to escape strings for JSON
json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# Build recolor job JSON
jobfile=$(mktemp)
echo "[" > "$jobfile"
sep=""

recolor_count=0
while IFS= read -r -d '' file; do
    filename="$(basename "$file")"
    out_path="$OUTPUT_DIR/$filename"
    echo "${sep}{" >> "$jobfile"
    echo "  \"img_path\": \"$(json_escape "$file")\"," >> "$jobfile"
    echo "  \"out_path\": \"$(json_escape "$out_path")\"," >> "$jobfile"
    echo "  \"base_palette\": [$(printf '"%s",' "${USED_COLORS[@]}" | sed 's/,$//')]," >> "$jobfile"
    echo "  \"target_palette\": [$(printf '"%s",' "${REPLACEMENT_COLORS[@]}" | sed 's/,$//')]" >> "$jobfile"
    echo "}" >> "$jobfile"
    sep=","
    ((recolor_count++))
done < <(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -print0)

echo "]" >> "$jobfile"

# Run recoloring
if [[ $recolor_count -eq 0 ]]; then
    echo "No images found to recolor."
    rm -f "$jobfile"
    exit 0
fi

if ! python3 "$PY_SCRIPT" < "$jobfile"; then
    echo "Python script failed!"
    rm -f "$jobfile"
    exit 1
fi

rm -f "$jobfile"
echo "Recolored $recolor_count image(s) to $OUTPUT_DIR"

# Generate blurred background
echo "Generating blurred background..."
magick "$input_wall" -strip -scale 10% -blur 0x3 -resize 100% "$output_path"
echo "Blurred background saved to: $output_path"

sudo /usr/sbin/update-grub
