{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "cheerio-pixel";
  home.homeDirectory = "/home/cheerio-pixel";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # It is sometimes useful to fine-tune packages, for example, by applying
    # overrides. You can do that directly here, just don't forget the
    # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # fonts?
    (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    (pkgs.writeShellScriptBin "nvim" ''
      LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
      pkgs.sqlite
      ]} ${pkgs.neovim}/bin/nvim "$@"
    '')
    vim
    emacs
    git
    ripgrep
    fd
    sqlite

    zig
    gcc

    unzip
    zip

    gnumake
    rustup

    tmux
    tmuxPlugins.sensible
    tmuxPlugins.continuum
    tmuxPlugins.catppuccin
    tmuxPlugins.resurrect

    eza
    fzf
    xsel

    zsh
    antidote
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    # ".local/lib/libsqlite3.so".source = "${pkgs.sqlite.out}/lib/libsqlite3.so";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/cheerio-pixel/etc/profile.d/hm-session-vars.sh
  #
  # home.sessionVariables = {
  #   # EDITOR = "vim";
  #   # To get the behaviour that I want
  #   EDITOR = "nvim";
  # };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
	  enable = true;
	  extraConfig = {
		  init = {
			  defaultBranch = "main";
		  };
	  };
  };

  programs.tmux = {
	  enable = true;
	  keyMode = "vi";
	  baseIndex  = 1;
	  mouse = true;
	  newSession = true;
	  prefix = "C-a";
	  clock24 = true;
	  shell = "${pkgs.zsh}/bin/zsh";
	  # shortcut = "a";
          # Force tmux to use /tmp for sockets (WSL2 compat)
	  secureSocket = false;
	  terminal = "tmux-256color";
	  extraConfig = ''
bind C-p previous-window
bind C-n next-window
bind-key -n C-a send-keys C-a
'';
	  plugins = with pkgs; [
		  tmuxPlugins.sensible
		  {
			  plugin = tmuxPlugins.resurrect;
			  extraConfig = ''
				  set -g @resurrect-processes 'ssh psql mysql sqlite3 ~sbt ~dotnet ~ng'
				  '';
		  }
	  {

		  plugin = tmuxPlugins.catppuccin;
		  extraConfig = ''
			  set -g @catppuccin_flavor "frappe"
			  set -g @catppuccin_window_status_style "rounded"

			  set -g status-right-length 100
			  set -g status-left-length 100
			  set -g status-left ""
			  set -g status-right "#{E:@catppuccin_status_application}"
			  set -agF status-right "#{E:@catppuccin_status_cpu}"
			  set -ag status-right "#{E:@catppuccin_status_session}"
			  set -ag status-right "#{E:@catppuccin_status_uptime}"
			  set -agF status-right "#{E:@catppuccin_status_battery}"
			  '';
	  }
	  {
		  plugin = tmuxPlugins.continuum;
		  extraConfig = ''
set -g @continuum-restore 'on'
set -g @continuum-save-interval '10' # minutes
'';
	  }
	  ];
  };

  programs.zsh = {
	  enable = true;

	  shellAliases = {
		  ls = "eza -la";
	  };
	  initExtra = ''
if [ "$TMUX" = "" ]; then tmux; fi
bindkey -e
source $HOME/.p10k.zsh
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' continuous-trigger '/'

# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'

# Make fzf-tab recursively list files (like `**`)
# zstyle ':fzf-tab:*' file-patterns '**/*'
if [ -n "$${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi
setopt globdots # show dotfiles in autocomplete list

# This will be our new default `ctrl+w` command
my-backward-delete-word() {
    # Copy the global WORDCHARS variable to a local variable. That way any
    # modifications are scoped to this function only
    local WORDCHARS=$WORDCHARS
    # Use bash string manipulation to remove `:` so our delete will stop at it
    WORDCHARS="''\${WORDCHARS//:}"
    # Use bash string manipulation to remove `/` so our delete will stop at it
    WORDCHARS="''\${WORDCHARS//\/}"
    # Use bash string manipulation to remove `.` so our delete will stop at it
    WORDCHARS="''\${WORDCHARS//.}"
    # zle <widget-name> will run an existing widget.
    zle backward-delete-word
}
# `zle -N` will create a new widget that we can use on the command line
zle -N my-backward-delete-word
# bind this new widget to `ctrl+w`
bindkey '^W' my-backward-delete-word

# This will be our `ctrl+alt+w` command
my-backward-delete-whole-word() {
    # Copy the global WORDCHARS variable to a local variable. That way any
    # modifications are scoped to this function only
    local WORDCHARS=$WORDCHARS
    # Use bash string manipulation to add `:` to WORDCHARS if it's not present
    # already.
    [[ ! $WORDCHARS == *":"* ]] && WORDCHARS="$WORDCHARS"":"
    # zle <widget-name> will run that widget.
    zle backward-delete-word
}
# `zle -N` will create a new widget that we can use on the command line
zle -N my-backward-delete-whole-word
# bind this new widget to `ctrl+alt+w`
bindkey '^[^w' my-backward-delete-whole-word

export EDITOR=nvim
'';

	  antidote = {
		  enable = true;
		  plugins = [
			  "zsh-users/zsh-autosuggestions"
			  "romkatv/powerlevel10k"
			  "zsh-users/zsh-syntax-highlighting"
			  "joshskidmore/zsh-fzf-history-search"
			  "Aloxaf/fzf-tab"
		  ];
	  };
  };
  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
}
