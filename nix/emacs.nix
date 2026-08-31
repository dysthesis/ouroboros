{
  inputs,
  lib,
  ...
}: let
  defaultTreeSitterGrammars = [
    "tree-sitter-bash"
    "tree-sitter-c"
    "tree-sitter-cpp"
    "tree-sitter-css"
    "tree-sitter-dockerfile"
    "tree-sitter-go"
    "tree-sitter-gomod"
    "tree-sitter-html"
    "tree-sitter-java"
    "tree-sitter-javascript"
    "tree-sitter-json"
    "tree-sitter-markdown"
    "tree-sitter-markdown-inline"
    "tree-sitter-python"
    "tree-sitter-ruby"
    "tree-sitter-rust"
    "tree-sitter-toml"
    "tree-sitter-tsx"
    "tree-sitter-typescript"
    "tree-sitter-yaml"
  ];

  mkPkgs = {
    system,
    cpu ? null,
  }:
    import inputs.nixpkgs (
      {
        overlays = [inputs.emacs-overlay.overlay];
        config.allowUnfree = true;
      }
      // (
        if cpu == null
        then {inherit system;}
        else {
          localSystem = {
            inherit system;
            gcc.arch = cpu;
            gcc.tune = cpu;
          };
        }
      )
    );

  mkEmacs = {
    system,
    cpu ? null,
    grammars ? defaultTreeSitterGrammars,
  }:
    assert lib.assertMsg (
      cpu
      == null
      || (
        system
        == "x86_64-linux"
        && builtins.isString cpu
        && builtins.match "^[a-z0-9][a-z0-9._+-]*$" cpu != null
      )
    ) "CPU tuning requires x86_64-linux and a valid explicit GCC CPU name";
    assert lib.assertMsg (
      builtins.isList grammars && builtins.all builtins.isString grammars
    ) "grammars must be a list of tree-sitter grammar attribute names"; let
      pkgs = mkPkgs {inherit system cpu;};
      baseEmacs = pkgs.emacs-unstable-pgtk;
      emacs = baseEmacs.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + lib.optionalString (cpu != null) ''
            substituteInPlace lisp/emacs-lisp/comp.el \
              --replace-fail \
                "(defcustom native-comp-compiler-options nil" \
                "(defcustom native-comp-compiler-options '(\"-march=${cpu}\" \"-mtune=${cpu}\")"
          '';
      });
      epkgs = pkgs.emacsPackagesFor emacs;

      runtimePackages = with pkgs; [
        fd
        ripgrep
      ];

      sourceWithName = name: source:
        pkgs.runCommandLocal "ouroboros-${name}-source" {} ''
          mkdir -p "$out"
          cp ${source} "$out/${name}"
        '';

      modusAlabaster = epkgs.trivialBuild {
        pname = "modus-alabaster";
        version = "0.0.1-${inputs.modus-alabaster.shortRev}";
        src = inputs.modus-alabaster;
        packageRequires = [epkgs.modus-themes];
      };

      builtinUsePackage = pkgs.runCommandLocal "emacs-builtin-use-package" {} ''
        mkdir -p "$out"
      '';

      earlyDefault = epkgs.trivialBuild {
        pname = "ouroboros-early-default";
        version = "0";
        src = sourceWithName "early-default.el" ../src/early-init.el;
      };

      grammarBundle = epkgs.treesit-grammars.with-grammars (available:
        map (
          name:
            if builtins.hasAttr name available
            then builtins.getAttr name available
            else throw "Unknown Tree-sitter grammar `${name}`"
        ) (lib.unique grammars));

      wrapped = pkgs.emacsWithPackagesFromUsePackage {
        package = emacs;
        config = ../src/init.el;
        defaultInitFile = true;
        alwaysEnsure = true;
        override = _: _: {
          modus-alabaster = modusAlabaster;
          use-package = builtinUsePackage;
        };
        extraEmacsPackages = _:
          runtimePackages
          ++ [
            earlyDefault
            grammarBundle
          ];
      };
      default =
        lib.findFirst (
          package: (package.pname or null) == "default"
        ) (throw "The use-package wrapper did not produce default.el")
        wrapped.explicitRequires;
    in
      assert lib.assertMsg (baseEmacs.version == "31.1")
      "This package expects the pinned Emacs version to be 31.1";
        wrapped.overrideAttrs (old: {
          passthru =
            (old.passthru or {})
            // {
              inherit default earlyDefault grammarBundle grammars modusAlabaster;
              unwrappedEmacs = emacs;
              withCpu = target:
                mkEmacs {
                  inherit system grammars;
                  cpu = target;
                };
              withGrammars = selected:
                mkEmacs {
                  inherit system cpu;
                  grammars = selected;
                };
            };
        });
in {
  flake.lib = {
    inherit defaultTreeSitterGrammars mkEmacs;
  };

  perSystem = {system, ...}: let
    pkgs = mkPkgs {inherit system;};
    emacs = pkgs.emacs-unstable-pgtk;
    ouroboros = mkEmacs {inherit system;};
  in {
    _module.args = {inherit pkgs emacs;};

    packages =
      {default = ouroboros;}
      // lib.optionalAttrs (system == "x86_64-linux") {
        znver3 = mkEmacs {
          inherit system;
          cpu = "znver3";
        };
      };
  };
}
