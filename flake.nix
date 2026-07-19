{
  description = "A flake for the Pumble desktop messaging application";

  inputs = {
    # Using unstable as Electron apps usually need the latest dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Allows you to run or build the package directly from this folder
      packages.${system} = {
        pumble = pkgs.callPackage ./pumble.nix { };
        default = self.packages.${system}.pumble;
      };

      # An overlay makes it simple to inject Pumble directly into your system-wide pkgs
      overlays.default = final: prev: {
        pumble = final.callPackage ./pumble.nix { };
      };
    };
}
