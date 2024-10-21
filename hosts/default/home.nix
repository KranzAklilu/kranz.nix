{ config, lib, pkgs, ... }:

{
  home.username = "kranz";
  home.homeDirectory = "/home/kranz";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/sway/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  #home.file.".config/sway/config" = {
  #  source = ./sway/config;
  #  recursive = true;   # link recursively
  #  executable = true;  # make all files executable
  #};

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

    neofetch

    # archives
    zip
    xz

    # utils
    tmux # terminal multiplexer
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

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

    #software
    telegram-desktop

    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

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
    yarn

    # formatters
    prettierd
    stylua
    nixfmt-classic

    swaylock
    light
  ];

  # basic configuration of git, please change to your own
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
  in {
    enable = true;

    vimAlias = true;

    extraPackages = with pkgs; [
      lua-language-server
      #rnix-lsp

      ripgrep
      xclip
      wl-clipboard
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
        plugin = typescript-tools-nvim;
        config = toLuaFile ./nvim/plugin/typescript-tools.lua;
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
      update = "sudo nixos-rebuild switch --flake .";
      test = "sudo nixos-rebuild test --flake .";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty";
      startup = [
        # Launch Firefox on start
        { command = "firefox"; }
        { command = "kitty"; }
      ];
      input = {
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
        };
      };
      keybindings =
        let modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "XF86MonBrightnessDown" = "exec sudo light -U 10";
          "XF86MonBrightnessUp" = "exec sudo light -A 10";
        };
    };
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
