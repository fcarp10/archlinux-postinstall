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
    if [[ $1 != \#* ]] && [ -n "$1" ]; then
        if paru -Qi "$1" &>/dev/null; then
            log "WARN" "the package $1 is already installed"
        else
            log "INFO" "installing package $1"
            paru -S --noconfirm --needed "$1"
        fi
    fi
}

usage='Usage:
'$0' [OPTION]

OPTIONS:
-b \t Installs base packages.
-s \t Installs sway packages.
-a \t Installs apps.
-t \t Installs printers packages.
-k \t Installs and configures kvm.
-p \t Installs paru.
-c \t Apply configuration.
-h \t Shows available options.
Only one option is allowed.
'

while [ "$1" != "" ]; do
    case $1 in
    -b)
        log "INFO" "installing base packages... please wait"
        cat <0_base.txt | while read -r y; do
            install_package "$y"
        done
        # sudo systemctl enable tlp.service
        sudo systemctl enable auto-cpufreq.service
        sudo systemctl enable bluetooth.service
        sudo systemctl start bluetooth.service
        sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
        sudo systemctl enable greetd.service -f
        log "INFO" "done"
        ;;
    -s)
        log "INFO" "installing sway packages... please wait"
        cat <1_sway.txt | while read -r y; do
            install_package "$y"
        done
        ;;

    -a)
        cat <2_apps.txt | while read -r y; do
            install_package "$y"
        done
        log "INFO" "done"
        ;;
    -t)
        log "INFO" "installing printers packages... please wait"
        cat <10_printers.txt | while read -r y; do
            install_package "$y"
        done
        sudo systemctl enable org.cups.cupsd.service
        log "INFO" "done"
        ;;
    -k)
        log "INFO" "installing kvm packages... please wait"
        cat <20_kvm.txt | while read -r y; do
            install_package "$y"
        done
        sudo systemctl enable libvirtd.service
        sudo systemctl start libvirtd.service
        log "INFO" "done"
        ;;

    -p)
        log "INFO" "installing paru... please wait"
        # install paru
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si
        log "INFO" "done"
        ;;

    -c)
        log "INFO" "applying personal configuration... please wait"
        # change shell to zsh
        chsh -s /usr/bin/zsh
        # add pluging to pyenv
        git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)"/plugins/pyenv-virtualenv
        # set up git
        git config --global user.name "Francisco Carpio"
        git config --global user.email "carpiofj@gmail.com"
        git config credential.helper store
        git config --global credential.helper store
        # set up docker
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker "$USER"
        newgrp docker
        # copy env vars
        sudo cp etc/environment /etc/environment
        # install vscodium extensions
        cat 30_vscodium.txt | while read y; do
            if [[ $y != \#* ]] && [ -n "$y" ]; then
                vscodium --install-extension $y
            fi
        done
        # libinput-gestures config
        sudo gpasswd -a $USER input
        libinput-gestures-setup desktop
        # start wob service
        systemctl enable --now --user wob.socket
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
