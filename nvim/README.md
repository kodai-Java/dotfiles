# Neovim 設定 (Ultra-Lightweight & Modern Setup)

VSCodeライクな操作感・軽量性・実用性を重視した Neovim の設定です。
`lazy.nvim` による高速なプラグイン管理、`oil.nvim` による快適なファイル操作、`telescope.nvim` による高速検索、`lazygit` との統合、`GitHub Copilot` によるAI支援を備えています。

---

## 🚀 他端末でのセットアップ手順

### 方法 1: Neovim 単体でセットアップする場合（推奨）

リポジトリをクローン後、`nvim` フォルダ内のインストールスクリプトを実行します。

```bash
# dotfiles をクローン (未取得の場合)
git clone https://github.com/kodai-Java/dotfiles.git ~/dotfiles

# Neovim セットアップスクリプトを実行
~/dotfiles/nvim/install.sh
```

このスクリプトは以下の処理を自動で行います：
1. OSごとの必要ツール (`neovim`, `ripgrep`, `lazygit`) のインストール (macOS: Homebrew, Linux: apt/pacman/dnf)
2. `~/.config/nvim` へのシンボリックリンク作成（既存設定がある場合は自動バックアップ）
3. `lazy.nvim` および各プラグインのヘッドレス同期・事前インストール
4. Node.js の存在確認（GitHub Copilot 利用に必要）

#### オプション
- `--no-pkg` : パッケージマネージャでのツールインストールをスキップし、シンボリックリンクとプラグイン同期のみ実行します。
  ```bash
  ~/dotfiles/nvim/install.sh --no-pkg
  ```

---

### 方法 2: dotfiles 全体をセットアップする場合

```bash
cd ~/dotfiles
.bin/install.sh
```

---

## 🔑 初期設定 (GitHub Copilot)

セットアップ完了後、`nvim` を起動して GitHub Copilot の初期認証を行います：

```bash
nvim
```

Neovim 内でコマンドモードを開き、以下を実行してブラウザ認証を行います：
```vim
:Copilot setup
```

---

## ⌨️ 主なキーバインド一覧

リーダーキー (`<leader>`) は **`Space`** に設定されています。

| キーバインド | 機能 | 説明 |
| :--- | :--- | :--- |
| `<Space> + e` | **ファイルエクスプローラ** | `oil.nvim` を開き、VSCodeのエクスプローラのようにディレクトリやファイルを編集・操作 |
| `<Space> + f` | **ファイル名検索** | `telescope.nvim` でプロジェクト内のファイルをインクリメンタル検索 |
| `<Space> + fg` | **全文検索 (grep)** | `ripgrep` を用いてプロジェクト内の文字列を高速全文検索 (`live_grep`) |
| `<Space> + gg` | **LazyGit** | プラグイン不要のフロートウィンドウで `lazygit` を快適に起動 |
| `Tab` (挿入モード) | **Copilot 補完確定** | GitHub Copilot のゴーストテキスト候補を受け入れ |

---

## 📦 プラグイン構成

- **パッケージマネージャ**: [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
- **ファイラー**: [stevearc/oil.nvim](https://github.com/stevearc/oil.nvim)
- **ファインダー**: [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- **AI 補完**: [github/copilot.vim](https://github.com/github/copilot.vim)

---

## 💡 推奨エイリアス設定 (`~/.zshrc` など)

```bash
alias vi=nvim
alias vim=nvim
```
