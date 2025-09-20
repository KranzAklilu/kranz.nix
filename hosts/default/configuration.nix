{ config, pkgs, lib, unstable, ... }:

{

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "splash" "amd_pstate=disable" ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

  environment.pathsToLink =
    [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  #boot.extraModprobeConfig = ''
  #options snd-intel-dspcfg dsp_driver=1
  #'';

  networking.hostName = "kranz-rog"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  #
  # networking.firewall = {
  #   allowedUDPPorts =
  #     [ 51820 ]; # Clients and peers can use the same port, see listenport
  # };
  # # Enable WireGuard
  # networking.wireguard.interfaces = {
  #   # "wg0" is the network interface name. You can name the interface arbitrarily.
  #   wg0 = {
  #     # Determines the IP address and subnet of the client's end of the tunnel interface.
  #     ips = [ "10.100.0.2/24" ];
  #     listenPort =
  #       51820; # to match firewall allowedUDPPorts (without this wg uses random port numbers)
  #
  #     # Path to the private key file.
  #     #
  #     # Note: The private key can also be included inline via the privateKey option,
  #     # but this makes the private key world-readable; thus, using privateKeyFile is
  #     # recommended.
  #     privateKeyFile = "~/wireguard/private";
  #
  #     peers = [
  #
  #     ];
  #   };
  # };
  #
  # Set your time zone.
  time.timeZone = "Africa/Addis_Ababa";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "am_ET";
    LC_IDENTIFICATION = "am_ET";
    LC_MEASUREMENT = "am_ET";
    LC_MONETARY = "am_ET";
    LC_NAME = "am_ET";
    LC_NUMERIC = "am_ET";
    LC_PAPER = "am_ET";
    LC_TELEPHONE = "am_ET";
    LC_TIME = "am_ET";
  };

  # Enable the X11 windowing system.
  # just incase i want to switch back 
  services.xserver = {
    enable = true;

    ## Load nvidia driver for Xorg and Wayland
    videoDrivers = [ "nvidia" ];

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ betterlockscreen rofi polybar ];
      configFile = ./i3/config;
    };

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
      options = "ctrl:swapcaps";
    };
  };

  # wayland.windowManager.sway = {
  #   enable = true;
  #   extraPackages = with pkgs; [ betterlockscreen rofi polybar ];
  #   config = rec {
  #     modifier = "Mod4";
  #     # Use kitty as default terminal
  #     terminal = "alacritty";
  #     startup = [
  #       # Launch Firefox on start
  #       { command = "firefox"; }
  #     ];
  #   };
  # };

  # bluetooth
  services.blueman.enable = true;

  # if using sddm
  services.displayManager.defaultSession = "xfce+i3";
  services.libinput.touchpad.naturalScrolling = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # hopefully disables xorg from getting stuck when rebuilding
  # systemd.services.display-manager.restartIfChanged = false;
  # Enable CUPS to print documents.
  services.printing.enable = true;

  #tailscale 
  services.tailscale.enable = true;

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;

  # services.pipewire = {
  # enable = false;
  # audio.enable = true;
  # alsa.enable = true;
  # alsa.support32Bit = true;
  # pulse.enable = false;
  # # If you want to use JACK applications, uncomment this
  # jack.enable = true;
  #
  # # use the example session manager (no others are packaged yet so this is enabled by default,
  # # no need to redefine it in your config for now)
  # #media-session.enable = true;
  # wireplumber = {
  #   enable = true;
  #   # bluetooth.autoswitch-to-headset-profile = false;
  #   # extraConfig."10-bluez" = {
  #   #   "monitor.bluez.properties" = {
  #   #     "bluez5.enable-sbc-xq" = true;
  #   #     "bluez5.enable-msbc" = true;
  #   #     "bluez5.enable-hw-volume" = true;
  #   #     "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
  #   #   };
  #   # };
  # };
  # };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  users.users.kranz = {
    isNormalUser = true;
    description = "kranz";
    extraGroups = [ "networkmanager" "wheel" "media" "video" "audio" "docker" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGcRmO87UaWNhjhM5XdYGZeOa2vkeZA5GJdYYC/humnb kranz@asus-g14"
    ];
  };

  # users.users.fun = {
  #   isNormalUser = true;
  #   description = "fun account";
  #   extraGroups = [ "networkmanager" "wheel" "media" "video" "audio" "docker" ];
  #   shell = pkgs.fish;
  # };

  # Install firefox.
  programs.firefox.enable = true;

  programs.rog-control-center.enable = true;
  # programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [ ];

  programs.hyprland.enable = true;
  programs.sway.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall =
      true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # nixpkgs.config.qt5 = {
  #   enable = true;
  #   platformTheme = "qt5ct";
  #   style = {
  #     package = pkgs.utterly-nord-plasma;
  #     name = "Utterly Nord Plasma";
  #   };
  # };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl

    # zsh
    fish
    grc

    kitty
    alacritty

    obs-studio

    vlc

    glxinfo
    glmark2
    pavucontrol

    brightnessctl
    openssl

    unstable.activitywatch
    obsidian
    vulkan-headers

    wireguard-tools

    killall
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
    alsa-utils

    hyprpaper

    # for obs to work in hyprland
    # https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580
    xdg-desktop-portal-hyprland

    hoppscotch
    redis
  ];
  environment.variables = {
    EDITOR = "vim";
    WLR_RENDERER = "vulkan";
  };

  # Add docker
  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # powerManagement.powertop.enable =
  #   true; # enable powertop auto tuning on startup.
  # services.system76-scheduler.settings.cfsProfiles.enable =
  #   true; # Better scheduling for CPU cycles - thanks System76!!!
  # powerManagement.cpuFreqGovernor = "performance";

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "ondemand";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      AMDGPU_ABM_LEVEL_ON_AC = 0;
      AMDGPU_ABM_LEVEL_ON_BAT = 3;

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      # tlp might be responsible for blocking bluetooth
      USB_AUTOSUSPEND = 0;

      START_CHARGE_THRESH_BAT1 = 0;
      STOP_CHARGE_THRESH_BAT1 = 80; # 80 and above it stops charging
    };
  };
  services.supergfxd.enable = true;

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

  systemd.services.supergfxd.path = [ pkgs.pciutils pkgs.lsof ];

  hardware.alsa.enablePersistence = true;

  # Enable graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ vulkan-validation-layers ];
  };

  hardware.bluetooth.enable = true;

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    # powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.beta.overrideAttrs (old:
    #   let version = "570.133.07";
    #   in {
    #     src = pkgs.fetchurl {
    #       url =
    #         "https://download.nvidia.com/XFree86/Linux-x86_64/${version}/NVIDIA-Linux-x86_64-${version}.run";
    #       sha256 = "sha256-LUPmTFgb5e9VTemIixqpADfvbUX1QoTT2dztwI3E3CY=";
    #     };
    #   });
    prime = {
      sync.enable = true;

      amdgpuBusId = "PCI:101:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = [ "on-the-go" ];
      services.xserver = { videoDrivers = lib.mkForce [ "amdgpu" ]; };

      hardware.nvidia = {
        prime.offload.enable = lib.mkForce true;
        prime.offload.enableOffloadCmd = lib.mkForce true;
        prime.sync.enable = lib.mkForce false;
      };
    };
  };
}
