# Arch Linux installation

## Arch Linux desktop

1. Download [Arch Linux](https://archlinux.org/download/) and flash the image.
2. Boot in the live system and run `archinstall` for a guided installation.
3. After the installation, restart, login and update the system with `sudo pacman -Syyu`
    - if only wifi connection is possible, run `nmtui` to connect.

## DanctNIX Arch Linux mobile

1. Download the Pinephone image from [here](https://github.com/dreemurrs-embedded/Pine64-Arch/releases) and flash to the eMMC using [Jumpdrive](https://github.com/dreemurrs-embedded/Jumpdrive).
2. Login with user: `alarm`, password: `123456`, open the terminal an update the system `sudo pacman -Syyu`.
3. (optional) Enable SSH: `sudo systemctl enable --now sshd`

## Script for installation of packages

`run.sh` installs packages for setting up `sway`, apps and personal configuration.

Do not just run this. Examine and judge. Run at your own risk.
