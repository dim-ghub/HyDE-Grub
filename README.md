# HyDE-Grub
A grub theme generator for HyDE

## Presetup

Install dependencies
```bash
sudo pacman -Sy python python-numpy python-pillow bash polkit grub sudo python imagemagick coreutils grep findutils --needed
```

Place the dcol files to `~/.config/hyde/wallbash/always` and the scripts to `~/.config/hyde/wallbash/scripts`

Place the `grub-theme` folder to `~/.config/hyde/wallbash/`

## Setup

Make the scripts executable
```bash
chmod +x ~/.config/hyde/wallbash/scripts/grub.sh ; chmod +x ~/.config/hyde/wallbash/scripts/recolor.py
```

Run the setup command
```bash
~/.config/hyde/wallbash/scripts/grub.sh -s
```

Reload hyde
```
hydectl reload
```

## Common errors

If you get some sort of error about a missing background image, switch to the "wallpaper-error" branch and download those dcol files from the github.
