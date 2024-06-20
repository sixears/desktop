{
  description = "Packages for a fully usable linux desktop";

  inputs = {
    nixpkgs.url     = github:NixOS/nixpkgs/938aa157; # nixos-24.05 2024-06-20
    mixpkgs.url     = github:NixOS/nixpkgs/938aa157; # nixos-24.05 2024-06-20
    flake-utils.url = github:numtide/flake-utils/c0e246b9;
    hpkgs1.url      = github:sixears/hpkgs1/r0.0.23.0;
#    hpkgs1.url      = "/home/martyn/src/hpkgs1";
  };

  outputs = { self, nixpkgs, mixpkgs, flake-utils, hpkgs1 }:
    flake-utils.lib.eachSystem [flake-utils.lib.system.x86_64-linux] (system:
      let
        super = nixpkgs.legacyPackages.${system};
        unfrees = [ "makemkv" "zoom" ];
        allowUnfreePredicate =
          pkg: builtins.elem (super.lib.getName pkg) unfrees;
        pkgs =
          import "${nixpkgs}" { config = { inherit allowUnfreePredicate; };
                                inherit system;
                              };
        mkgs =
          import mixpkgs { config = { inherit allowUnfreePredicate; };
                           inherit system;
                         };
        hpkgs = hpkgs1.packages.${system};
      in
        rec {
          defaultPackage = pkgs.ocaml;

          packages = with pkgs; flake-utils.lib.flattenTree {

            inherit (mkgs) signal-desktop zoom-us;
            claws-mail = claws-mail.override {
              enablePluginPdf   = true;
              enablePgp         = true;
            };

            # browsers
            inherit (mkgs) firefox chromium;

            # media
            inherit (mkgs) audacity;
            inherit audacious evince ffmpeg gqview handbrake shntool;

            ## video
            vlc = pkgs.vlc.override { inherit libbluray; };
            inherit (mkgs) makemkv;
            losslesscut = losslesscut-bin;

            # keyboardIO
            inherit chrysalis;

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
            # currently, this doesn't work with flakes
            # https://discourse.nixos.org/t/declarative-priorities-for-flakes/23008
         #  scheme-small = let override = old: { meta = old.meta // { priority = 7; }; }; in texlive.combined.scheme-small.overrideAttrs(override);
            # priorities not yet supported in flakes in nixos-22.05 .
            # see https://github.com/NixOS/nix/pull/6522/commits/27d0f6747d7e70be4b9ade28ce77444e6135cadb

            # I'm hoping that texliveTeTex supercedes this
            # scheme-small = pkgs.texlive.combined.scheme-small;
            # inherit (pkgs.texlive.combined) scheme-small;

            # needed for multi-column output of pandoc, specifically
            # multirow.sty
            # see
            # https://levelup.gitconnected.com/use-columns-adjust-margins-and-do-more-in-markdown-with-these-simple-pandoc-commands-adb4c19f9f35
            inherit (mkgs) texliveTeTeX;

          ##  chrysalis  = import ../../pkgs/chrysalis  { inherit nixpkgs; };
          #            scheme-small =
          #              let
          #                override = old: { meta = old.meta // { priority = 7; }; };
          #              in
          #                pkgs.texlive.combined.scheme-small.overrideAttrs(override);
            inherit (hpkgs) acct;
          };
        }
    );
}
