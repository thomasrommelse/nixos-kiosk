{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  #####################################
  # Bootloader (UEFI)
  #####################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #####################################
  # Basic system settings
  #####################################
  networking.hostName = "tv-dashboard-1";  # Change per machine if needed
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";  # Change if needed

  #####################################
  # X11 + Display
  #####################################
  services.xserver.enable = true;

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kiosk";

  services.xserver.windowManager.openbox.enable = true;

  # Disable screen blanking
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
  # Software
  #####################################
  environment.systemPackages = with pkgs; [
    chromium
    rustdesk
  ];

  #####################################
  # SSH (remote fallback access)
  #####################################
  services.openssh.enable = true;

  #####################################
  # Firewall (optional)
  #####################################
  networking.firewall.enable = true;

  #####################################
  # NixOS version
  #####################################
  system.stateVersion = "24.05";
}