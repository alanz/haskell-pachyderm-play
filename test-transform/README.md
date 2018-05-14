## Experiment with creating a docker image that can be used in pachyderm

This should be written in haskell, and constructed using nix

Based on https://github.com/Gabriel439/haskell-nix/tree/master/project3

## Create haskell project

- simple.cabal
- SimpleMain.hs
- LICENSE

Create a nix file for it

```bash
$ nix-env -i cabal2nix
$ cabal2nix . > default.nix
```

The file `release.nix` is based on
https://github.com/Gabriel439/haskell-nix/blob/master/project3/release2.nix

It builds the `simple.cabal` project, and constructs a docker image
with the exe from it.

```bash
$ nix-build release.nix
$ docker load < result
..
Loaded image: simple-container:latest
```

Upload it

```
$ docker push alanz/simple-container
```

## Make pachyderm capable project

This is a docker container that needs to

 - process input from `/pfs/somedir` (Where `somedir` is in the pipeline spec)
 - generate output into `/pfs/out/`
 - accept an external command when running the container

Provided the docker image is named correctly, it can be uploaded to a registry.

This allows


```bash
nix-build release.nix
docker load < result
docker push alanz/simple-container
```
