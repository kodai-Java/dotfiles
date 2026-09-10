#!/usr/bin/env bash
# =============================================================================
# Neovim 自動セットアップスクリプト
# macOS / Linux (Ubuntu, Debian, Arch, Fedora) 対応
# =============================================================================

set -euo pipefail

# カラー設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
NVIM_CONFIG_DIR="${HOME}/.config/nvim"

echo -e "${CYAN}"
echo "=================================================="
echo "      Neovim Environment Setup Script            "
echo "=================================================="
echo -e "${NC}"

# -----------------------------------------------------------------------------
# 1. 依存ツールのインストール
# -----------------------------------------------------------------------------
install_dependencies() {
    info "依存ツール (neovim, ripgrep, lazygit) の確認とインストールを開始します..."

    local os_type="$(uname -s)"

    if [[ "$os_type" == "Darwin" ]]; then
        info "macOS 環境を検出しました。"
        if command -v brew >/dev/null 2>&1; then
            info "Homebrew を使用してツールをインストールします..."
            brew install neovim ripgrep lazygit || warn "一部パッケージのインストールに失敗した可能性があります。後で手動確認してください。"
        else
            warn "Homebrew がインストールされていません。"
            echo "https://brew.sh/ から Homebrew をインストール後、以下を実行してください:"
            echo "  brew install neovim ripgrep lazygit"
        fi
    elif [[ "$os_type" == "Linux" ]]; then
        info "Linux 環境を検出しました。"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    info "Debian/Ubuntu 環境を検出しました。"
                    if command -v sudo >/dev/null 2>&1; then
                        sudo apt-get update
                        sudo apt-get install -y neovim ripgrep
                        # lazygit はディストリビューションによって apt で入らない場合がある
                        if ! sudo apt-get install -y lazygit 2>/dev/null; then
                            warn "apt に lazygit が見つかりませんでした。GitHub Releases からインストールを推奨します。"
                        fi
                    else
                        warn "sudo が利用できません。パッケージは手動でインストールしてください。"
                    fi
                    ;;
                arch)
                    info "Arch Linux 環境を検出しました。"
                    if command -v sudo >/dev/null 2>&1; then
                        sudo pacman -S --needed --noconfirm neovim ripgrep lazygit
                    else
                        warn "sudo が利用できません。pacman -S neovim ripgrep lazygit を手動実行してください。"
                    fi
                    ;;
                fedora)
                    info "Fedora 環境を検出しました。"
                    if command -v sudo >/dev/null 2>&1; then
                        sudo dnf install -y neovim ripgrep lazygit
                    else
                        warn "sudo が利用できません。dnf install neovim ripgrep lazygit を手動実行してください。"
                    fi
                    ;;
                *)
                    warn "未対応の Linux ディストリビューション ($ID) です。パッケージを手動でインストールしてください。"
                    ;;
            esac
        else
            warn "/etc/os-release が見つかりません。neovim, ripgrep, lazygit を手動でインストールしてください。"
        fi
    else
        warn "未対応の OS ($os_type) です。手動で必要なパッケージをインストールしてください。"
    fi

    # Node.js (GitHub Copilot 用) の確認
    if command -v node >/dev/null 2>&1; then
        success "Node.js を検出しました ($(node -v))。GitHub Copilot を利用可能です。"
    else
        warn "Node.js が見つかりません。GitHub Copilot プラグイン (copilot.vim) の動作には Node.js が必要です。"
        echo "  nvm, fnm, brew などで Node.js (v18+) をインストールしてください。"
    fi
}

# -----------------------------------------------------------------------------
# 2. シンボリックリンクの作成
# -----------------------------------------------------------------------------
link_nvim_config() {
    info "Neovim 設定フォルダへのシンボリックリンクを作成します..."

    mkdir -p "${HOME}/.config"

    if [ -L "$NVIM_CONFIG_DIR" ]; then
        local current_target="$(readlink "$NVIM_CONFIG_DIR" || true)"
        if [[ "$current_target" == "$SCRIPT_DIR" ]]; then
            success "シンボリックリンクは既に正しく設定されています: $NVIM_CONFIG_DIR -> $SCRIPT_DIR"
            return 0
        else
            info "既存のシンボリックリンクを削除して張り直します: $NVIM_CONFIG_DIR"
            rm -f "$NVIM_CONFIG_DIR"
        fi
    elif [ -e "$NVIM_CONFIG_DIR" ]; then
        local backup_dir="${HOME}/.dotbackup/nvim_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "${HOME}/.dotbackup"
        warn "既存の Neovim 設定ディレクトリが存在します。バックアップに退避します: $backup_dir"
        mv "$NVIM_CONFIG_DIR" "$backup_dir"
    fi

    ln -snf "$SCRIPT_DIR" "$NVIM_CONFIG_DIR"
    success "シンボリックリンクを作成しました: $NVIM_CONFIG_DIR -> $SCRIPT_DIR"
}

