{
  description = "Neovim config packaged as a flake-wrapped binary";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # or unstable
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "nvim-my-config";
          version = "0.1.0";
          src = ./.;

          # we only need makeWrapper for the launcher script
          nativeBuildInputs = [ pkgs.makeWrapper ];

          # Put your config into $out/etc/nvim
          installPhase = ''
            mkdir -p $out/etc/nvim
            cp -r config/* $out/etc/nvim/

            # Provide a launcher that pins XDG_CONFIG_HOME to the store path
            mkdir -p $out/bin
            makeWrapper ${pkgs.neovim}/bin/nvim $out/bin/nvim-my \
              --set XDG_CONFIG_HOME $out/etc

          '';

          # (Optional) useful metadata
          meta = with pkgs.lib; {
            description = "Wrapped Neovim with my config";
            license = licenses.mit;
            platforms = platforms.unix;
            mainProgram = "nvim-my";
          };
        };
      }
    );
}
