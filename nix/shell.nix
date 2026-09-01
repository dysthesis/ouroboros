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
          pkgs.glib
          pkgs.gsettings-desktop-schemas
        ];

        runtimeEnv.GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-50.1/glib-2.0/schemas";
        text = ''
          config_dir="''${EMACS_DEV_CONFIG:-$PWD/src}"
          gsettings list-schemas | grep -x org.gnome.desktop.interface
          gsettings set org.gnome.desktop.interface font-hinting 'slight'
          gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
          settings get org.gnome.desktop.interface font-hinting
          gsettings get org.gnome.desktop.interface font-antialiasing
          gsettings get org.gnome.desktop.interface font-rgba-order
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
