{ pkgs, packageManager ? "npm", ... }: {
  packages = [
    pkgs.nodejs_20
    pkgs.yarn
    pkgs.jq
    pkgs.j2cli
    pkgs.nixfmt
  ];
  bootstrap = ''
    # Validate workspace name: React Native CLI init does not allow hyphens.
    if [[ "$WS_NAME" == *-* ]]; then
      echo "[ERROR] Workspace name '$WS_NAME' contains hyphens, which are not allowed by 'react-native init'. Please use only alphanumeric characters or underscores." >&2
      exit 1
    fi

    # If validation passes, proceed with setup using the original WS_NAME
    mkdir -p "$WS_NAME"
    
    # Initialize the project using npx directly
    npx -y @react-native-community/cli init "$WS_NAME" --skip-install
    
    mkdir "$WS_NAME/.idx/"
    packageManager=${packageManager} j2 ${./devNix.j2} -o "$WS_NAME/.idx/dev.nix"
    nixfmt "$WS_NAME/.idx/dev.nix"
    packageManager=${packageManager} j2 ${./README.j2} -o "$WS_NAME/README.md"
    
    chmod -R +w "$WS_NAME"
    mv "$WS_NAME" "$out"
  '';
}
