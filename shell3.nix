{ pkgs ? import <nixpkgs> {} }:
pkgs.buildFHSUserEnv {
  name = "pipzone"; # choose your own name
  targetPkgs = pkgs: (with pkgs; [
    python311Full # Preferable choose version with Full postfix, e.g. python311Full
    python39Packages.pip
    python39Packages.virtualen
  ]);
  multiPkgs = pkgs: with pkgs; [ # choose your libraries
    libgcc
    binutils
    coreutils
  ];
  # exporting LIBRARY_PATH is essential so the libraries get found!
  profile = ''
    export LIBRARY_PATH=/usr/lib:/usr/lib64:$LIBRARY_PATH
    # export LIBRARY_PATH=${pkgs.libgcc}/lib # somethingl like this may also be necessary for certain libraries (change to your library e.g. pkgs.coreutils
  '';
  runScript = "bash";
}
pkgs.mkShell {
            # The Nix packages provided in the environment
            packages = [
              pkgs.rocmPackages.rpp
              pkgs.rocmPackages.clr
              pkgs.rocmPackages.hipcc
              pkgs.rocmPackages.rocm-smi 
              pkgs.zlib
              pkgs.zstd
              pkgs.gcc
              pkgs.glibc
              pkgs.python311
              pkgs.python311Packages.pip
              pkgs.python311Packages.tkinter
              pkgs.python311Packages.numpy
              pkgs.stdenv.cc.cc.lib
              # Whatever other packages are required
            ];
            #
            buildInputs = with pkgs; [
              python311
              zstd
            ];
            nativeBuildInputs = with pkgs; [
              stdenv.cc.cc.lib
            ];
            shellHook = ''
              python3.11 -m venv .venv
              source .venv/bin/activate
              pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/test/rocm6.1
              pip install -r requirements2.txt
            '';
}
