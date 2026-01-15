# CLAUDE.md

Nixフレークベースのマルチプラットフォーム設定リポジトリ。

## システム構成

| システム | 説明 | 再構築コマンド |
|----------|------|----------------|
| `privateMac` | 個人用macOS (ARM64) | `darwin-rebuild switch --flake ~/nix-config#privateMac` |
| `businessMac` | 業務用macOS (ARM64) | `darwin-rebuild switch --flake ~/nix-config#businessMac --impure` |
| `wsl-nixos` | NixOS on WSL (x86_64) | `sudo nixos-rebuild switch --flake /home/nixos/.local/share/nix-config#wsl-nixos` |

| Home Manager | コマンド |
|--------------|----------|
| `nakazye@privateMac` | `home-manager switch --flake ~/nix-config#nakazye@privateMac` |
| `businessMac` | `home-manager switch --flake ~/nix-config#businessMac --impure` |
| `nixos@wsl-nixos` | `home-manager switch --flake /home/nixos/.local/share/nix-config#nixos@wsl-nixos` |

**重要**: businessMacは`builtins.getEnv`を使用するため`--impure`必須。

## ディレクトリ構造

```
nix-config/
├── flake.nix                  # エントリーポイント
├── home-manager/
│   ├── programs/              # 共通プログラム設定
│   ├── privateMac-home.nix
│   ├── businessMac-home.nix
│   └── wsl-home.nix
├── nix-darwin/
│   ├── common.nix             # macOS共通設定
│   ├── privateMac-configuration.nix
│   └── businessMac-configuration.nix
└── nixos/
    └── wsl-configuration.nix
```

## 開発コマンド

```bash
nix fmt                        # alejandrでフォーマット
nix flake update               # 全依存関係更新
nix flake update home-manager  # 特定入力のみ更新
```

## 設定パターン

- **プラットフォーム分岐**: `systemType`変数で macOS/WSL を判定
- **モジュール無効化**: 各Home設定で`disabledModules`を使用
- **パッケージソース**: nixpkgs-25.11（メイン）、nixpkgs-unstable（最新版必要時）、brew-nix（macOS GUIアプリ）

## トラブルシューティング

- **新規ファイル**: フレークはGit追跡ファイルのみ認識。`git add`必須
- **1Password**: Homebrew caskで管理。既存appは削除してから再構築: `sudo rm -rf /Applications/1Password.app`
- **businessMac**: `--impure`忘れるとユーザー名が空文字でビルド失敗
