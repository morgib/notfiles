{ lib, stdenv, writeTextFile, symlinkJoin, coreutils } :

{ name          # derivation name
, emacs         # emacs derivation to wrap
, userDir       # emacs user directory to set (shell vars such as $HOME will be expanded)
}:
let
  wrapScript = wrapPath: login: ''
  #!${stdenv.shell} ${if login then "--login" else ""}

  # You can never be too careful
  set -e

  EMACS_USER_DIRECTORY="${userDir}"
  if [ ! -d "''${EMACS_USER_DIRECTORY}" ]; then
      mkdir -p "''${EMACS_USER_DIRECTORY}"
  fi

  EMACS_USER_DIRECTORY=$(${coreutils}/bin/realpath "''${EMACS_USER_DIRECTORY}")

  if [ ! -f "''${EMACS_USER_DIRECTORY}/init.el" ]; then
      touch "''${EMACS_USER_DIRECTORY}/init.el"
  fi


  # Bootstrap directory
  BOOTSTRAP=$(${coreutils}/bin/mktemp --directory --tmpdir .emacs-bootstrap.XXXXXX)
  mkdir "''${BOOTSTRAP}/.emacs.d"

  # Bootstrap init file
  cat >"''${BOOTSTRAP}/.emacs.d/init.el" <<EOF
      ;; # Correctly set-up emacs-user-directory
      (setq user-emacs-directory "''${EMACS_USER_DIRECTORY}/")
      (setq user-init-file (concat user-emacs-directory "init.el"))

      ;; # Reset the HOME environment variable
      (setenv "HOME" "''${HOME}")

      ;; # Load the real init file and clean-up afterwards
      (unwind-protect (load user-init-file)
      (delete-directory "''${BOOTSTRAP}" :recursive))
  EOF

  # Forward remaining arguments to emacs
  exec env \
      HOME="''${BOOTSTRAP}" \
      ${emacs}${wrapPath} "$@"
  '';
  writeWrapper = { login ? false }: wrapPath:
    writeTextFile {
        name = "${baseNameOf wrapPath}";
        text = wrapScript wrapPath login;
        executable = true;
        destination = wrapPath;
    };

in
symlinkJoin {
  inherit name;
  paths = lib.optional stdenv.isDarwin
    (writeWrapper { login = true; } "/Applications/Emacs.app/Contents/MacOS/Emacs")
    ++ [ (writeWrapper {} "/bin/emacs")
         (writeWrapper {} "/bin/emacs-27.2")
         emacs
       ];
}

