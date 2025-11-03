# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## アーキテクチャ概要

これはNixフレークベースの設定リポジトリで、モジュラーアプローチを使用して複数のプラットフォームと環境を管理します：

- **コア設定**: `flake.nix`がすべてのシステムとホーム設定を定義
- **マルチプラットフォーム対応**: macOS (Darwin)、WSL上のNixOS、ハードウェア上のNixOS
- **Home Manager統合**: すべてのプラットフォームでのユーザーレベル設定管理
- **モジュラー構造**: 共有コンポーネントを持つ環境ごとの個別設定

### 主要プラットフォーム
- `privateMac`: nix-darwinとHomebrew統合によるARM64 macOS
- `wsl-nixos`: Windows Subsystem for Linux上で動作するx86_64 NixOS
- `hp-spectre`: GNOMEデスクトップ環境を持つハードウェア上のNixOS

## 開発コマンド

### システム再構築
```bash
# macOS Darwinシステム
sudo nix run nix-darwin -- switch --flake ~/nix-config#privateMac

# NixOS WSLシステム
sudo nixos-rebuild switch --flake /home/nixos/.local/share/nix-config#wsl-nixos

# NixOSハードウェアシステム
sudo nixos-rebuild switch --flake .#hp-spectre
```

### Home Manager更新
```bash
# macOSホーム環境
nix run home-manager -- switch --flake ~/nix-config#nakazye@privateMac

# WSLホーム環境
home-manager switch --flake /home/nixos/.local/share/nix-config#nixos@wsl-nixos

# NixOSハードウェアホーム環境
home-manager switch --flake .#nakazye@hp-spectre
```

### コードフォーマット
```bash
# alejandraを使用したNixコードのフォーマット
nix fmt
```

## 設定構造

### コアファイル
- `flake.nix`: すべてのシステム定義を含むメインフレーク設定
- `flake.lock`: 再現可能なビルドのための依存関係ロックファイル

### プラットフォーム固有設定
- `nix-darwin/privateMac-configuration.nix`: macOSシステム設定（ドック、キーボード、Homebrew）
- `nixos/wsl-configuration.nix`: Linux固有設定を含むWSLシステム設定
- `nixos/hp-spectre-configuration.nix`: GNOMEとデスクトップパッケージを含むハードウェアNixOS

### Home Manager設定
- `home-manager/darwin-home.nix`: 1Password SSHエージェント付きmacOSユーザー環境（ユーザー名: nakazye、ホームディレクトリ: /Users/nakazye）
- `home-manager/wsl-home.nix`: Linux固有エイリアス付きWSLユーザー環境（ユーザー名: nixos、ホームディレクトリ: /home/nixos）
- `home-manager/nixos-home.nix`: NixOSハードウェアユーザー環境

### モジュラーコンポーネント
- `overlays/default.nix`: 不安定パッケージとカスタマイゼーション用パッケージオーバーレイ
- `pkgs/default.nix`: カスタムパッケージ定義フレームワーク
- `modules/`: 再利用可能な設定モジュール用ディレクトリ構造

## パッケージ管理戦略

- **主要ソース**: Nixpkgs安定版 (25.05)
- **不安定版アクセス**: 必要時により新しいパッケージ用のオーバーレイ経由
- **macOS統合**: プラットフォーム固有アプリケーション用Homebrew
- **カスタムパッケージ**: `pkgs/default.nix`で利用可能なフレームワーク

## 開発環境

### 全プラットフォーム共通コアツール
- **エディタ**: 広範囲な設定と日本語入力用mozcを含むEmacs
- **シェル**: カスタム設定とgit統合を持つZsh
- **バージョン管理**: プラットフォーム対応設定を持つGit
- **検索/ナビゲーション**: 開発ワークフロー用fzf、ripgrep、fd、peco、ghq

### プラットフォーム固有機能
- **macOS**: sudo用TouchID、1Password SSHエージェント統合
- **WSL**: Windows統合用SSH設定、Linux固有エイリアス
- **NixOS**: 完全なLinuxデスクトップパッケージを持つGNOMEデスクトップ環境

## 主要設定パターン

- **XDGベースディレクトリ**: 全システムで準拠したディレクトリ構造
- **プラットフォーム認識**: macOS対Linux環境での異なるエイリアスとパス
- **共有ベース**: プラットフォーム固有オーバーライドを持つ共通ツール設定
- **Emacs中心**: 一貫したキーバインディングでEmacs開発用に最適化されたワークフロー