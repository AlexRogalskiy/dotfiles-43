#!/usr/bin/env bash
# Bash script to setup or update my dotfiles
# For docs and dotfiles, see: https://github.com/lissy93/dotfiles
# Licensed under MIT - (C) Alicia Sykes, 2022 <https://aliciasykes.com>

set -e

REPO_NAME="Lissy93/Dotfiles"
REPO_PATH="https://github.com/${REPO_NAME}.git"

CONFIG=".install.conf.yaml"
DOTBOT_DIR="dotbot"
DOTBOT_BIN="bin/dotbot"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="/home/$USER/Documents/config/dotfiles"
TITLE='🧰 Lissy93/Dotfiles Setup'

# Color Variables
CYAN_B='\033[1;96m'
YELLOW_B='\033[1;93m'
RED_B='\033[1;31m'
GREEN_B='\033[1;32m'
PLAIN_B='\033[1;37m'
RESET='\033[0m'

# Start timer
start_time=`date +%s`

# Get system type - Linux / MacOS (Darwin)
system_type=$(uname -s)

# Function that prints important text in a banner with colored border
# First param is the text to output, then optional color and padding
make_banner () {  
  bannerText=$1
  lineColor="${2:-$CYAN_B}"
  padding="${3:-0}"
  titleLen=$(expr ${#bannerText} + 2 + $padding);
  lineChar="─"; line=""
  for (( i = 0; i < "$titleLen"; ++i )); do line="${line}${lineChar}"; done
  banner="${lineColor}╭${line}╮\n│ ${PLAIN_B}${bannerText}${lineColor} │\n╰${line}╯"
  echo -e "\n${banner}\n${RESET}"
}

# Checks if a given package is installed
command_exists () {
  hash "$1" 2> /dev/null
}

# Displays death banner, and terminates app with exit code 1
terminate () {
  make_banner "Installation failed. Terminating..." ${RED_B}
  exit 1
}

# Checks if command / package (in $1) exists and then shows
# warning or error + terminates depending if required ($2)
system_verify () {
  if ! command_exists $1; then
    if $2; then
      echo -e "🚫 ${RED_B}Error:${PLAIN_B} $1 is not installed${RESET}"
      terminate
    else
      echo -e "⚠️  ${YELLOW_B}Warning:${PLAIN_B} $1 is not installed${RESET}"
    fi
  fi
}

# Show starting banner
make_banner "${TITLE}" "${CYAN_B}" 1

# Verify required packages are installed
system_verify "git" true
system_verify "zsh" false
system_verify "vim" false
system_verify "tmux" false

# If on Mac, offer to install Brew
if [ "$system_type" = "Darwin" ] && ! command_exists brew; then
  read -p "Would you like to install Homebrew? (y/N)" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -en "🍺 ${YELLOW_B}Installing Homebrew...${RESET}\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Download / update dotfiles repo with git
if [[ ! -d "$DOTFILES_DIR" ]]
then
  echo "Dotfiles not yet present. Will download ${REPO_NAME} into ${DOTFILES_DIR}"
  mkdir -p "${DOTFILES_DIR}"
  git clone --recursive ${REPO_PATH} ${DOTFILES_DIR}
else
  echo -e "Pulling changes from ${REPO_NAME} into ${DOTFILES_DIR}"
  cd "${DOTFILES_DIR}" && git pull
fi

# If git clone / pull failed, then exit with error
ret=$?
if ! test "$ret" -eq 0
then
    echo >&2 "Failed to fetch dotfiels $ret"
    terminate
fi

# # If on Mac, update Brew bundle
if [ "$system_type" = "Darwin" ] && command_exists brew && [ -f "$HOME/.Brewfile" ]
then
  echo "Updating homebrew bundle"
  brew bundle --global
fi

# Set up symlinks with dotbot
cd "${DOTFILES_DIR}"
git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
git submodule update --init --recursive "${DOTBOT_DIR}"

"${DOTFILES_DIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${DOTFILES_DIR}" -c "${CONFIG}" "${@}"

# Update source to ZSH entry point
source "${HOME}/.zshenv"

# Print success message, and time taken
total_time=$((`date +%s`-start_time))
make_banner "✨ Dotfiles configured succesfully in $total_time seconds" ${GREEN_B} 1
exit 0
