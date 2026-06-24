# ユーザー設定

すべての Claude Code セッションに適用されるユーザーレベル設定。

## Git

- コミットメッセージは1行目50文字以内で要約
- `Co-Authored-By` などAI生成を示す署名は付けない
- SSH認証エラー（`Permission denied (publickey)`）時:
  1PasswordのSSHエージェント有効化を促し、確認を取ってから再実行

## 環境（Nix管理）

- 未インストールのツールは `nix run nixpkgs#<package>` で一時利用
- ファイル削除に `rm` を使わない: macは `trash`、Linux/WSLは `trash-cli`
- `find` の代わりに `fd`、`grep` の代わりに `rg`
- **oletools は使用禁止**（会社のウイルススキャンが誤検知）。
  overlay と PreToolUse フックで強制済み

## 作業スタイル

- 要件が不明確なら推測せず確認する
