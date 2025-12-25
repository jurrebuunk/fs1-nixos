{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    copyparty.url = "github:9001/copyparty";
  };

  outputs = { self, nixpkgs, copyparty, ... }@inputs: {
    nixosConfigurations.nixos-server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        copyparty.nixosModules.default
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ copyparty.overlays.default ];
        })
      ];
    };
  };
}
