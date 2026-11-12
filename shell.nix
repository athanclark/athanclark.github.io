{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # ltext isn't in nixpkgs; install it separately (see README.md), e.g.
    # `nix profile add github:ltext/ltext` or `cargo install ltext`.
    nativeBuildInputs = with pkgs.buildPackages; [
      pandoc
      watchexec
      nodejs_22
      static-web-server
      shellcheck
      linkchecker
    ];
}
