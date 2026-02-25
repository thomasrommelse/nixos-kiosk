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
  # Installed software
  #####################################
  environment.systemPackages = with pkgs; [
    chromium
  ];

  #####################################
  # Declarative Openbox autostart
  #####################################
  environment.etc."xdg/openbox/autostart".text = ''
    xset -dpms
    xset s off
    xset s noblank

    ${pkgs.chromium}/bin/chromium \
      --kiosk \
      --incognito \
      --noerrdialogs \
      --disable-infobars \
      https://youngones.freshdesk.com/a/dashboard/36000006806 &
  '';

  #####################################
  # SSH
  #####################################
  services.openssh.enable = true;

  networking.firewall.enable = true;

  system.stateVersion = "25.11";
}