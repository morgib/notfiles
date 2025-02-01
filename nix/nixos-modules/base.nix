{ pkgs, ... }: {
  nix.package = pkgs.nixVersions.latest;
  nix.extraOptions = "experimental-features = nix-command flakes";
  environment.systemPackages = with pkgs; [ git vim htop ];
  time.timeZone = "America/Los_Angeles";
}

