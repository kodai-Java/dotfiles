# Zsh & Oh My Zsh 設定

Oh My Zsh、テーマ (`jonathan`)、便利プラグイン (`git`, `zsh-autosuggestions`, `aws`)、および共通エイリアスを設定した Zsh 環境です。

---

## 📁 構成

- **`dotfiles/.zshrc`**: Zsh の設定本体（エイリアス `vi=nvim`, `vim=nvim`、NVM、パス設定等を含む）
- **`dotfiles/zsh/install.sh`**: Oh My Zsh および `zsh-autosuggestions` の自動導入とシンボリックリンク作成スクリプト

---

## 🚀 他端末でのセットアップ手順

```bash
# Zsh & Oh My Zsh セットアップを実行
~/dotfiles/zsh/install.sh
```

このスクリプトは以下の処理を自動で行います：
1. `zsh` 本体の確認・インストール（Linux の場合は apt/pacman/dnf）
2. Oh My Zsh の非対話インストール (`~/.oh-my-zsh`)
3. カスタム補完プラグイン `zsh-autosuggestions` の自動クローン・更新
4. `~/.zshrc` へのシンボリックリンク作成（既存ファイルは `~/.dotbackup` に退避）

---

## 💡 設定内容

- **テーマ**: `jonathan`
- **プラグイン**:
  - `git`: Git のエイリアス・ブランチ表示
  - `zsh-autosuggestions`: コマンド履歴からの自動薄文字補完
  - `aws`: AWS CLI の補完ヘルパー
- **主なエイリアス**:
  - `vi` -> `nvim`
  - `vim` -> `nvim`
  - `zshconfig` -> `mate ~/.zshrc`
  - `ohmyzsh` -> `mate ~/.oh-my-zsh`
