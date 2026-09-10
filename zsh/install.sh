#!/usr/bin/env bash
# =============================================================================
# Zsh & Oh My Zsh 自動セットアップスクリプト
# =============================================================================

set -euo pipefail

# カラー設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTDIR="$(dirname "$SCRIPT_DIR")"
OH_MY_ZSH_DIR="${HOME}/.oh-my-zsh"

echo -e "${CYAN}"
echo "=================================================="
echo "      Zsh & Oh My Zsh Setup Script                "
echo "=================================================="
echo -e "${NC}"

# -----------------------------------------------------------------------------
# 1. Zsh 本体の確認・インストール
# -----------------------------------------------------------------------------
install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        success "zsh を検出しました ($(zsh --version))"
        return 0
    fi

    info "zsh が見つからないためインストールを試行します..."
    local os_type="$(uname -s)"
    if [[ "$os_type" == "Darwin" ]]; then
        if command -v brew >/dev/null 2>&1; then
            brew install zsh
        fi
    elif [[ "$os_type" == "Linux" ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    sudo apt-get update && sudo apt-get install -y zsh curl git
                    ;;
                arch)
                    sudo pacman -S --needed --noconfirm zsh curl git
                    ;;
                fedora)
                    sudo dnf install -y zsh curl git
                    ;;
            esac
        fi
    fi
}

# -----------------------------------------------------------------------------
# 2. Oh My Zsh 本体のインストール
# -----------------------------------------------------------------------------
install_oh_my_zsh() {
    if [ -d "$OH_MY_ZSH_DIR" ]; then
        success "Oh My Zsh は既にインストールされています: $OH_MY_ZSH_DIR"
    else
        info "Oh My Zsh をインストールします..."
        # KEEP_ZSHRC=yes で既存の .zshrc 上書きを防止、非対話実行
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
            error "Oh My Zsh のインストールに失敗しました。"
            return 1
        }
        success "Oh My Zsh のインストールが完了しました。"
    fi
}

# -----------------------------------------------------------------------------
# 3. カスタムプラグイン (zsh-autosuggestions) のインストール
# -----------------------------------------------------------------------------
install_plugins() {
    local zsh_custom="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"
    local autosuggestions_dir="$zsh_custom/plugins/zsh-autosuggestions"

    info "Oh My Zsh プラグイン (zsh-autosuggestions) の確認..."
    if [ -d "$autosuggestions_dir" ]; then
        info "zsh-autosuggestions は既に存在します。最新に更新します..."
        git -C "$autosuggestions_dir" pull --quiet || true
        success "zsh-autosuggestions を更新しました。"
    else
        info "zsh-autosuggestions をクローンします..."
        mkdir -p "$zsh_custom/plugins"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
        success "zsh-autosuggestions のインストールが完了しました。"
    fi
}

# -----------------------------------------------------------------------------
# 4. .zshrc のシンボリックリンク作成
# -----------------------------------------------------------------------------
link_zshrc() {
    info ".zshrc のシンボリックリンクを作成します..."

    local target="$HOME/.zshrc"
    local src="$DOTDIR/.zshrc"

    if [ ! -f "$src" ]; then
        error "dotfiles 内に .zshrc が見つかりません: $src"
        return 1
    fi

    if [ -L "$target" ]; then
        local cur="$(readlink "$target" || true)"
        if [ "$cur" = "$src" ]; then
            success "シンボリックリンクは既に正しく設定されています: $target -> $src"
            return 0
        else
            rm -f "$target"
        fi
    elif [ -e "$target" ]; then
        local backup_dir="${HOME}/.dotbackup/zshrc_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "${HOME}/.dotbackup"
        warn "既存の .zshrc が存在します。バックアップに退避します: $backup_dir"
        mv "$target" "$backup_dir"
    fi

    ln -snf "$src" "$target"
    success "シンボリックリンクを作成しました: $target -> $src"
}

# -----------------------------------------------------------------------------
# メイン処理
# -----------------------------------------------------------------------------
install_zsh
install_oh_my_zsh
install_plugins
link_zshrc

echo ""
echo -e "${GREEN}=================================================="
echo "   Zsh & Oh My Zsh のセットアップが完了しました！"
echo -e "==================================================${NC}"
echo ""
echo "■ 反映方法:"
echo "  以下のコマンドを実行するか、ターミナルを再起動してください:"
echo "  $ source ~/.zshrc"
echo ""
echo "■ デフォルトシェルが zsh でない場合:"
echo "  $ chsh -s $(which zsh)"
echo ""
