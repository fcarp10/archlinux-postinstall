# Arch Linux installation

1. Download [Arch Linux](https://archlinux.org/download/) and flash the image.
2. Boot in the live system and run `archinstall` for a guided installation.
3. After the installation, restart, login and update the system with `sudo pacman -Syyu`
    - if only wifi connection is possible, run `nmtui` to connect.

## Script for installation of packages

Script for installing all required packages for setting up `sway`, apps and personal configuration.

Do not just run this. Examine and judge. Run at your own risk.

```
chmod +x install-packages.sh
./install-packages.sh -h

OPTIONS:
-b \t Installs base packages.
-s \t Installs sway packages.
-a \t Installs apps.
-p \t Installs printers packages.
-k \t Installs and configures kvm.
-p \t Installs paru.
-c \t Apply configuration.
-h \t Shows available options.
Only one option is allowed.
```
