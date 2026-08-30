{  inputs, ... }: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    # Import https://github.com/nix-community/emacs-overlay to our packages
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [inputs.emacs-overlay.overlay];
      config.allowUnfree = true;
    };
    emacs = pkgs.emacs-unstable-pgtk;
  in {
    _module.args = {
      inherit
        pkgs
        emacs
        ;
    };
  };
}

