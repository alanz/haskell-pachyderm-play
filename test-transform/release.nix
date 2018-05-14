let
  config = rec {
    packageOverrides = pkgs: rec {

      docker-container-small = pkgs.dockerTools.buildImage {
        name = "alanz/simple-container";
        fromImage = pkgs.dockerTools.pullImage {
              imageName = "ubuntu";
              imageDigest = "sha256:1dfb94f13f5c181756b2ed7f174825029aca902c78d0490590b1aaa203abc052";
              sha256 = "08qsffa3g2a9m2apr8w4vrms3q0r5l745mbj94b1cgka6z7ds1i6";
        };

        contents =
          [
          haskellPackages.simple-minimal
          ];
        config = {
          Env = [ "PATH=${haskellPackages.simple-minimal}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
                ];
        };
      };

      haskellPackages = pkgs.haskellPackages.override {
        overrides = haskellPackagesNew: haskellPackgesOld: rec {
          simple = haskellPackagesNew.callPackage ./default.nix {};

          simple-minimal =
            pkgs.haskell.lib.overrideCabal
              ( pkgs.haskell.lib.justStaticExecutables
                  ( haskellPackagesNew.callPackage ./default.nix {
                    }
                  )
              )
              ( oldDerivation: {
                  testToolDepends = [ pkgs.libarchive ];
                }
              );
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; system = "x86_64-linux"; };

in
  {
    docker-container-small = pkgs.docker-container-small;
  }
