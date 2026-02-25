{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  #####################################
  # Allow unfree packages (RustDesk)
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
  networking.hostName = "tv-dashboard-1";  # Change per TV if needed
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";  # Adjust if needed

  #####################################
  # X11 + Display
  #####################################
  services.xserver.enable = true;

  services.xserver.displayManager.lightdm.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kiosk";

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
  # Installed software
  #####################################
  environment.systemPackages = with pkgs; [
    chromium
  ];

  #####################################
  # SSH (remote fallback access)
  #####################################
  services.openssh.enable = true;

  #####################################
  # Firewall
  #####################################
  networking.firewall.enable = true;

  #####################################
  # System version
  #####################################
  system.stateVersion = "25.11";
}