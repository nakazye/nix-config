# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## アーキテクチャ概要

これはNixフレークベースのマルチプラットフォーム設定リポジトリで、モジュラーアプローチを使用して複数の環境を管理します：

- **フレーク基盤**: `flake.nix`がシステム、Home Manager設定、および依存関係を一元管理
- **マルチプラットフォーム対応**: ARM64 macOS (Darwin)、x86_64 NixOS on WSL
- **Nixpkgs 25.05**: 安定版ブランチを統一使用
- **統合Home Manager**: 全環境でのユーザーレベル設定管理
- **モジュラー構造**: プラットフォーム固有設定と共有コンポーネント

### 定義済みシステム
- `privateMac`: Apple Silicon Mac用nix-darwinシステム（ARM64、Homebrew統合）
- `businessMac`: 業務用Apple Silicon Mac用nix-darwinシステム（ARM64、環境変数依存のため`--impure`必須）
- `wsl-nixos`: Windows Subsystem for Linux上のNixOSシステム（x86_64）

### ユーザー環境
- `nakazye@privateMac`: macOS用ホーム環境（/Users/nakazye、1Password SSH統合）
- `businessMac`: 業務用macOS用ホーム環境（環境変数から動的にユーザー名取得、`--impure`必須）
- `nixos@wsl-nixos`: WSL用ホーム環境（/home/nixos、Linux固有設定）

## 開発コマンド

### システム再構築

**macOS Darwin (nix-darwin 25.05)**
```bash
# privateMac: フレーク指定でシステム再構築
sudo nix run nix-darwin -- switch --flake ~/nix-config#privateMac

# businessMac: 環境変数を参照するため --impure が必須
sudo nix run nix-darwin -- switch --flake ~/nix-config#businessMac --impure

# または古い方式（darwin-rebuild利用可能な場合）
darwin-rebuild switch --flake ~/nix-config#privateMac
darwin-rebuild switch --flake ~/nix-config#businessMac --impure
```

**NixOS WSL**
```bash
# WSLシステム再構築
sudo nixos-rebuild switch --flake /home/nixos/.local/share/nix-config#wsl-nixos
```

### Home Manager更新

**macOS環境**
```bash
# privateMac: フレーク指定でHome Manager切り替え
home-manager switch --flake ~/nix-config#nakazye@privateMac

# businessMac: 環境変数を参照するため --impure が必須
home-manager switch --flake ~/nix-config#businessMac --impure
```

**WSL環境**
```bash
# WSL用Home Manager切り替え
home-manager switch --flake /home/nixos/.local/share/nix-config#nixos@wsl-nixos
```

### 開発・保守コマンド

**フォーマット**
```bash
# Nixコードを alejandra でフォーマット
nix fmt
```

**フレーク更新**
```bash
# 全依存関係更新
nix flake update

# 特定入力のみ更新（例：home-manager）
nix flake update home-manager
```

## 設定構造詳細

### コアフレーク設定
- `flake.nix`: システム、Home Manager、モジュール定義の中央管理
- `flake.lock`: 再現可能なビルドのための依存関係固定

### ディレクトリ構造
```
nix-config/
├── flake.nix              # メインエントリーポイント
├── flake.lock             # 依存関係ロックファイル
├── home-manager/          # Home Manager設定
│   ├── programs/          # 共通プログラム設定モジュール
│   ├── privateMac-home.nix
│   ├── businessMac-home.nix
│   └── wsl-home.nix
├── nix-darwin/            # macOSシステム設定
│   ├── privateMac-configuration.nix
│   └── businessMac-configuration.nix
├── nixos/                 # NixOSシステム設定
│   └── wsl-configuration.nix
├── modules/               # 再利用可能モジュール（現在空）
│   ├── home-manager/
│   └── nixos/
├── overlays/              # パッケージオーバーレイ
│   └── default.nix
└── pkgs/                  # カスタムパッケージ（現在空）
    └── default.nix
```

### プラットフォーム固有システム設定

**nix-darwin設定 (`nix-darwin/privateMac-configuration.nix`)**
- キーボードマッピング（Caps Lock→Control、fnキー動作）
- キーリピート設定の最適化
- トラックパッド設定（タップクリック、右クリック）
- Dock設定（最小化動作、固定アプリ）
- Touch ID sudo認証
- 1Password SSH エージェント統合
- Homebrew管理とcask自動インストール

**nix-darwin設定 (`nix-darwin/businessMac-configuration.nix`)**
- privateMacと同様の基本設定（キーボード、トラックパッド、Touch ID等）
- 環境変数から動的にユーザー名を取得（`builtins.getEnv`使用）
- カスタムnixbld UID/GID設定（企業環境での既存ID競合対応）
- 業務用Homebrew casks（JetBrains IDEs、AWS VPN、Slack等）
- **重要**: `--impure`フラグが必須

