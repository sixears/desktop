# see ../desktop.nix for which nixpkgs is used
{ nixpkgs ? import ../support/nixpkgs.nix {} }:

with nixpkgs;

let # _2022_06_29 = import /nix/var/nixpkgs/nixos-22.05.2022-06-29.be6da377 {};

    # v1.33.0;
    # signal-desktop = _2022_10_15.signal-desktop;

    # https://vlc-bluray.whoknowsmy.name/
    # https://github.com/NixOS/nixpkgs/issues/63641
    # https://wiki.archlinux.org/index.php/Blu-ray
    # http://fvonline-db.bplaced.net/
    libbluray = nixpkgs.libbluray.override { withAACS   = true;
                                             withBDplus = true;
                                           };
 in
{
  inherit youtube-dl;
  inherit signal-desktop zoom-us;
  inherit mua;

  # browsers
  inherit firefox chromium;

  # media
  inherit audacity audacious evince ffmpeg gqview handbrake shntool makemkv;
  vlc = pkgs.vlc.override { inherit libbluray; };

  # office
  inherit libreoffice gnumeric;

  # music
  inherit lilypond musescore;

  inherit psutils;
  # pandoc
  inherit pandoc;
  # for pdflatex
  # reduce priority (which means, increase the number...); such that psutils'
  # tools take precedence over texlive.
#  scheme-small =
#    let override = old: { meta = old.meta // { priority = 7; }; };
#     in texlive.combined.scheme-small.overrideAttrs(override);

  chrysalis  = import ../../pkgs/chrysalis  { inherit nixpkgs; };
}
