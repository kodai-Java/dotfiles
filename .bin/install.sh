#!/usr/bin/env bash
set -ue

helpmsg() {
  command echo "Usage: $0 [--help | -h]" 0>&2
  command echo ""
}

link_to_homedir() {
  command echo "backup old dotfiles..."
  if [ ! -d "$HOME/.dotbackup" ];then
    command echo "$HOME/.dotbackup not found. Auto Make it"
    command mkdir "$HOME/.dotbackup"
  fi

  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir=$(dirname ${script_dir})
  if [[ "$HOME" != "$dotdir" ]];then
    for f in $dotdir/.??*; do
      [[ `basename $f` == ".git" ]] && continue
      if [[ -L "$HOME/`basename $f`" ]];then
        command rm -f "$HOME/`basename $f`"
      fi
      if [[ -e "$HOME/`basename $f`" ]];then
        command mv "$HOME/`basename $f`" "$HOME/.dotbackup"
      fi
      command ln -snf $f $HOME
    done
  else
    command echo "same install src dest"
  fi
}

link_nvim() {
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir=$(dirname ${script_dir})
  if [ -d "$dotdir/nvim" ]; then
    command echo "linking nvim config..."
    command mkdir -p "$HOME/.config"
    if [ -L "$HOME/.config/nvim" ]; then
      command rm -f "$HOME/.config/nvim"
    elif [ -e "$HOME/.config/nvim" ]; then
      if [ ! -d "$HOME/.dotbackup" ]; then
        command mkdir "$HOME/.dotbackup"
      fi
      command mv "$HOME/.config/nvim" "$HOME/.dotbackup"
    fi
    command ln -snf "$dotdir/nvim" "$HOME/.config/nvim"
  fi
}

link_wezterm() {
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir=$(dirname ${script_dir})
  if [ -d "$dotdir/wezterm" ]; then
    command echo "linking wezterm config..."
    command mkdir -p "$HOME/.config"
    if [ -L "$HOME/.config/wezterm" ]; then
      command rm -f "$HOME/.config/wezterm"
    elif [ -e "$HOME/.config/wezterm" ]; then
      if [ ! -d "$HOME/.dotbackup" ]; then
        command mkdir "$HOME/.dotbackup"
      fi
      command mv "$HOME/.config/wezterm" "$HOME/.dotbackup"
    fi
    command ln -snf "$dotdir/wezterm" "$HOME/.config/wezterm"
  fi
}

setup_nvim_aliases() {
  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rc" ]; then
      if ! grep -q -E "alias vi=['\"]?nvim['\"]?" "$rc"; then
        echo "" >> "$rc"
        echo "# Neovim alias" >> "$rc"
        echo "alias vi=nvim" >> "$rc"
        echo "alias vim=nvim" >> "$rc"
      fi
    fi
  done
}

while [ $# -gt 0 ];do
  case ${1} in
    --debug|-d)
      set -uex
      ;;
    --help|-h)
      helpmsg
      exit 1
      ;;
    *)
      ;;
  esac
  shift
done

link_to_homedir
link_nvim
link_wezterm
setup_nvim_aliases
git config --global include.path "~/.gitconfig_shared"
command echo -e "\e[1;36m Install completed!!!! \e[m"

