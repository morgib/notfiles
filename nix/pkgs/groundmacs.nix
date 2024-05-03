let

  selectPackages = epkgs:
    with epkgs.melpaPackages; [
      use-package
      evil
      color-theme-sanityinc-solarized
      company
      helm
      helm-org
      #epkgs.elpaPackages.org
      evil-org
      evil-collection
      which-key
      general
      epkgs.elpaPackages.delight
      # zoom-frm # need to build this from the emacs wiki
      nix-mode
      ledger-mode
      projectile
      magit
      #evil-magit
      forge
      dtrace-script-mode
      ob-async
      org-babel-eval-in-repl
      eval-in-repl
      direnv
      ox-hugo
      haskell-mode
      dhall-mode
      neotree
      lsp-mode
      lsp-ui
      lsp-haskell
      flycheck
      yasnippet
      helm-lsp
      ormolu
      format-all
      ob-tmux
      emamux
      epkgs.elpaPackages.xclip
      epkgs.elpaPackages.undo-tree
      epkgs.elpaPackages.auctex
      evil-terminal-cursor-changer
      powershell
      json-mode
      ox-pandoc
    ];

in { emacs29XWithPackages, ... }:

emacs29XWithPackages selectPackages
