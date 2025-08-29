{
  description = "Zig Dev Environment Template - Zig Latest Release";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";

    zig-overlay.url = "github:mitchellh/zig-overlay";

    zls.url = "github:zigtools/zls/0.15.0";
    zls.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, flake-utils, zig-overlay, zls, ...}:
    let
      templates = {
        zig-project = {
          description = "New Zig project with zig-common dev environment";
          path = nixpkgs.lib.cleanSourceWith {
            filter = name: type: true;
            src = ./template;
          };
        };
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ zig-overlay.overlays.default ];
        };


        zls-bin = zls.packages.${system}.zls;
      in
      rec {
        lib = {
          mkDevShell = { extras ? [], projectLocalCaches ? false }:
            pkgs.mkShell {
              buildInputs = with pkgs; [
                pkgs.zigpkgs."0.15.1"
                zls-bin
                helix
                tmux
                just
                lldb
                gdb
                watchexec
                ripgrep
                fd
                git
                jujutsu
              ] ++ extras;

              shellHook = ''
                echo "Zig Dev Shell Active - Zig: $(zig version)"
              '' + (if projectLocalCaches then ''
                export ZIG_GLOBAL_CACHE_DIR="$PWD/.zig-global-cache"
                export ZIG_LOCAL_CACHE_DIR="$PWD/.zig-local-cache"
              '' else "");
            };

          mkChecks = { src, optimize ? "Debug" }:
            pkgs.stdenvNoCC.mkDerivation {
              name = "zig-checks";
              inherit src;
              dontUnpack = true;
              nativeBuildInputs = [ pkgs.zigpkgs."0.15.1" ]; 
              buildPhase = ''
                zig fmt --check . || {
                  echo "Run 'zig fmt .' to fix formatting"; exit 1;
                }
                zig build -Doptimize=${optimize}
                zig build test -Doptimize=${optimize}
              '';
              installPhase = "mkdir -p $out; echo ok > $out/result";
            };
        };

        devShells.default = lib.mkDevShell { };

        packages.default = zls-bin;
        packages.zls-bin = zls-bin;

      }
    ) // { inherit templates; };
}
