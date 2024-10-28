# shell.nix
{ pkgs ? import <nixpkgs> {} }:
(pkgs.buildFHSUserEnv {
  name = "pipzone"; # choose your own name
  targetPkgs = pkgs: (with pkgs; [
    rocmPackages.rpp
    rocmPackages.clr
    rocmPackages.hipcc
    rocmPackages.rocm-smi
    python311Full # Preferable choose version with Full postfix, e.g. python311Full
    python311Packages.pip
    python311Packages.virtualenv
    python311Packages.tkinter
  ]);
  multiPkgs = pkgs: with pkgs; [ # choose your libraries
    gcc
    binutils
    coreutils
    zstd
    zlib
    glibc
  ];
  # exporting LIBRARY_PATH is essential so the libraries get found!
  profile = ''
    export PYTORCH_ROCM_ARCH="gfx1030"
    export AMDGPU_TARGETS="gfx1030"
    export GPU_TARGETS="gfx1030"
    export HSA_OVERRIDE_GFX_VERSION=10.3.0
    python3.11 -m venv .venv
    source .venv/bin/activate
    pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/test/rocm6.1
    pip install -r requirements2.txt
    export LIBRARY_PATH=/usr/lib:/usr/lib64:$LIBRARY_PATH
    # export LIBRARY_PATH=${pkgs.libgcc}/lib # somethingl like this may also be necessary for certain libraries (change to your library e.g. pkgs.coreutils
    #python convertertemp.py 2> error.log
  '';
  runScript = "bash";
}).env
