{
  description = "Mydia development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Elixir and Erlang
            elixir_1_16
            erlang_26

            # Node.js for assets
            nodejs_20

            # SQLite
            sqlite

            # Build tools
            gcc
            gnumake
            git

            # Phoenix live reload (inotify)
            inotify-tools

            # Hex and Rebar (Elixir package managers)
            # These will be installed via mix
          ];

          shellHook = ''
            # Set up local hex and rebar
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export PATH=$MIX_HOME/bin:$PATH
            export PATH=$MIX_HOME/escripts:$PATH

            # Ensure mix is available
            mix local.hex --force --if-missing
            mix local.rebar --force --if-missing

            echo "🚀 Mydia development environment loaded"
            echo "Elixir version: $(elixir --version | head -1)"
            echo "Node version: $(node --version)"
            echo "SQLite version: $(sqlite3 --version)"
          '';
        };
      }
    );
}
