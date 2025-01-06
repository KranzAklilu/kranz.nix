{ config, lib, pkgs, ... }:

{
  home.username = "kranz";
  home.homeDirectory = "/home/kranz";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/sway/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  home.file.".config/sway" = {
    source = ./sway;
    recursive = true; # link recursively
    executable = true; # make all files executable
    onChange = ''
      ${pkgs.sway}/bin/swaymsg reload
    '';
  };

  home.file.".config/i3" = {
    source = ./i3;
    recursive = true;
    onChange = ''
      ${pkgs.i3}/bin/i3-msg reload
    '';
  };
  home.file.".config/polybar" = { source = ./polybar; };
  home.file.".config/rofi" = { source = ./rofi; };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    fastfetch

    # archives
    zip
    xz

    # utils
    tmux # terminal multiplexer
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    gh # github cli

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    ripgrep
    xclip
    feh

    # chat
    telegram-desktop
    signal-desktop

    # other software
    # insecure https://www.openwall.com/lists/oss-security/2024/10/30/4
    # qbittorrent
    postman

    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal
    obsidian # note taking

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring

    # system tools
    lm_sensors # for `sensors` command

    # dev
    nodejs_20
    # nodejs_18
    yarn
    pnpm
    go
    protobuf_26

    # formatters
    prettierd
    stylua
    nixfmt-classic

    #docs
    libre
    libreoffice-qt
    hunspell

    # lsps
    tailwindcss-language-server
    nodePackages_latest.typescript-language-server
    lua-language-server
    gopls

    #swaylock
    light
    rofi
    rofi-screenshot

    #ai stuff
    codeium
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  programs.git = {
    enable = true;
    userName = "Kranz Aklilu";
    userEmail = "kranzaklilu@gmail.com";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.sensible
      tmuxPlugins.catppuccin
    ];
    extraConfig = ''
      bind | split-window -h
      bind - split-window -v

      unbind '"'
      unbind %
      set-option -g mouse on
      set -g @catppuccin_flavour 'mocha'

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      unbind C-b
      set -g prefix C-s
    '';
  };

  programs.neovim = let
    toLua = str: ''
      lua << EOF
      ${str}
      EOF
    '';
    toLuaFile = file: ''
      lua << EOF
      ${builtins.readFile file}
      EOF
    '';
    rustToolchain = pkgs.fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
      "rust-analyzer"
    ];
  in {
    enable = true;

    vimAlias = true;

    extraPackages = with pkgs; [
      #lua-language-server
      lua52Packages.lua-lsp

      ripgrep
      xclip
      wl-clipboard
      rustToolchain
    ];

    plugins = with pkgs.vimPlugins; [

      vim-fugitive

      #cmp_luasnip

      cmp-nvim-lsp

      luasnip

      #friendly-snippets

      lualine-nvim

      nvim-web-devicons

      plenary-nvim

      undotree

      {
        plugin = codeium-nvim;
        config = toLuaFile ./nvim/plugin/codeium.lua;
      }

      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./nvim/plugin/lsp.lua;
      }

      {
        plugin = which-key-nvim;
        config = toLuaFile ./nvim/plugin/which-key.lua;
      }

      {
        plugin = comment-nvim;
        config = toLua ''require("Comment").setup()'';
      }

      {
        plugin = typescript-tools-nvim;
        config = toLuaFile ./nvim/plugin/typescript-tools.lua;
      }

      {
        plugin = nightfox-nvim;
        config = "colorscheme carbonfox";
      }

      {
        plugin = gitsigns-nvim;
        config = toLuaFile ./nvim/plugin/gitsigns.lua;
      }

      {
        plugin = mini-nvim;
        config = toLuaFile ./nvim/plugin/mini.lua;
      }

      neodev-nvim

      #nvim-cmp 

      {
        plugin = nvim-cmp;
        config = toLuaFile ./nvim/plugin/cmp.lua;
      }

      {
        plugin = conform-nvim;
        config = toLuaFile ./nvim/plugin/conform.lua;
      }

      telescope-fzf-native-nvim
      telescope-ui-select-nvim

      {
        plugin = telescope-nvim;
        config = toLuaFile ./nvim/plugin/telescope.lua;
      }

      {
        plugin = nvim-tree-lua;
        config = toLuaFile ./nvim/plugin/nvim-tree.lua;
      }

      {
        plugin = (nvim-treesitter.withPlugins (p: [
          p.tree-sitter-nix
          p.tree-sitter-vim
          p.tree-sitter-vimdoc
          p.tree-sitter-bash
          p.tree-sitter-lua
          p.tree-sitter-python
          p.tree-sitter-json
          p.tree-sitter-css
          p.tree-sitter-javascript
          p.tree-sitter-typescript
          p.tree-sitter-go
          p.tree-sitter-gomod
        ]));
        config = toLuaFile ./nvim/plugin/treesitter.lua;
      }

      vim-nix

      # {
      #   plugin = vimPlugins.own-onedark-nvim;
      #   config = "colorscheme onedark";
      # }
    ];

    #extraLuaConfig = ''
    #  ${builtins.readFile ./nvim/options.lua}
    #'';

    extraLuaConfig = ''
      ${builtins.readFile ./nvim/options.lua}
      ${builtins.readFile ./nvim/plugin/lsp.lua}
      ${builtins.readFile ./nvim/plugin/cmp.lua}
      ${builtins.readFile ./nvim/plugin/telescope.lua}
      ${builtins.readFile ./nvim/plugin/treesitter.lua}
      ${builtins.readFile ./nvim/plugin/nvim-tree.lua}
      ${builtins.readFile ./nvim/plugin/conform.lua}
      ${builtins.readFile ./nvim/plugin/other.lua}
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "z" "sudo" "web-search" "copypath" "copyfile" ];
    };
    shellAliases = {
      ll = "ls -l";
      ":q" = "exit";
      update = "sudo nixos-rebuild switch --flake .";
      test = "sudo nixos-rebuild test --flake .";
    };
    initExtra = ''
      export PATH=$HOME/.cargo/bin:$PATH
    '';
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  services.polybar = {
    package = pkgs.polybar.override {
      alsaSupport = true;
      pulseSupport = true;
      i3Support = true;
      i3 = pkgs.i3;
      jsoncpp = pkgs.jsoncpp;
    };
    enable = true;
    script = "exec polybar main";
  };

  # sway config
  wayland.windowManager.sway = {
    enable = true;
    extraOptions = [ "--unsupported-gpu" ];
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
