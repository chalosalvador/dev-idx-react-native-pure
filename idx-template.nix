{ pkgs, packageManager ? "npm", ... }: {
  packages = [
    pkgs.nodejs_20
    pkgs.yarn
    pkgs.jq
  ];
  bootstrap = ''
    mkdir -p "$WS_NAME"
    ${if packageManager == "yarn" 
      then ''
        cd "$WS_NAME"
        yarn init -y
        yarn add @react-native-community/cli
        yarn react-native init . --template react-native-template-typescript
        cd ..
      ''
      else ''
        cd "$WS_NAME"
        npm init -y
        npm install @react-native-community/cli
        npx react-native init . --template react-native-template-typescript
        cd ..
      ''
    }
    
    mkdir "$WS_NAME/.idx/"
    packageManager=${packageManager} j2 ${./devNix.j2} -o "$WS_NAME/.idx/dev.nix"
    nixfmt "$WS_NAME/.idx/dev.nix"
    packageManager=${packageManager} j2 ${./README.j2} -o "$WS_NAME/README.md"
    
    chmod -R +w "$WS_NAME"
    mv "$WS_NAME" "$out"
  '';
}
