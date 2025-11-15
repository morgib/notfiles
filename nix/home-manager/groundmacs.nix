{ pkgs, ... }: {
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    cacert
    terminfo-24bit
    mosh
    hunspell
    hunspellDicts.en-us
    (texlive.combine {
      inherit (texlive) scheme-medium wrapfig capt-of cm-super;
    })
    coreutils
    gnugrep
    #cachix
    tree
    nixfmt-rfc-style
    jq
    smfgen
    file
    dnsutils
    xsel
    entr
    whois
    evince
    nodePackages.bash-language-server
    shellcheck
    shfmt
    bashInteractive
    nixpkgs-fmt
    pandoc
  ];

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      set -o vi
      export EDITOR="emacsclient -t -a vim"
      PS1='\u@\h:\w$ '
    '';
    profileExtra = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi

      brew=/opt/homebrew/bin/brew
      if [ -f "$brew" ] && [ -x "$brew" ] ; then
        eval "$("$brew" shellenv)"
      fi 
    '';
    shellAliases = { e = "emacsclient -t -a vim"; ls = "ls --color=auto"; };
    sessionVariables = { EDITOR = "emacsclient -t -a vim"; };
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      set -o vi
      export EDITOR="emacsclient -t -a vim"
      setopt interactive_comments
    '';
    shellAliases = { e = "emacsclient -t -a vim"; };
    sessionVariables = { EDITOR = "emacsclient -t -a vim"; };
  };

  programs.dircolors.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    package = pkgs.direnv.overrideAttrs(old: { doCheck = false; });
  };
  
  programs.emacs = {
    enable = true;
    package = pkgs.groundmacs;
  };

  services.emacs = {
    enable = false;
    package = pkgs.groundmacs;
  };

  home.file.emacs-init = {
    source = ../../emacs/init-babel.el;
    target = ".emacs.d/init.el";
  };

  programs.git = {
    enable = true;
    settings.user = {
      email = "git@morgib.com";
      name = "Morgan Gibson";
    };
  };
  
  programs.tmux = {
    enable = true;
    escapeTime = 0;
    terminal = "tmux-256color";
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = {}
      
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end
      
      config.font = wezterm.font("IBM Plex Mono")
      config.font_size = 15.0
      config.color_scheme = "Gruvbox Dark (Gogh)"
      config.hide_tab_bar_if_only_one_tab = true
      config.default_prog = { "/Users/morgib/.nix-profile/bin/bash", "--login" }
      
      return config
   '';
  };
}
