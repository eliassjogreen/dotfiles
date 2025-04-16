{
  description = "A flake that provides the Zed Plex Mono font";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          version = "v0.181.8";
          directory = "assets/fonts/plex-mono";
          zedPlexMono = pkgs.stdenv.mkDerivation {
            pname = "Zed Plex Mono";
            version = version;
            src = pkgs.fetchgit {
              url = "https://github.com/zed-industries/zed.git";
              rev = "refs/tags/${version}";
              sha256 = "sha256-gkbiV0kfeM1Ito8jVOBVneNjaXCA4PFayXJLIUmjqn4=";
              sparseCheckout = [ directory ];
            };
            phases = [ "installPhase" ];
            installPhase = ''
              mkdir -p "$out/share/fonts/truetype"
              find "$src/${directory}" -name "*.ttf" -exec cp {} "$out/share/fonts/truetype/" \;
            '';
            meta = with pkgs.lib; {
              license = licenses.ofl;
              platforms = platforms.all;
            };
          };
        in
        {
          default = zedPlexMono;
        }
      );
    };
}
