# devenv.nix
{ pkgs, lib, config, inputs, ... }:
{
  languages.python = {
    enable = true;
    venv.enable = true;
    venv.requirements = ''
      epub2txt
      TTS
      torch
      Tkinter
    '';
  };

  enterShell = ''
    python converter.py
  '';
}
