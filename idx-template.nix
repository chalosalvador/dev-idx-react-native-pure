{ pkgs, packageManager ? "npm", ... }: {
  packages = [
    pkgs.nodejs_20
    pkgs.yarn
    pkgs.jq
    pkgs.j2cli
    pkgs.nixfmt
  ];
  bootstrap = ''
    mkdir -p "$WS_NAME"

		# Replace hyphens with underscores for the project name
    PROJECT_NAME="''${WS_NAME//-/_}"

    # Initialize the project using the sanitized name
    npx -y @react-native-community/cli init "$PROJECT_NAME" --skip-install
    
    mkdir "$WS_NAME/.idx/"
    packageManager=${packageManager} j2 ${./devNix.j2} -o "$WS_NAME/.idx/dev.nix"
    nixfmt "$WS_NAME/.idx/dev.nix"
    packageManager=${packageManager} j2 ${./README.j2} -o "$WS_NAME/README.md"
    
    chmod -R +w "$WS_NAME"
    mv "$WS_NAME" "$out"
  '';
}
