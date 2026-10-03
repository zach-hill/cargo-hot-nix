{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    cargo-hot.url = "github:hecrj/cargo-hot";
    cargo-hot.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      naersk,
      cargo-hot,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };

        localPackage = naersk-lib.buildPackage {
          src = cargo-hot;
        };
      in
      {
        packages = {
          default = localPackage;
          cargo-hot = localPackage;
        };
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
            ];
            nativeBuildInputs = [
              rustfmt
              pre-commit
              rustPackages.clippy
              rustc
              cargo
            ];
            packages = [
              localPackage
            ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
      }
    );
}
