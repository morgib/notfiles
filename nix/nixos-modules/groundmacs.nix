{ pkgs, ...}:

{
environment.systemPackages = with pkgs; [ groundmacs ];
programs.tmux.enable = true;
programs.tmux.extraConfig = ''
  source-file ${pkgs.terminfo-24bit}/etc/tmux.d/*
  set -s escape-time 0
  '';
environment.shellInit = ''
  if [ -d ${pkgs.terminfo-24bit}/etc/profile.d ]; then
  for i in ${pkgs.terminfo-24bit}/etc/profile.d/*; do
      if [ -r $i ]; then
      . $i
      fi
  done
  unset i

  export TERMINFO_DIRS="${pkgs.wezterm.terminfo}/share/terminfo:$TERMINFO_DIRS"
  fi
  '';

  
}
