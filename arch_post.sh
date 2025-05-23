#!/bin/bash -i

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
-p \t Installs paru
-ba \t Installs audio
-bb \t Installs bluetooth
-bl \t Installs laptop
-bn \t Installs network
-hs \t Installs hyprland
-a \t Installs apps
-ae \t Installs apps extra
-ac \t Installs cli
-ad \t Installs dev
-ao \t Installs office
-ap \t Installs pass
-at \t Installs theme
-ma \t Installs mobile apps
-t \t Installs printers
-k \t Installs kvm
-vs \t Installs vscodium extensions
-g \t Installs gaming
-c \t Applies global configuration
-cd \t Pulls dotfiles
-cm \t Applies mobile configuration
-h \t Shows available options
Only one option is allowed
'

while [ "$1" != "" ]; do
    case $1 in
    -p)
        log "INFO" "installing paru... please wait"
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si
        log "INFO" "done"
        ;;
    -ba)
        install_package 0_audio.txt
        systemctl --user enable --now pipewire.socket
        systemctl --user enable --now pipewire-pulse.socket
        systemctl --user enable --now wireplumber.service
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
        sudo systemctl enable auto-cpufreq.service
        log "INFO" "enabling thermald service..."
        sudo systemctl enable thermald.service
        log "INFO" "done"
        ;;
    -bn)
        install_package 0_network.txt
        log "INFO" "done"
        ;;
    -hs)
        install_package 1_hyprland.txt
        sudo cp conf/hypr-run /usr/local/bin/
        log "INFO" "enabling swayosd service..."
        sudo systemctl enable --now swayosd-libinput-backend.service     
        log "INFO" "done"
        ;;
    -a)
        install_package 2_apps.txt
        ;;
    -ae)
        install_package 2_apps_extra.txt
        ;;
    -ac)
        install_package 2_cli.txt
        ;;
    -ad)
        install_package 2_dev.txt
        ;;
    -ao)
        install_package 2_office.txt
        ;;
    -ap)
        install_package 2_pass.txt
        ;;
    -at)
        install_package 2_theme.txt
        ;;
    -ma)
        install_package 3_mobileapps.txt
        ;;
    -t)
        install_package 10_printers.txt
        log "INFO" "enabling cups service..."
        sudo systemctl enable cups
        log "INFO" "done"
        ;;
    -k)
        install_package 20_kvm.txt
        log "INFO" "enabling libvirtd service..."
        sudo systemctl enable --now libvirtd.service
        log "INFO" "done"
        ;;
    -g)
        install_package 40_gaming.txt
        sudo modprobe i2c-dev
        sudo modprobe i2c-piix4
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
        timedatectl set-ntp true
        timedatectl set-timezone Europe/Berlin
        log "INFO" "installing oh-my-zsh and plugins"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/marlonrichert/zsh-autocomplete ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
        log "INFO" "generating locale..."
        sudo cp conf/locale.gen /etc/
        log "INFO" "copying autologin conf..."
        sudo mkdir /etc/systemd/system/getty@tty1.service.d
        sudo cp conf/autologin.conf /etc/systemd/system/getty@tty1.service.d/
        log "WARN" "remember to edit USER in /etc/systemd/system/getty@tty1.service.d/autologin.conf" 
        log "WARN" "remember to edit USER in /usr/lib/systemd/system/logid.service"
        sudo locale-gen
        log "INFO" "copying pacman conf..."
        sudo cp config/pacman.conf /etc/pacman.conf
        log "INFO" "enable ssh-agent service..."
        systemctl enable --now --user ssh-agent.service
        log "INFO" "changing papirus folder theme..."
        papirus-folders -C red
        log "INFO" "setting up docker..."
        sudo usermod -aG docker "$USER"
        newgrp docker
        log "INFO" "setting alacritty default for nemo..."
        gsettings set org.cinnamon.desktop.default-applications.terminal exec alacritty
        log "INFO" "setting nemo default file manager"
        xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
        log "INFO" "adding virtualenv to pyenv..."
        git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)"/plugins/pyenv-virtualenv
        log "INFO" "change default shell"
        chsh -s /bin/zsh "$USER"
        ;;
    -cd)
        log "INFO" "pulling dotfiles... please wait"
        echo "alias gdots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >>$HOME/.bashrc
        git clone --bare https://github.com/fcarp10/dotfiles.git $HOME/.dotfiles
        source $HOME/.bashrc
        gdots reset --hard
        gdots checkout
        gdots config --local status.showUntrackedFiles no
        log "INFO" "done"
        ;;
    -cm)
        log "INFO" "applying mobile configuration... please wait"
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
