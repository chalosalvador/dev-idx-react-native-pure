{ pkgs, packageManager ? "npm", ... }: {
  packages = [
    pkgs.nodejs_20
    pkgs.yarn
    pkgs.jq
  ];
  bootstrap = ''
    mkdir -p "$WS_NAME"
    ${if packageManager == "yarn" 
      then "yarn create react-native-app \"$WS_NAME\" --template typescript" 
      else "npx react-native@latest init \"$WS_NAME\" --template react-native"
    }
    
    mkdir "$WS_NAME/.idx/"
    packageManager=${packageManager} j2 ${./devNix.j2} -o "$WS_NAME/.idx/dev.nix"
    nixfmt "$WS_NAME/.idx/dev.nix"
    packageManager=${packageManager} j2 ${./README.j2} -o "$WS_NAME/README.md"
    
    chmod -R +w "$WS_NAME"
    mv "$WS_NAME" "$out"
  '';
}
