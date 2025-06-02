# HyDE-Grub
A grub theme generator for HyDE

## Presetup

Install dependencies
```bash
sudo pacman -Sy python python-numpy python-pillow bash polkit grub sudo python imagemagick coreutils grep findutils --needed
```

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
