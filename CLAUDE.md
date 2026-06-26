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

## 開発コマンド

```bash
nix fmt                        # alejandraでフォーマット
nix flake check                # 設定の評価・検証（再構築前の確認）
nix flake update [input名]     # 依存更新（input名省略で全更新）
```

## 設定パターン

- **プラットフォーム分岐**: `systemType`変数（`wsl` / `privateMac` / `businessMac`）で判定
- **モジュール無効化**: 各Home設定で`disabledModules`を使用
- **パッケージソース**: nixpkgs（メイン）、nixpkgs-unstable（最新版必要時）、brew-nix（macOS GUIアプリ）
- **Claude Code設定**: `~/.claude`を直接編集せず`home-manager/programs/claude-code/`で管理

## トラブルシューティング

- **businessMac**: `builtins.getEnv`使用のため再構築は`--impure`必須（忘れるとユーザー名が空文字でビルド失敗）
- **新規ファイル**: フレークはGit追跡ファイルのみ認識。`git add`必須
- **1Password**: Homebrew caskで管理。既存appは削除してから再構築: `sudo rm -rf /Applications/1Password.app`