{ pkgs, dhall-vmadm }: {
  dhall-vmadm = let
    dhallImports = ''
      { dhall-vmadm = ${dhall-vmadm}/binary.dhall
      , Prelude = ${pkgs.dhallPackages.Prelude}/binary.dhall
      }
    '';
  in pkgs.mkShell {
    DHALL_RESOLVER = "${pkgs.writeText "dhall-resolver-vmadm" dhallImports}";
    shellHook = ''
      for f in "${dhall-vmadm}/.cache/dhall"/* "${pkgs.dhallPackages.Prelude}/.cache/dhall"/*; do
        hash=$(basename $f)
        dest=''${XDG_CACHE_HOME:-''${HOME}/.cache}/dhall/$hash
        if [ ! -e $dest ]; then
          ln -s $f $dest
        fi
      done
    '';
  };

  dhall-vmadm2 = let
    dhallImports = ''
      { dhall-vmadm = ${dhall-vmadm}/binary.dhall
      , Prelude = ${pkgs.dhallPackages.Prelude}/binary.dhall
      }
    '';
  in pkgs.mkShell {
    packages = [ pkgs.dhall pkgs.dhall-json ];
    DHALL_RESOLVER = "${pkgs.writeText "dhall-resolver-vmadm" dhallImports}";
    shellHook = ''
      for f in "${dhall-vmadm}/.cache/dhall"/* "${pkgs.dhallPackages.Prelude}/.cache/dhall"/*; do
        hash=$(basename $f)
        dest=''${XDG_CACHE_HOME:-''${HOME}/.cache}/dhall/$hash
        if [ ! -e $dest ]; then
          ln -s $f $dest
        fi
      done
      echo "${
        pkgs.writeText "dhall-resolver-vmadm" dhallImports
      }" > .imports.dhall
    '';
  };
}
