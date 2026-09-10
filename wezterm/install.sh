#!/usr/bin/env bash
# =============================================================================
# WezTerm 自動セットアップスクリプト
# macOS / Linux 対応
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
WEZTERM_CONFIG_DIR="${HOME}/.config/wezterm"

echo -e "${CYAN}"
echo "=================================================="
echo "      WezTerm Environment Setup Script            "
echo "=================================================="
echo -e "${NC}"

# -----------------------------------------------------------------------------
# 1. WezTerm 本体のインストール
# -----------------------------------------------------------------------------
install_wezterm() {
    if command -v wezterm >/dev/null 2>&1; then
        success "WezTerm は既にインストールされています ($(wezterm --version 2>/dev/null || true))"
        return 0
    fi

    info "WezTerm のインストールを開始します..."
    local os_type="$(uname -s)"

    if [[ "$os_type" == "Darwin" ]]; then
        info "macOS 環境を検出しました。"
        if command -v brew >/dev/null 2>&1; then
            info "Homebrew Cask を使用して WezTerm をインストールします..."
            brew install --cask wezterm || warn "brew によるインストールに失敗しました。手動で確認してください。"
        else
            warn "Homebrew がインストールされていません。"
            echo "https://wezfurlong.org/wezterm/install/macos.html からインストールしてください。"
        fi
    elif [[ "$os_type" == "Linux" ]]; then
        info "Linux 環境を検出しました。"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    echo "Debian/Ubuntu の場合は公式 apt リポジトリまたは Flatpak/AppImage を推奨します:"
                    echo "https://wezfurlong.org/wezterm/install/linux.html"
                    ;;
                arch)
                    if command -v sudo >/dev/null 2>&1; then
                        sudo pacman -S --needed --noconfirm wezterm
                    fi
                    ;;
                fedora)
                    if command -v sudo >/dev/null 2>&1; then
                        sudo dnf install -y wezterm
                    fi
                    ;;
                *)
                    echo "https://wezfurlong.org/wezterm/install/linux.html からインストールしてください。"
                    ;;
            esac
        fi
    fi
}

# -----------------------------------------------------------------------------
# 2. シンボリックリンクの作成
# -----------------------------------------------------------------------------
link_wezterm_config() {
    info "WezTerm 設定フォルダへのシンボリックリンクを作成します..."

    mkdir -p "${HOME}/.config"

    if [ -L "$WEZTERM_CONFIG_DIR" ]; then
        local current_target="$(readlink "$WEZTERM_CONFIG_DIR" || true)"
        if [[ "$current_target" == "$SCRIPT_DIR" ]]; then
            success "シンボリックリンクは既に正しく設定されています: $WEZTERM_CONFIG_DIR -> $SCRIPT_DIR"
            return 0
        else
            info "既存のシンボリックリンクを削除して張り直します: $WEZTERM_CONFIG_DIR"
            rm -f "$WEZTERM_CONFIG_DIR"
        fi
    elif [ -e "$WEZTERM_CONFIG_DIR" ]; then
        local backup_dir="${HOME}/.dotbackup/wezterm_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "${HOME}/.dotbackup"
        warn "既存の WezTerm 設定ディレクトリが存在します。バックアップに退避します: $backup_dir"
        mv "$WEZTERM_CONFIG_DIR" "$backup_dir"
    fi

    ln -snf "$SCRIPT_DIR" "$WEZTERM_CONFIG_DIR"
    success "シンボリックリンクを作成しました: $WEZTERM_CONFIG_DIR -> $SCRIPT_DIR"
}

# -----------------------------------------------------------------------------
# メイン処理
# -----------------------------------------------------------------------------
SKIP_PKG=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-pkg|--skip-pkg)
            SKIP_PKG=true
            shift
            ;;
        --help|-h)
            echo "使用方法: $0 [オプション]"
            echo ""
            echo "オプション:"
            echo "  --no-pkg, --skip-pkg   パッケージのインストールをスキップ"
            echo "  --help, -h             ヘルプを表示"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$SKIP_PKG" = false ]; then
    install_wezterm
else
    info "パッケージインストールをスキップしました。"
fi

link_wezterm_config

echo ""
echo -e "${GREEN}=================================================="
echo "      WezTerm のセットアップが完了しました！"
echo -e "==================================================${NC}"
echo ""
echo "設定ファイル: $SCRIPT_DIR/wezterm.lua"
echo "キーバインド: $SCRIPT_DIR/keybinds.lua"
echo ""
