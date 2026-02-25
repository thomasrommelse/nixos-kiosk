{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  #####################################
  # Allow unfree packages
  #####################################
  nixpkgs.config.allowUnfree = true;

  #####################################
  # Bootloader (UEFI)
  #####################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #####################################
  # Basic system settings
  #####################################
  networking.hostName = "tv-dashboard-1";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  #####################################
  # X11 + Display
  #####################################
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kiosk";

  services.xserver.windowManager.openbox.enable = true;

  #####################################
  # Disable screen blanking
  #####################################
  services.xserver.displayManager.sessionCommands = ''
    xset -dpms
    xset s off
    xset s noblank
  '';

  #####################################
  # Users
  #####################################
  users.users.kiosk = {
    isNormalUser = true;
    description = "Kiosk User";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

#####################################
# RustDesk (AppImage, simple method)
#####################################

environment.systemPackages = with pkgs; [
  chromium
  git
  curl

  (pkgs.stdenv.mkDerivation {
    pname = "rustdesk";
    version = "1.2.3";

    src = pkgs.fetchurl {
      url = "https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-x86_64.AppImage";
      sha256 = pkgs.lib.fakeSha256;
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/rustdesk
      chmod +x $out/bin/rustdesk
    '';
  })
];

#####################################
# Kiosk browser (stable version)
#####################################
systemd.user.services.kiosk-browser = {
  description = "Chromium Kiosk Browser";
  wantedBy = [ "graphical-session.target" ];

  serviceConfig = {
    ExecStartPre = ''
      ${pkgs.coreutils}/bin/sleep 8
    '';

    ExecStart = ''
    ${pkgs.chromium}/bin/chromium \
        --kiosk \
        --noerrdialogs \
        --disable-infobars \
        --user-data-dir=/home/kiosk/.config/chromium-kiosk \
        https://youngones.freshdesk.com/a/dashboard/36000006806
    '';

    Restart = "always";
    RestartSec = 5;
  };
};

  #####################################
  # SSH
  #####################################
  services.openssh.enable = true;

  networking.firewall.enable = true;

  system.stateVersion = "25.11";
}