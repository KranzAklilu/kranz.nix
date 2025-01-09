# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "splash" "amd_pstate=disable" ];

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
    # videoDrivers = [ "nvidia" "amdgpu" ];
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
      extraPackages = with pkgs; [
        i3status # gives you the default i3 status bar
        i3lock-color
        i3blocks # if you are planning on using i3blocks over i3status
        imagemagick
        betterlockscreen
        rofi
        polybar
      ];
      configFile = ./i3/config;
    };

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
      options = "ctrl:swapcaps";
    };
  };

  # bluetooth
  services.blueman.enable = true;

  # if using sddm
  services.displayManager.defaultSession = "none+i3";
  services.libinput.touchpad.naturalScrolling = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # hopefully disables xorg from getting stuck when rebuilding
  # systemd.services.display-manager.restartIfChanged = false;
  # Enable CUPS to print documents.
  services.printing.enable = true;

  #tailscale 
  services.tailscale.enable = true;

  # nessessary for sway
  security.polkit.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    wireplumber.enable = true;
  };

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
    extraGroups = [ "networkmanager" "wheel" "media" "video" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGcRmO87UaWNhjhM5XdYGZeOa2vkeZA5GJdYYC/humnb kranz@asus-g14"
    ];
    packages = with pkgs;
      [
        kdePackages.kate
        #  thunderbird
      ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.rog-control-center.enable = true;
  programs.zsh.enable = true;

  # sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      linux-firmware
      swaylock
      swayidle
      i3status-rust
      wayland
    ];

    extraSessionCommands = ''
      export MOZ_ENABLE_WAYLAND=1
      export WLR_DRM_NO_MODIFIERS=1
      export WLR_DRM_DEVICES=/dev/dri/card0
    '';

  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [ ];

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

  # nixpkgs.config.qt5 = {
  #   enable = true;
  #   platformTheme = "qt5ct";
  #   style = {
  #     package = pkgs.utterly-nord-plasma;
  #     name = "Utterly Nord Plasma";
  #   };
  # };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    git
    vim
    wget
    curl
    clang
    python3
    rustup
    zsh
    nodePackages.prisma

    kitty
    obs-studio
    vlc
    glxinfo
    glmark2
    sway
    pavucontrol
    qbittorrent

    brightnessctl
    openssl

    # activitywatch
    vulkan-headers

    # kde themeing
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    killall
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];
  environment.variables = {
    EDITOR = "vim";
    WLR_RENDERER = "vulkan";
  };
  environment.sessionVariables = {
    PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
    PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
    PRISMA_QUERY_ENGINE_LIBRARY =
      "${pkgs.prisma-engines}/lib/libquery_engine.node";
    PRISMA_INTROSPECTION_ENGINE_BINARY =
      "${pkgs.prisma-engines}/bin/introspection-engine";
    PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
    PRISMA_CLI_BINARY_TARGETS = "linux";
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
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      PLATFORM_PROFILE_ON_AC = "performance";
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

      START_CHARGE_THRESH_BAT1 = 0;
      STOP_CHARGE_THRESH_BAT1 = 80; # 80 and above it stops charging
    };
  };
  services.supergfxd.enable = true;

  systemd.services.supergfxd.path = [ pkgs.pciutils pkgs.lsof ];

  # necessary for sway
  # kanshi systemd service
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    environment = {
      WAYLAND_DISPLAY = "wayland-1";
      DISPLAY = ":0";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kanshi}/bin/kanshi -c kanshi_config_file";
    };
  };

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

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
    powerManagement.enable = false;

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
    prime = {
      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };
      sync.enable = true;

      amdgpuBusId = "PCI:101:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
