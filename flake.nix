{
  description = "Experimenting with roc";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    roc.url = "github:roc-lang/roc";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, roc, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];
      perSystem = { pkgs, system, inputs', ... }:
        let
          rocPkgs = roc.packages.${system};
          darwinInputs = with pkgs;
            lib.optionals stdenv.isDarwin
            (with pkgs.darwin.apple_sdk.frameworks; [
              AppKit
              CoreFoundation
              CoreServices
              Foundation
              Security
            ]);
        in {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ ];
          };
          packages = { };
          devShells = {
            default =
              pkgs.mkShell { buildInputs = [ rocPkgs.cli ] ++ darwinInputs; };
          };
        };
    };
}
