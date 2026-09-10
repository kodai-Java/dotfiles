# dotfiles

パーソナル開発環境の dotfiles リポジトリです。
Neovim、WezTerm、Zsh (Oh My Zsh) の設定および自動インストーラを含みます。

---

## 🚀 クイックスタート (他端末での環境構築)

### 1. リポジトリをクローン

```bash
git clone git@github.com:kodai-Java/dotfiles.git ~/dotfiles
# または HTTPS
# git clone https://github.com/kodai-Java/dotfiles.git ~/dotfiles
```

### 2. 環境構築の実行

目的に応じて以下のいずれかを実行してください。

#### パターン A: dotfiles 全体の設定を一括リンク
```bash
~/dotfiles/.bin/install.sh
```
- 各種ドットファイル (`.zshrc` 等) を `$HOME` 直下にシンボリックリンク
- `~/.config/nvim` および `~/.config/wezterm` のシンボリックリンクを作成
- `alias vi=nvim`, `alias vim=nvim` の自動設定

#### パターン B: 各ツールの単体セットアップ（ツール自動導入・同期含む）

- **Zsh & Oh My Zsh セットアップ** (本体、Oh My Zsh、zsh-autosuggestions、.zshrcリンク)
  ```bash
  ~/dotfiles/zsh/install.sh
  ```
- **Neovim セットアップ** (Neovim/ripgrep/lazygit導入、プラグインヘッドレス同期、設定リンク)
  ```bash
  ~/dotfiles/nvim/install.sh
  ```
- **WezTerm セットアップ** (WezTerm導入、設定リンク)
  ```bash
  ~/dotfiles/wezterm/install.sh
  ```

---

## 📁 ディレクトリ構成

```text
dotfiles/
├── .bin/
│   └── install.sh        # dotfiles 全体インストーラ
├── .github/
│   └── workflows/
│       └── check.yml     # CI ワークフロー
├── .zshrc                # Zsh 設定本体 (テーマ, プラグイン, エイリアス)
├── nvim/                 # Neovim 設定
│   ├── init.lua          # 設定本体 (VSCodeライク, oil, telescope, copilot, lazygit)
│   ├── lazy-lock.json    # プラグインのコミットハッシュ固定
│   ├── install.sh        # Neovim 自動インストーラ
│   └── README.md         # 詳細説明 & キーマップ
├── wezterm/              # WezTerm 設定
│   ├── wezterm.lua       # 設定本体 (外観, タブ装飾, リーダーキー Ctrl+q)
│   ├── keybinds.lua      # キーバインド設定
│   ├── install.sh        # WezTerm 自動インストーラ
│   └── README.md         # 詳細説明 & キーマップ
└── zsh/                  # Zsh 関連ツール
    ├── install.sh        # Oh My Zsh & プラグイン導入スクリプト
    └── README.md         # 詳細説明
```
