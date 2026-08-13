{
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.python3Packages.markitdown];

  # markitdown -> datasets -> pyarrow -> arrow-cpp の依存で arrow-cpp が
  # ソースビルドされ、arrow-azurefs-test が会社プロキシのMITM証明書で失敗する。
  # overlays/default.nix で arrow-cpp の doInstallCheck=false にして回避している。
  # nixpkgs 更新でキャッシュ済み arrow-cpp が降ってくるようになったら overlay を削除できるか確認すること
  home.activation.arrowCppWorkaroundNotice = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo ""
    echo "NOTE: arrow-cpp は doInstallCheck=false でビルドされています (arrow-azurefs-test の証明書エラー回避)"
    echo "      解消確認後は overlays/default.nix の arrow-cpp override を削除してください"
    echo ""
  '';
}
