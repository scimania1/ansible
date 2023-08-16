#!/usr/bin/env bash

export PATH="$PATH:$HOME/.local/bin:$HOME/.local/share"

sudo pacman -S python python-pip python-pipx
pipx install --include-deps ansible
ansible-galaxy collection install community.general

CWD=$(pwd)
mkdir $HOME/src
cd $HOME/src
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd $CWD

ansible-playbook --ask-become-pass local.yml
