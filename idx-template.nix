{ pkgs, packageManager ? "npm", ... }: {
  packages = [
    pkgs.nodejs_20
    pkgs.yarn
    pkgs.jq
    pkgs.j2cli
    pkgs.nixfmt
  ];
  bootstrap = ''
	# Replace hyphens with underscores for the project name
    SANITIZED_PROJECT_NAME="''${WS_NAME//-/_}"

    # Inform user if sanitization occurred
    if [ "$SANITIZED_PROJECT_NAME" != "$WS_NAME" ]; then
      echo "[INFO] Workspace name '$WS_NAME' sanitized to '$SANITIZED_PROJECT_NAME' for React Native project initialization." >&2
    fi

    mkdir -p "$SANITIZED_PROJECT_NAME"

    # Initialize the project using the sanitized name
    npx -y @react-native-community/cli init "$SANITIZED_PROJECT_NAME" --skip-install
    
    mkdir "$SANITIZED_PROJECT_NAME/.idx/"
    packageManager=${packageManager} j2 ${./devNix.j2} -o "$SANITIZED_PROJECT_NAME/.idx/dev.nix"
    nixfmt "$SANITIZED_PROJECT_NAME/.idx/dev.nix"
    packageManager=${packageManager} j2 ${./README.j2} -o "$SANITIZED_PROJECT_NAME/README.md"
    
    chmod -R +w "$SANITIZED_PROJECT_NAME"
    mv "$SANITIZED_PROJECT_NAME" "$out"
  '';
}
