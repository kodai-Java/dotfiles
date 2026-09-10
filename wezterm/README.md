# WezTerm 設定

透過・ブラー背景、タブ装飾、および tmux 風・ブラウザ風の豊富なキーバインドをカスタマイズした WezTerm の設定です。

---

## 📁 構成ファイル

- **`wezterm.lua`**: 外観（半透明背景、ブラー、フォントサイズ、IME設定、タブバー装飾）、リーダーキー設定 (`Ctrl + q`)
- **`keybinds.lua`**: キーバインド設定（ペイン分割、タブ切り替え、フォントサイズ変更、検索、クリップボード等）
- **`install.sh`**: WezTerm の自動インストールおよびシンボリックリンク作成スクリプト

---

## 🚀 他端末でのセットアップ手順

```bash
# WezTerm 自動セットアップを実行
~/dotfiles/wezterm/install.sh
```

- macOS では Homebrew Cask 経由で WezTerm 本体をインストールし、`~/.config/wezterm` にリンクを張ります。
- ツールインストールをスキップして設定リンクのみ行う場合:
  ```bash
  ~/dotfiles/wezterm/install.sh --no-pkg
  ```

---

## ⌨️ 主な操作・キーバインド

- **リーダーキー**: `Ctrl + q` (タイムアウト 2000ms)
- **ペイン分割**:
  - 水平分割: `Alt + Ctrl + %` または `Ctrl + Shift + Alt + %`
  - 垂直分割: `Alt + Ctrl + "` または `Ctrl + Shift + Alt + "`
- **タブ切り替え**: `Ctrl + Tab` (次), `Ctrl + Shift + Tab` (前), `Super + 1..9`
- **フォントサイズ変更**: `Ctrl + +` (拡大), `Ctrl + -` (縮小), `Ctrl + 0` (リセット)
- **検索**: `Ctrl + f`
- **全画面切り替え**: `Alt + Enter`
