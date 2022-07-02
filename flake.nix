{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs@{ self, utils, rust-overlay, ... }:
    utils.lib.mkFlake rec {
      inherit self inputs;

      supportedSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      sharedOverlays = [ (import rust-overlay) ];

      outputsBuilder = channels: with channels; {
        packages = with nixpkgs; { 
          inherit (nixpkgs) package-from-overlays;

          xxx = rustPlatform.buildRustPackage {
            pname = "xxx";
            version = "v0.1.20";
            doCheck = true;
            src = ./.;
            checkInputs = [ rustfmt clippy ];
            checkPhase = ''
              runHook preCheck

              cargo check
              rustfmt --check src/**/*.rs
              cargo clippy

              runHook postCheck
            '';
            cargoLock = {
              lockFile = ./Cargo.lock;
            };
          };
        };

        devShell = nixpkgs.mkShell {
          name = "xxx";

          buildInputs = with nixpkgs; [
            rust-bin.stable.latest.minimal
          ];
        };
      };
    };
}