# -----------------------------------------------------------------------------
# 3. プラグインのヘッドレス自動インストール
# -----------------------------------------------------------------------------
bootstrap_plugins() {
    if command -v nvim >/dev/null 2>&1; then
        info "Neovim プラグイン (lazy.nvim) を初期セットアップしています..."
        # lazy.nvim の自動クローンとプラグイン同期をヘッドレスで実行
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
        success "プラグインのインストールが完了しました。"
    else
        warn "nvim コマンドが見つからないため、プラグインの事前セットアップをスキップしました。"
        echo "  neovim インストール後に 'nvim' を起動すると自動でプラグインがインストールされます。"
    fi
}

# -----------------------------------------------------------------------------
# 4. シェルエイリアスの自動設定 (alias vi=nvim, alias vim=nvim)
# -----------------------------------------------------------------------------
setup_shell_aliases() {
    info "シェルのエイリアス (alias vi=nvim / alias vim=nvim) を確認・設定します..."

    local target_files=()
    [ -f "${HOME}/.zshrc" ] && target_files+=("${HOME}/.zshrc")
    [ -f "${HOME}/.bashrc" ] && target_files+=("${HOME}/.bashrc")

    if [ ${#target_files[@]} -eq 0 ]; then
        # どちらもなければカレントシェルに応じて作成
        if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = "zsh" ]; then
            touch "${HOME}/.zshrc"
            target_files+=("${HOME}/.zshrc")
        else
            touch "${HOME}/.bashrc"
            target_files+=("${HOME}/.bashrc")
        fi
    fi

    for rc in "${target_files[@]}"; do
        local need_header=true
        if grep -q -E "alias vi=['\"]?nvim['\"]?" "$rc" && grep -q -E "alias vim=['\"]?nvim['\"]?" "$rc"; then
            info "$rc には既に 'alias vi=nvim' / 'alias vim=nvim' が設定されています。"
            continue
        fi

        if grep -q "Neovim aliases" "$rc"; then
            need_header=false
        fi

        if [ "$need_header" = true ]; then
            echo "" >> "$rc"
            echo "# Neovim aliases (added by nvim/install.sh)" >> "$rc"
        fi

        if ! grep -q -E "alias vi=['\"]?nvim['\"]?" "$rc"; then
            echo "alias vi=nvim" >> "$rc"
            success "$rc に 'alias vi=nvim' を追加しました。"
        fi

        if ! grep -q -E "alias vim=['\"]?nvim['\"]?" "$rc"; then
            echo "alias vim=nvim" >> "$rc"
            success "$rc に 'alias vim=nvim' を追加しました。"
        fi
    done
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
            echo "  --no-pkg, --skip-pkg   パッケージマネージャによるパッケージインストールをスキップ"
            echo "  --help, -h             ヘルプを表示"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$SKIP_PKG" = false ]; then
    install_dependencies
else
    info "パッケージインストールをスキップしました。"
fi

link_nvim_config
bootstrap_plugins
setup_shell_aliases

echo ""
echo -e "${GREEN}=================================================="
echo "          セットアップが完了しました！"
echo -e "==================================================${NC}"
echo ""
echo "■ 使い方・初回設定:"
echo "  1. GitHub Copilot の有効化:"
echo "     $ nvim を起動後、以下のコマンドを実行して GitHub 連携を行ってください:"
echo "     :Copilot setup"
echo ""
echo "■ 主なキー操作 (Leader = Space):"
echo "  - <Space>e  : ファイルエクスプローラ (Oil.nvim) を開く"
echo "  - <Space>f  : ファイル名検索 (Telescope find_files)"
echo "  - <Space>fg : 全文テキスト検索 (Telescope live_grep / ripgrep)"
echo "  - <Space>gg : Git クライアント (LazyGit) をポップアップ起動"
echo "  - <Tab>     : Copilot のコード補完を確定 (挿入モード時)"
echo ""
echo "■ 設定されたエイリアス:"
echo "  alias vi=nvim"
echo "  alias vim=nvim"
echo ""
