self: super:

let
  callWith = world: f:
    f (builtins.intersectAttrs (builtins.functionArgs f) world);
  callPathWith = world: path: callWith world (import path);
in {
  emacs29X = super.emacs29.override { withGTK3 = false; };
  emacs29XPackages =
    super.dontRecurseIntoAttrs (super.emacsPackagesFor self.emacs29X);
  emacs29XWithPackages = self.emacs29XPackages.emacsWithPackages;

  groundmacs = callPathWith self ../pkgs/groundmacs.nix;

  terminfo-24bit = callPathWith super ../pkgs/terminfo-24bit.nix;

  nodeEnv = callPathWith super ../pkgs/smfgen/node-env.nix;

  smfgen = (callPathWith self ../pkgs/smfgen/node-packages.nix).smfgen;

}
