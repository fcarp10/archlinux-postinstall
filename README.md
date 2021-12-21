# Arch Linux installation

1. Download [Arch Linux](https://archlinux.org/download/) and flash the image.
2. Boot in the live system and run `archinstall` for a guided installation.
3. After the installation, restart, login and update the system with `sudo pacman -Syyu`
    - if only wifi connection is possible, run `nmtui` to connect.

## Script for installation of packages

`run.sh` installs packages for setting up `sway`, apps and personal configuration.

Do not just run this. Examine and judge. Run at your own risk.
