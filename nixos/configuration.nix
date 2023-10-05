# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config
, pkgs
, ...
}:
let
  cuda = with pkgs;
    callPackage "/etc/nixpkgs/pkgs/development/compilers/cudatoolkit/common.nix" {
      version = "11.8.0";
      url = "https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run";
      sha256 = "sha256-kiPErzrr5Ke77Zq9mxY7A6GzS4VfvCtKDRtwasCaWhY=";
      gcc = "gcc11";
    };
  nvdriver = pkgs.linuxPackages.nvidia_x11.overrideAttrs (oldAttrs: {
    src = pkgs.fetchurl {
      url = "https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run";
      sha256 = "sha256-kiPErzrr5Ke77Zq9mxY7A6GzS4VfvCtKDRtwasCaWhY=";
    };
    version = "520.61.05";
    gcc = "gcc11";
  });
  user = "bg";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./cachix.nix
    ((builtins.fetchTarball {
      url = "https://github.com/symphorien/nixseparatedebuginfod/archive/9b7a087a98095c26d1ad42a05102e0edfeb49b59.tar.gz";
      sha256 = "sha256:1jbkv9mg11bcx3gg13m9d1jmg4vim7prny7bqsvlx9f78142qrlw";
    })
    + "/module.nix")
  ];

  # config = {
  services.nixseparatedebuginfod.enable = true;
  # };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  #boot.loader.grub.device = "/dev/sdb";

  boot.supportedFilesystems = [ "ntfs" ];

  #  boot.loader = {
  #	  efi = {
  #		  canTouchEfiVariables = true;
  #		  efiSysMountPoint = "/boot";
  #	  };
  #	  grub = {
  #		  #useOSProber = true;
  #		  devices = [ "/dev/sdc" ];
  #		  #efiSupport = true;
  #		  enable = true;
  #		  extraEntries = ''
  #			  menuentry "Windows" {
  #				  insmod part_msdos
  #				  insmod ntfs
  #				  insmod chain
  #				  set root=(hd3,msdos1)
  #				  chainloader +1
  #			  }
  #		  '';
  #	  };
  #};

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelPackages =
    pkgs.linuxPackages
    // {
      nvidiaPackages.stable = nvdriver;
    };

  hardware.nvidia = {
    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    #package = config.boot.kernelPackages.nvidiaPackages.legacy_520;
    # package = nvdriver;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.lorri.enable = true; # replace default nix-shell

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bg = {
    isNormalUser = true;
    description = "bg";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      google-chrome
      neovim
      vim
      pcmanfm
      ripgrep
      git
      wget
      htop
      curl
      tmux
      wget
      direnv
      gnome.gnome-terminal
      kitty
      #  thunderbird
    ];
  };

  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  # environment.binsh = "${pkgs.dash}/bin/dash";

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "bg";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  systemd.targets."bluetooth".after = [ "systemd-tmpfiles-setup.service" ];
  systemd.tmpfiles.rules = [
    "d /var/lib/bluetooth 700 root root - -"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    wireguard-tools
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.setXAuthLocation = true;
  services.openssh.settings.X11Forwarding = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
    };
  };

  #SUBSYSTEM=="input", KERNEL=="event[0-9]*", GROUP="${user}", MODE:="0660"
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="${user}", MODE:="0660"
  '';

  # services.xrdp.enable = true;
  # services.xrdp.defaultWindowManager = "${pkgs.icewm}/bin/icewm";
  # networking.firewall.allowedTCPPorts = [ 3389 ];
}
