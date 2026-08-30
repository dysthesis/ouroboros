{
  perSystem = {
    self',
    inputs',
    pkgs,
    system,
    emacs,
    ...
  }: {
    devShells.default = let
      # Wrapper script that sets ../src as the Emacs config dir so we can
      # quickly iterate while developing the config
      emacs-dev = pkgs.writeShellApplication {
        name = "emacs-dev";

        runtimeInputs = [
          emacs
        ];

        text = ''
          config_dir="''${EMACS_DEV_CONFIG:-$PWD/src}"

          if [[ ! -f "$config_dir/init.el" ]]; then
            echo "emacs-dev: $config_dir/init.el does not exist" >&2
            exit 1
          fi

          exec emacs \
            --init-directory "$config_dir" \
            "$@"
        '';
      };
    in
      pkgs.mkShell {
        name = "ouroboros-dev";
        packages = with pkgs; [
          nil
          statix
          deadnix
          alejandra
          emacs-dev
        ];
      };
  };
}
