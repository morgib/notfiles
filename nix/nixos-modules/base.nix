{ pkgs, ... }: {
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";
  environment.systemPackages = with pkgs; [ git vim htop ];
  time.timeZone = "America/Los_Angeles";
}

