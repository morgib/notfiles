{ runCommand }:

file:

runCommand "default.el" {} ''
  mkdir -p $out/share/emacs/site-lisp
  cp ${file} $out/share/emacs/site-lisp/default.el
  ''
