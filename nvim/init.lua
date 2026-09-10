-- =============================================================================
-- Neovim 超軽量設定 (init.lua)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. リーダーキーの設定 (lazy.nvim の読み込み前に設定必須)
-- -----------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- -----------------------------------------------------------------------------
-- 2. 基本オプション設定 (VSCodeライク・Java向けインデント)
-- -----------------------------------------------------------------------------
local opt = vim.opt

-- 外観・表示
opt.number = true             -- 行番号を表示
opt.relativenumber = false    -- 相対行番号は無効（VSCodeスタイル）
opt.termguicolors = true      -- 24-bit True Color を有効化
opt.signcolumn = "yes"        -- サイン列を常に表示（画面のガタつき防止）

-- 操作性
opt.mouse = "a"               -- マウス操作を全モードで有効化
opt.clipboard = "unnamedplus" -- システムのクリップボードと共有
opt.ignorecase = true         -- 検索時に大文字小文字を区別しない
opt.smartcase = true          -- 大文字が含まれている場合は厳格に区別
opt.updatetime = 250          -- カーソル静止時の更新速度向上

-- インデント設定 (Java想定: 4スペース)
opt.tabstop = 4               -- タブ文字の表示幅
opt.shiftwidth = 4            -- 自動インデント時のスペース幅
opt.softtabstop = 4           -- タブキー入力時のスペース幅
opt.expandtab = true          -- タブをスペースに変換
opt.smartindent = true        -- 改行時に自動で賢くインデント

-- -----------------------------------------------------------------------------
-- 3. lazy.nvim のブートストラップ (自動インストール)
-- -----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- -----------------------------------------------------------------------------
-- 4. プラグイン設定
-- -----------------------------------------------------------------------------
require("lazy").setup({
  -- oil.nvim: バッファのように編集できる超高速・軽量ファイルマネージャー
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true, -- デフォルトのエクスプローラ (netrw) を置き換え
      view_options = {
        show_hidden = true,         -- ドットファイル（隠しファイル）を表示
      },
    },
  },

  -- telescope.nvim: 高速ファインダー (ファイル検索・全文検索)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- github/copilot.vim: GitHub Copilot 公式プラグイン (軽量インライン補完)
  {
    "github/copilot.vim",
    init = function()
      -- TabキーでCopilotの補完候補を確定（Accept）できるように設定
      vim.g.copilot_no_tab_map = false
    end,
  },
})

-- -----------------------------------------------------------------------------
-- 5. ユーティリティ関数 (プラグイン不要の超軽量フロート端末)
-- -----------------------------------------------------------------------------
local function open_lazygit()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("lazygit がインストールされていません ('brew install lazygit' を実行してください)", vim.log.levels.WARN)
    return
  end

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.fn.termopen("lazygit", {
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })

  vim.cmd("startinsert")
end

-- -----------------------------------------------------------------------------
-- 6. キーマップ設定
-- -----------------------------------------------------------------------------
local keymap = vim.keymap.set

-- <leader>e で oil.nvim を開く (VSCodeのエクスプローラのように操作)
keymap("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil file manager" })

-- <leader>f で Telescope のファイル検索を開く
keymap("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Find files" })

-- <leader>fg で Telescope の全文検索 (live_grep) を開く (ripgrep使用)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep (Search text)" })

-- <leader>gg で LazyGit をフロートウィンドウで開く
keymap("n", "<leader>gg", open_lazygit, { desc = "Open LazyGit in floating window" })

-- Copilot: Tabキーで提案を受け入れる（ゴーストテキスト確定）
keymap("i", "<Tab>", 'copilot#Accept("\\<Tab>")', {
  expr = true,
  replace_keycodes = false,
  silent = true,
  desc = "Copilot accept completion",
})
