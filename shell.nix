let
  localLib = import ./lib.nix;
in
{ system ? builtins.currentSystem
, config ? {}
, pkgs ? (import (localLib.fetchNixPkgs) { inherit system config; })
}:

with pkgs;

let
  pachyderm_private = callPackage ./pachyderm.nix{};
  # docker_egs = callPackage ./test-transform/examples.nix{};
in
stdenv.mkDerivation {
  name = "azplay";

  buildInputs = [
    nix bash binutils coreutils curl gnutar
    gnumake
    pachyderm_private
    kubectl
    google-cloud-sdk
    git
    openssh
    imagemagick
    vault
    # docker_egs
  ];
}
