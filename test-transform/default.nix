{ mkDerivation, base, directory, stdenv }:
mkDerivation {
  pname = "simple";
  version = "1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base directory ];
  license = stdenv.lib.licenses.bsd3;
}
