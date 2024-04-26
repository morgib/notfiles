{ runCommand, ncurses }:

runCommand "terminfo-24bit" {
    nativeBuildInputs = [ ncurses ];
  }
  ''
  mkdir -p $out/share/terminfo
  ${ncurses}/bin/tic -x -o $out/share/terminfo - <<EOF
  xterm-256color-bak|Original xterm-256color definition,
      use=xterm-256color,
  xterm-256color|xterm with 24-bit direct color mode,
      use=xterm-256color,
      sitm=\E[3m,
      ritm=\E[23m,
      setb24=\E[48;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
      setf24=\E[38;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
  screen-bak|Original screen definition,
      use=screen,
  screen|screen with 24-bit direct color mode for tmux,
      use=screen-256color,
      sitm=\E[3m,
      ritm=\E[23m,
      setb24=\E[48;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
      setf24=\E[38;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
  tmux-24bit|tmux with 24-bit direct color mode for tmux,
      use=tmux,
      sitm=\E[3m,
      ritm=\E[23m,
      rmso=\E[27m, smso=\E[7m, Ms@,
      setb24=\E[48;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
      setf24=\E[38;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
      Cr=\E]112\007, Cs=\E]12;%p1%s\007, Ms=\E]52;%p1%s;%p2%s\007, Se=\E[2\sq,
      Ss=\E[%p1%d\sq,
  EOF
  # TODO: minimize the changes here...
  
  mkdir -p $out/etc/profile.d/
  cat > $out/etc/profile.d/50-set-terminfo-dirs <<EOF
  export TERMINFO_DIRS="$out/share/terminfo:${ncurses}/share/terminfo"
  EOF
  
  mkdir -p $out/etc/tmux.d/
  cat > $out/etc/tmux.d/50-set-truecolor <<EOF
  set-option -ga terminal-overrides ',xterm-256color:Tc'
  set-option -g default-terminal 'tmux-24bit'
  EOF
  ''
