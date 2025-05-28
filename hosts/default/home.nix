{ config, lib, pkgs, ... }:

{
  home.username = "kranz";
  home.homeDirectory = "/home/kranz";

  # link the configuration file in current directory to the specified location in home directory

  home.file.".config/i3" = {
    source = ./i3;
    recursive = true;
    onChange = ''
      ${pkgs.i3}/bin/i3-msg reload
    '';
  };
  home.file.".config/polybar".source = config.lib.file.mkOutOfStoreSymlink
    /home/kranz/main/nixos/hosts/default/polybar;
  home.file.".config/rofi" = { source = ./rofi; };
  home.file.".config/theme/images" = { source = ./images; };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    fastfetch

    # archives
    zip
    unzip
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
    dysk

    # chat
    telegram-desktop
    signal-desktop

    # other software
    # insecure https://www.openwall.com/lists/oss-security/2024/10/30/4
    # qbittorrent

    # api caller
    postman
    hoppscotch

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
    powertop # power monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring

    # system tools
    lm_sensors # for `sensors` command

    # dev
    code-cursor
    nodejs_20
    # nodejs_18
    yarn
    pnpm

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
    nodePackages_latest."@prisma/language-server"
    lua-language-server
    gopls

    light
    rofi
    rofi-screenshot

    #ai stuff
    codeium
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
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
      unbind C-b
      set -g prefix C-s

      unbind '"'
      unbind %

      bind | split-window -h
      bind - split-window -v
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind p last-window
      bind b previous-window

      set-option -g mouse on
      set -g @catppuccin_flavour 'mocha'

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
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
    # rustToolchain = pkgs.fenix.complete.withComponents [
    #   "cargo"
    #   "clippy"
    #   "rust-src"
    #   "rustc"
    #   "rustfmt"
    #   "rust-analyzer"
    # ];
  in {
    enable = true;

    vimAlias = true;

    extraPackages = with pkgs; [
      #lua-language-server
      lua52Packages.lua-lsp

      ripgrep
      xclip
      wl-clipboard
      # rustToolchain
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

      codeium-nvim

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

      lspkind-nvim

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
          p.tree-sitter-prisma

          (pkgs.tree-sitter.buildGrammar {
            language = "astro";
            version = "8af0aab";
            src = pkgs.fetchFromGitHub {
              owner = "virchau13";
              repo = "tree-sitter-astro";
              rev = "6e3bad36a8c12d579e73ed4f05676141a4ccf68d";
              sha256 = "sha256-ZsItSpYeSPnHn4avpHS54P4J069X9cW8VCRTM9Gfefg=";
            };
          })
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
      switch = "sudo nixos-rebuild switch --flake .";
      test = "sudo nixos-rebuild test --flake .";
    };
    initExtra = ''
      export PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
      export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query-engine"
      export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
      export PRISMA_INTROSPECTION_ENGINE_BINARY="${pkgs.prisma-engines}/bin/introspection-engine"
      export PRISMA_FMT_BINARY="${pkgs.prisma-engines}/bin/prisma-fmt"

      export PATH="/home/kranz/go/bin:$PATH"
      export PATH="/home/kranz/.cache/npm/global/bin:$PATH"
      export PATH="/usr/local/bin:$PATH"
    '';
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    plugins = [{
      name = "zsh-nix-shell";
      file = "nix-shell.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "chisui";
        repo = "zsh-nix-shell";
        rev = "v0.8.0";
        sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
      };
    }];
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
      githubSupport = true;
    };
    enable = true;
    script = "exec polybar main";
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
