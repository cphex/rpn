{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self, nixpkgs, flake-parts, ... }:
    let
      name = "rpn";
      pname = "rpn";
      version = "0.0.1";
      src = ./.;
    in flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { lib, config, self', inputs', pkgs, system, ... }:
        let
          tailwindCss = pkgs.tailwindcss_4;
          beam_pkgs = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_28;
          elixir = beam_pkgs.elixir_1_18;
        in {
          devShells = rec {
            ci = lib.makeOverridable pkgs.mkShell {
              packages = [
                pkgs.just
                elixir
                beam_pkgs.erlang
                pkgs.nodejs
                pkgs.typescript
                pkgs.eslint
                pkgs.nodePackages.prettier

                # make and gcc is needed to build bcrypt_elixir
                pkgs.gnumake
                pkgs.gcc

                # coreutils are probably also needed in a very tight environment
                pkgs.coreutils
              ];

              LANG = "C.UTF-8";
              # It seems like `glibcLocales` is not available on mac. Therefore,
              # we only set this environment variable on Linux.

              LOCALE_ARCHIVE = if pkgs.stdenv.isLinux then
                "${pkgs.glibcLocales}/lib/locale/locale-archive"
              else
                null;

              MIX_PATH = "${beam_pkgs.hex}/lib/erlang/lib/hex/ebin";
              MIX_TAILWIND_PATH = "${tailwindCss}/bin/tailwindcss";
              MIX_ESBUILD_PATH = "${pkgs.esbuild}/bin/esbuild";
            };

            default = ci.override (oldAttrs: {
              packages =
                (if pkgs.stdenv.isLinux then [ pkgs.inotify-tools ] else [ ])
                ++ oldAttrs.packages
                ++ [
                  pkgs.node2nix
                  pkgs.sqlite
                  pkgs.mix2nix
                  tailwindCss
                  pkgs.esbuild
                  (beam_pkgs.elixir-ls.override { elixir = elixir; })
                ];
              ERL_AFLAGS = "-kernel shell_history enabled";
            });
          };
        };
      flake = {
        # add nixosConfigurations for vms, etc, here
      };
    };
}
