{
  description = "Zig project via zig-common";

  inputs = {
    zig-common.url "github.com:penuvil/zig-common";
    nixpkgs.follows = "zig-common/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, zig-common, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        devShells.default = zig-common.lib.mkDevShell { };
        checks.default = zig-common.lib.mkchecks { src = self; };
      });
}