**NixOS WSL設定 (`nixos/wsl-configuration.nix`)**
- フレーク＆nixコマンド有効化
- フォント設定（HackGen NF、Nerd Font Symbols、Noto Color Emoji）
- Zshをデフォルトシェルに設定
- XDG Base Directory環境変数設定

### Home Manager設定アーキテクチャ

**共通プログラム設定 (`home-manager/programs/`)**
```
programs/
├── chezmoi/       # dotfiles管理
├── claude-code/   # Claude Code CLI設定
├── cmake/         # CMakeビルドツール
├── direnv/        # ディレクトリ単位の環境変数管理（nix-direnv統合）
├── emacs/         # Emacs設定（日本語入力対応）
├── fd/            # ファイル検索ツール
├── fzf/           # ファジーファインダー
├── gcc/           # GCCコンパイラ
├── ghq/           # Git リポジトリ管理
├── git/           # Git設定
├── gitstatus/     # Zsh向けGitステータス高速表示
├── glibtool/      # GNU libtool（macOS用）
├── gnumake/       # GNU Make
├── libtool/       # libtool
├── nixvim/        # Neovim設定（Telescope、ToggleTerm統合）
├── ripgrep/       # 高速grep
├── tree/          # ディレクトリツリー表示
├── unar/          # アーカイブ展開
├── vim/           # Vim設定
├── wezterm/       # WezTermターミナル（macOS専用、WSLでは無効）
└── zsh/           # Zshシェル設定
```

**注意**:
- `home-manager/programs/default.nix`のimportsはアルファベット順で管理
- weztermはWSL環境では`isWSL`フラグにより無効化

**プラットフォーム別Home設定**
- `home-manager/privateMac-home.nix`: 個人macOS用ホーム設定（ユーザー: nakazye）
- `home-manager/businessMac-home.nix`: 業務macOS用ホーム設定（Claude Code無効化、環境変数依存で`--impure`必須）
- `home-manager/wsl-home.nix`: Linux固有パッケージ（mozc、noto-fonts-color-emoji）、systemd統合

### システム機能詳細

**macOSシステム設定**
- キーボード：Caps Lock→Control変換、F1-F12直接使用、最適化されたリピート設定
- トラックパッド：タップクリック、右クリック有効化
- Dock：アプリアイコンへの最小化、システムアプリ固定
- セキュリティ：Touch ID sudo認証
- 入力：日本語入力（ライブ変換無効）、Spotlightショートカット無効化

**パッケージ管理戦略**
- **主要ソース**: Nixpkgs 25.05安定版統一使用
- **オーバーレイ**: カスタムパッケージと不安定版アクセス対応
- **macOS統合**: プラットフォーム固有GUI用Homebrew
- **フォント**: HackGen Nerd Font、シンボル専用Nerd Font

**開発環境統合**
- **エディタ**: Emacs（日本語入力対応）、Neovim（Telescope、ToggleTerm統合）
- **シェル**: Zsh（カスタム設定、gitstatus統合）
- **ターミナル**: WezTerm（macOS専用、HackGen Console NFフォント）
- **検索・ナビゲーション**: fzf、ripgrep、fd、ghq統合
- **バージョン管理**: プラットフォーム対応Git設定
- **環境管理**: direnv（nix-direnv統合、ログ抑制で高速化）
- **ビルドツール**: gcc、gnumake、cmake、libtool、glibtool
- **SSH**: 1Password SSH エージェント（macOS）

**XDG準拠**
- XDG Base Directory Specification準拠の環境変数設定
- 設定とデータファイルの標準化された配置

## 重要な設定パターン

- **統一バージョン管理**: Nixpkgs 25.05をすべての環境で使用
- **プラットフォーム認識**: `isWSL`フラグによるmacOS/WSL環境の適切な設定分岐
- **モジュラー設計**: 共有コンポーネントとプラットフォーム固有設定の分離
- **条件付きインポート**: `lib.optionals`でプラットフォーム固有モジュールを制御
- **1Password統合**: macOSでのSSH鍵管理の統合

## トラブルシューティング

**フレーク関連**
- Git追跡ファイルのみがフレークで利用可能（未追跡ファイルは無視される）
- `nix flake update`でロックファイル更新後は要システム再構築

**Home Manager**
- デフォルト設定場所が `~/.config/home-manager/flake.nix` に変更（24.11以降）
- `--flake`フラグ必須（省略すると古いチャンネルベース動作）

**nix-darwin**
- 25.05では `nix run nix-darwin` による呼び出しが推奨
- MASアプリが毎回再インストールされる既知の問題あり

**businessMac固有の注意事項**
- `builtins.getEnv`で環境変数を参照しているため、必ず`--impure`フラグが必要
- `--impure`を忘れるとユーザー名やホームディレクトリが空文字になりビルド失敗
- nixbld UID/GID（351/4000）は企業環境での既存ID競合を回避するためのカスタム設定