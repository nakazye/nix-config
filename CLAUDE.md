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
- `wsl-nixos`: Windows Subsystem for Linux上のNixOSシステム（x86_64）

### ユーザー環境
- `nakazye@privateMac`: macOS用ホーム環境（/Users/nakazye、1Password SSH統合）
- `nixos@wsl-nixos`: WSL用ホーム環境（/home/nixos、Linux固有設定）

## 開発コマンド

### システム再構築

**macOS Darwin (nix-darwin 25.05)**
```bash
# フレーク指定でシステム再構築
sudo nix run nix-darwin -- switch --flake ~/nix-config#privateMac

# または古い方式（darwin-rebuild利用可能な場合）
darwin-rebuild switch --flake ~/nix-config#privateMac
```

**NixOS WSL**
```bash
# WSLシステム再構築
sudo nixos-rebuild switch --flake /home/nixos/.local/share/nix-config#wsl-nixos
```

### Home Manager更新

**macOS環境**
```bash
# フレーク指定でHome Manager切り替え
home-manager switch --flake ~/nix-config#nakazye@privateMac
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

### プラットフォーム固有システム設定

**nix-darwin設定 (`nix-darwin/privateMac-configuration.nix`)**
- キーボードマッピング（Caps Lock→Control、fnキー動作）
- キーリピート設定の最適化
- トラックパッド設定（タップクリック、右クリック）
- Dock設定（最小化動作、固定アプリ）
- Touch ID sudo認証
- 1Password SSH エージェント統合
- Homebrew管理とcask自動インストール

**NixOS WSL設定 (`nixos/wsl-configuration.nix`)**
- WSL固有設定とLinux環境設定

### Home Manager設定アーキテクチャ

**共通プログラム設定 (`home-manager/programs/`)**
```
programs/
├── chezmoi/       # dotfiles管理
├── claude-code/   # Claude Code CLI設定
├── emacs/         # Emacs設定（日本語入力対応）
├── fd/            # ファイル検索ツール
├── fzf/           # ファジーファインダー
├── ghq/           # Git リポジトリ管理
├── git/           # Git設定
├── neovim/        # Neovim設定
├── ripgrep/       # 高速grep
├── tree/          # ディレクトリツリー表示
├── unar/          # アーカイブ展開
├── vim/           # Vim設定
└── zsh/           # Zshシェル設定
```

**注意**: `home-manager/programs/default.nix`のimportsはアルファベット順で管理されています。

**プラットフォーム別Home設定**
- `home-manager/darwin-home.nix`: macOS固有パッケージ（cmake、glibtool）
- `home-manager/wsl-home.nix`: Linux固有パッケージ（mozc）、systemd統合

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
- **エディタ**: Emacs（日本語入力mozc統合、幅広い設定）
- **シェル**: Zsh（カスタム設定、Git統合）
- **検索・ナビゲーション**: fzf、ripgrep、fd、peco、ghq統合
- **バージョン管理**: プラットフォーム対応Git設定
- **SSH**: 1Password SSH エージェント（macOS）

**XDG準拠**
- XDG Base Directory Specification準拠の環境変数設定
- 設定とデータファイルの標準化された配置

## 重要な設定パターン

- **統一バージョン管理**: Nixpkgs 25.05をすべての環境で使用
- **プラットフォーム認識**: macOS/WSL環境での適切な設定分岐
- **モジュラー設計**: 共有コンポーネントとプラットフォーム固有設定の分離
- **Emacs中心**: 一貫したキーバインディングとワークフロー最適化
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