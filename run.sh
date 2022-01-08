#!/bin/bash

###############################################################################
# Author	:	Francisco Carpio
# Github	:	https://github.com/fcarp10
###############################################################################
#   This script has been inspired by Arcolinux scripts created by Erik Dubois.
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
###############################################################################

BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

function log {
    if [[ $1 == "INFO" ]]; then
        printf "${BLUE}INFO:${NO_COLOR} %s \n" "$2"
    elif [[ $1 == "DONE" ]]; then
        printf "${GREEN}SUCCESS:${NO_COLOR} %s \n" "$2"
    elif [[ $1 == "WARN" ]]; then
        printf "${ORANGE}WARNING:${NO_COLOR} %s \n" "$2"
    else
        printf "${RED}FAILED:${NO_COLOR} %s \n" "$2"
    fi
}

function install_package {
    log "INFO" "installing packages from $1 file, please wait..."
    cat <"$1" | while read -r y; do
        if [[ $y != \#* ]] && [ -n "$y" ]; then
            if paru -Qi "$y" &>/dev/null; then
                log "WARN" "the package $y is already installed"
            else
                log "INFO" "installing package $y"
                paru -S --noconfirm --needed "$y"
            fi
        fi
    done
    log "INFO" "done"
}

usage='Usage:
'$0' [OPTION]

OPTIONS:
-ba \t Installs audio.
-bb \t Installs bluetooth.
-bl \t Installs laptop.
-s \t Installs sway.
-a \t Installs apps.
-ma \t Installs mobile apps.
-t \t Installs printers.
-k \t Installs kvm.
-p \t Installs paru.
-vs \t Installs vscodium extensions.
-g \t Installs gaming.
-c \t Applies global configuration.
-cd \t Applies desktop configuration.
-cm \t Applies mobile configuration.
-h \t Shows available options.
Only one option is allowed.
'

while [ "$1" != "" ]; do
    case $1 in
    -ba)
        install_package 0_audio.txt
        ;;
    -bb)
        install_package 0_bluetooth.txt
        log "INFO" "enabling bluetooth service..."
        sudo systemctl enable bluetooth.service
        sudo systemctl start bluetooth.service
        sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
        log "INFO" "done"
        ;;
    -bl)
        install_package 0_laptop.txt
        log "INFO" "enabling auto-cpufreq service..."
        # sudo systemctl enable tlp.service
        sudo systemctl enable auto-cpufreq.service
        log "INFO" "done"
        ;;
    -s)
        install_package 1_sway.txt
        log "INFO" "enabling greetd service..."
        sudo systemctl enable greetd.service -f
        log "INFO" "done"
        ;;
    -a)
        install_package 2_apps.txt
        ;;
    -ma)
        install_package 3_mobileapps.txt
        ;;
    -t)
        install_package 10_printers.txt
        log "INFO" "enabling org.cups.cupsd.service service..."
        sudo systemctl enable org.cups.cupsd.service
        log "INFO" "done"
        ;;
    -k)
        install_package 20_kvm.txt
        log "INFO" "enabling libvirtd service..."
        sudo systemctl enable libvirtd.service
        sudo systemctl start libvirtd.service
        log "INFO" "done"
        ;;
    -g)
        install_package 40_gaming.txt
        ;;
    -p)
        log "INFO" "installing paru... please wait"
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si
        log "INFO" "done"
        ;;
    -vs)
        log "INFO" "installing vscodium extensions... please wait"
        cat 30_vscodium.txt | while read y; do
            if [[ $y != \#* ]] && [ -n "$y" ]; then
                vscodium --install-extension $y
            fi
        done
        log "INFO" "done"
        ;;
    -c)
        log "INFO" "applying global configuration... please wait"
        # change shell to zsh
        chsh -s /usr/bin/zsh
        # set up git
        git config --global user.name "Francisco Carpio"
        git config --global user.email "carpiofj@gmail.com"
        git config credential.helper store
        git config --global credential.helper store
        # clone dotfiles
        echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >>$HOME/.bashrc
        git clone --bare https://github.com/fcarp10/dotfiles.git $HOME/.dotfiles
        exec "$SHELL"
        config reset --hard
        config checkout
        config config --local status.showUntrackedFiles no
        log "INFO" "done"
        ;;
    -cd)
        log "INFO" "applying desktop configuration... please wait"
        # copy env vars
        sudo cp desktop/etc/environment /etc/environment
        # add pluging to pyenv
        git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)"/plugins/pyenv-virtualenv
        # set up docker
        sudo usermod -aG docker "$USER"
        newgrp docker
        # libinput-gestures config
        sudo gpasswd -a $USER input
        libinput-gestures-setup desktop
        # start wob service
        systemctl enable --now --user wob.socket
        log "INFO" "done"
        ;;
    -cm)
        log "INFO" "applying mobile configuration... please wait"
        # copy env vars
        sudo cp mobile/etc/environment /etc/environment
        log "INFO" "done"
        ;;
    -h)
        echo -e "${usage}"
        exit 1
        ;;
    *)
        echo -e "Invalid option $1 \n\n${usage}"
        exit 0
        ;;
    esac
    shift
done
