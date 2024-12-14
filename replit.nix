{ pkgs }: {
  deps = [
    pkgs.bashInteractive
    pkgs.nodePackages.bash-language-server
    pkgs.jdk
    pkgs.wget
    pkgs.frp
    pkgs.deno
    pkgs.git
  ];
}