/*
 * Hook direnv to the Bash shell with:
 *
 *  eval "$(direnv hook bash)"
 *  direnv allow
 */
{
  description = "Shell script development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }: let
    # Overlays enable you to customize the Nixpkgs attribute set
    overlays = [
      (self: super:
        let jdk = super.openjdk17; in
        # sets jre/jdk overrides that use the openjdk17 package
        {
          jre = jdk;
          inherit jdk;
        })
    ];

    # Systems supported
    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    # Helper to provide system-specific attributes
    forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
      pkgs = import nixpkgs { inherit overlays system; };
    });
  in
  {
    # Development environment output
    devShells = forAllSystems ({ pkgs }: {

      default = pkgs.mkShell {

        name = "script-dev-shell";

        # The Nix packages provided in the environment
        packages = with pkgs; [
          # Uses the JRE/JDK version set up by the overlay.
          glibc
          jdk
          shunit2
        ];

        shellHook = ''
          export JAVA_HOME="${pkgs.jre}"
          JAVA_HOME="${pkgs.jdk}"
          export M2_HOME="${pkgs.maven}"
          export SCALA_HOME="${pkgs.dotty}"
        '';
      };
    });
  };
}
