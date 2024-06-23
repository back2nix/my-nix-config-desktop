{
  config,
  pkgs,
  ...
}: let
  cudaPkg = import (fetchTarball "https://github.com/admercs/nixpkgs/archive/6fbd12c2a062abe04528230998f36730287b6fbd.tar.gz") {
    config.allowUnfree = true;
  };
  masterPkg = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {
    nixpkgs.config = {
      allowUnfree = true;
    };
  };
in {
  imports = [
    #<home-manager/nixos>
    # ./module/wordpress.nix
    ./hardware-configuration.nix
    ./cachix.nix
    ./module/shadowsocks.nix
    ./module/vpn/vpn.nix
    ./module/users/users.nix
    ./module/change.mac.nix
    ./cuda.nix
    # ./opendevin.nix
  ];

  nixpkgs.overlays = [
    # ( final: prev: {
    #   unstable = cudaPkg.legacyPackages.${prev.system};
    #   nvidia-container-toolkit = cudaPkg.legacyPackages.${prev.system}.nvidia-container-toolkit;
    # })
  ];

  boot = {
    # kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;

    supportedFilesystems = ["ntfs"];

    tmp = {
      useTmpfs = true;
      tmpfsSize = "25%";
    };

    kernel.sysctl = {
      "net.ipv4.ip_forward" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
      "net.ipv4.conf.all.send_redirects" = "0";
      "net.ipv4.ip_unprivileged_port_start" = 0;
    };
  };

  hardware = {
    # opengl = {
    #   enable = true;
    #   driSupport = true;
    #   driSupport32Bit = true;
    # };

    # pulseaudio.enable = true;
    pulseaudio.enable = false;

    nvidia-container-toolkit.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
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
  };

  # Enable sound with pipewire.
  sound.enable = true;
  # pavucontol for settings loop back "Monitor of Alder Lake PCH-P High Definition Audio Controller HDMI / DisplayPort 3 Output"
  security.rtkit.enable = true;

  environment = {
    sessionVariables = rec {
      GTK_THEME = "Adwaita:dark";
      LD_LIBRARY_PATH = [
        "/run/opengl-driver/lib/:$NIX_LD_LIBRARY_PATH"
      ];
    };

    shells = with pkgs; [zsh];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      gcc
      xclip
      gnumake
      unzip
      cargo
      luarocks
      go_1_21
      go-outline
      gopls
      gopkgs
      go-tools
      delve
      telescope

      neovim
      fzf
      fd
      lazygit
      gdu
      bottom
      nodejs_18

      obfs4
      vim
      ripgrep
      git
      wget
      htop
      curl
      tmux
      wget
      kitty
      gnome.gnome-shell
      shadowsocks-libev

      lm_sensors
      virtualbox
      direnv
      tcpdump
      wireshark
      tshark
      pavucontrol
      # cudatoolkit-pin
      #cudatoolkit
      #linuxPackages.nvidia_x11
      # cudaPkg.nvidia-docker
      # cudaPkg.nvidia-container-toolkit
      # cudaPkg.cudaPackages_12_4.cudatoolkit
      # cudaPkg.nvtopPackages.nvidia
      cudaPackages.cudatoolkit
      # nvtopPackages.nvidia
    ];

    etc."proxychains.conf".text = ''
      strict_chain
      proxy_dns

      remote_dns_subnet 224

      tcp_read_time_out 15000
      tcp_connect_time_out 8000

      localnet 127.0.0.0/255.0.0.0

      [ProxyList]
      # ssh -L 0.0.0.0:1081:localhost:1080 bg@localhost -N
      # socks5 192.168.0.5 1081
      socks5 127.0.0.1 1080
      # socks5 192.168.100.3 1080
      # socks5 127.0.0.1 8118
      # socks5 127.0.0.1 9063
    '';
  };

  programs = {
    zsh.enable = true;
    ssh.setXAuthLocation = true;
    nix-ld.enable = true;
    dconf.enable = true;
    wireshark.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  systemd = {
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
      NetworkManager-wait-online.enable = false;
    };

    targets.sleep.enable = false;
    targets.suspend.enable = false;
    targets.hibernate.enable = false;
    targets.hybrid-sleep.enable = false;
    tmpfiles.rules = [
      "d /var/lib/bluetooth 700 root root - -"
      "d /var/lib/swapfile 0644 root root - -"
      # "d /var/lib/wordpress/localhost 0750 wordpress wwwrun - -"
      # "d /var/lib/wordpress/localhost/wp-content 0750 wordpress wwwrun - -"
      # "d /var/lib/wordpress/localhost/wp-content/plugins 0750 wordpress wwwrun - -"
      # "d /var/lib/wordpress/localhost/wp-content/themes 0750 wordpress wwwrun - -"
      # "d /var/lib/wordpress/localhost/wp-content/upgrade 0750 wordpress wwwrun - -"
    ];
    targets."bluetooth".after = ["systemd-tmpfiles-setup.service"];
    user.services.pipewire-pulse.path = [pkgs.pulseaudio];
    # user.services.docker.path = [ cudaPkg.nvidia-docker ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  system.stateVersion = "23.11"; # Did you read the comment?

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
      # extraOptions = "--add-runtime nvidia=/run/current-system/sw/bin/nvidia-container-runtime";
      # enableNvidia = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      # package = cudaPkg.docker;
      # extraPackages = [cudaPkg.nvidia-docker];
      # extraOptions = "--default-runtime=nvidia";
      daemon = {
        settings = {
          # registry-mirrors = [
          #   "https://huecker.io"
          # ];
          # runtimes = {
          #   nvidia = {
          #     path = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
          #   };
          # };
        };
      };
    };

    virtualbox.host.enable = true;

    podman = {
      enable = true;
      #dockerCompat = true;
      enableNvidia = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };

  # swapDevices = [
  #   {
  #     device = "/swapfile";
  #     size = 16 * 1024;
  #   }
  # ];

  # https://github.com/gvolpe/nix-config/blob/0ed3d66f228a6d54f1e9f6e1ef4bc8daec30c0af/system/configuration.nix#L161
  fonts.packages = with pkgs; [
    times-newer-roman
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings.trusted-users = ["root" "bg"];
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;

    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "wlp0s20f3";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };

    # 127.0.0.1 host.docker.internal
    extraHosts = ''
      127.0.0.1 kafka
    '';

    hostName = "nixos"; # Define your hostname.

    # Open ports in the firewall.
    firewall = {
      enable = true;
      extraCommands = ''
        iptables -t nat -A PREROUTING -i wlp0s20f3 -p tcp --dport 80 -j REDIRECT --to-port 1081
        iptables -t nat -A PREROUTING -i wlp0s20f3 -p tcp --dport 443 -j REDIRECT --to-port 1081
        ip6tables -t nat -A PREROUTING -i wlp0s20f3 -p tcp --dport 80 -j REDIRECT --to-port 1081
        ip6tables -t nat -A PREROUTING -i wlp0s20f3 -p tcp --dport 443 -j REDIRECT --to-port 1081
      '';
    };
  };

  # hardware.nvidia.modesetting.enable = true; # ./cuda.nix
  services = {
    change-mac = {
      enable = false;
      interface = "wlp0s20f3";
      macAddress = "00:11:22:33:44:55";
    };

    dbus.packages = [pkgs.dconf];

    udev.packages = [pkgs.gnome3.gnome-settings-daemon];

    libinput.enable = true;

    xserver = {
      enable = true;
      autorun = true;
      # videoDrivers = ["modesetting" "nvidia"]; # ./cuda.nix
      xkb = {
        layout = "us,ru";
      };
      displayManager = {
        gdm = {
          enable = true;
          wayland = false;
        };
      };
      desktopManager.gnome.enable = true;
      displayManager = {startx.enable = true;};
    };

    printing.enable = true;

    openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        X11DisplayOffset = 10;
        #X11UseLocalhost = true;
      };
    };

    flatpak.enable = true;

    blueman.enable = true;

    logind.extraConfig = ''
      RuntimeDirectorySize=16G
    '';

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
    };
  };
}
