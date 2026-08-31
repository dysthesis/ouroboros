{
  description = "Personal Emacs configuration";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./nix/shell.nix
        ./nix/emacs.nix
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    modus-alabaster = {
      url = "github:dysthesis/minimal.el/6c304bce9319acbee4d98e384e49ffb8fe1ed766";
      flake = false;
    };
  };
}
