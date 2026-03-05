# ----------------------------------------------
# 🔧 ENVIRONMENT VARIABLES
# ----------------------------------------------
# Enable vim-keybinds
#fish_vi_key_bindings

# Fish uses parens () for command substitution, not $()
if command -v java >/dev/null 2>&1
    set -gx JAVA_HOME (dirname (dirname (readlink -f (which java))))
end

if command -v jdtls >/dev/null 2>&1
    set -gx JDTLS_BIN (which jdtls)
end


# FZF Styling (No backslashes needed for Fish multiline strings if quoted properly)
set -gx FZF_DEFAULT_OPTS " \
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8 \
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8 \
  --color=info:#94e2d5,prompt:#89b4fa,pointer:#f5c2e7 \
  --color=marker:#a6e3a1,spinner:#f5c2e7,header:#f9e2af,border:#45475a"

# ----------------------------------------------
# 🔗 ALIASES
# ----------------------------------------------
alias cat "bat --color=always"
alias pcat "bat --style=plain"
alias sudo "sudo "
alias l "eza -lh --icons=auto"
alias ls "eza -1  --icons=auto"
alias ll "eza -lha --icons=auto --sort=name --group-directories-first"
alias ld "eza -lhD --icons=auto"
alias lt "eza --icons=auto --tree"
alias c "clear"
alias h "history"
alias grep "grep --color=auto"
alias fgrep "fgrep --color=auto"
alias egrep "egrep --color=auto"
alias untar "tar -xvzf"
alias fishrc "source ~/.config/fish/config.fish"
alias reb "reboot"
alias shut "shutdown -h now"
alias del "sudo rm -r"
alias cp "cp -i"
alias mkdir "mkdir -p"
# Complex aliases with arguments often need quotes in Fish
alias aliasdelete "find . -type l -print -delete"
alias zoxide-add-recursive "zoxide add **/"

# Navigation
alias .1 "cd .."
alias .2 "cd ../.."
alias .3 "cd ../../.."
alias .4 "cd ../../../.."
alias .5 "cd ../../../../.."
alias .6 "cd ../../../../../.."

alias down "cd ~/Downloads"
alias config "cd ~/.config"
alias share "cd ~/.local/share/"
alias opt "cd /opt/"
alias home "cd /home/"
alias tmp "cd /tmp/"
alias bin "cd /bin/"
alias lib "cd /lib/"
alias etc "cd /etc/"
alias usr "cd /usr/"
alias pictures "cd ~/Pictures/"
alias videos "cd ~/Videos/"
alias doc "cd ~/Documents/"
alias temp "cd ~/Templates/"
alias dot "cd ~/dotfiles"
alias dev-projects "cd ~/developing-projects/"
alias dev-java "cd ~/developing-projects/java-projects/"
alias dev-python "cd ~/developing-projects/python-projects/"
alias dev-latex "cd ~/developing-projects/latex-projects/"
alias dev-html "cd ~/developing-projects/html-projects/"

# Git
alias clone "git clone "
alias gc "git checkout "
alias gpul "git pull "
alias gm "git commit -m"
alias gmer "git merge "
alias gs "git status"
alias gp "git push "
alias clonedepth1 "git clone --depth=1 "
alias gitkeep "find . -type d -empty -not -path './.git/*' -exec touch {}/.gitkeep \;"
alias gaall "git add -A"

# SSH
alias sshtailscale "ssh krit@nicol-nas"
alias sshnasip "ssh krit@192.168.1.98"
alias sshos "ssh -l kritpio.nicol@supsi.ch linux1-didattica.supsi.ch"
alias nas-ssh "cloudflared access ssh --hostname ssh.nicolkrit.ch"

# Developing
alias rebuildmvn "cd ~/developing-projects/java-projects && mvn clean install"
alias dbx "DBX_CONTAINER_MANAGER=podman distrobox"
alias drva "direnv allow ."
alias drvr "direnv reload ."
alias nixdev "nix develop"

# Fun
alias pipes1 "pipes.sh -t 1"
alias pipes2 "pipes.sh -t 2"
alias pipes3 "pipes.sh -t 3"
alias pipes4 "pipes.sh -t 4"
alias pipes5 "pipes.sh -t 5"
alias pipes6 "pipes.sh -t 6"
alias pipes7 "pipes.sh -t 7"
alias pipes8 "pipes.sh -t 8"
alias pipes9 "pipes.sh -t 9"
alias bonsailive "cbonsai -l"

# Borgmatic backup to nas
alias borg-status "journalctl -fu borgmatic"
alias borg-manual "sudo borgmatic --verbosity 1 --stats --progress"
alias borg-unlock "sudo borgmatic break-lock"

# Virtualization
alias win-start "docker start WinBoat && echo 'Winboat-windows-vm started'"
alias win-stop "docker stop WinBoat && echo 'Winboat-windows-vm stopped'"


# System maintenance
alias nvim-recent-files-clean "rm ~/.local/state/nvim/shada/main.shada && echo 'Neovim recent files cleaned'"
alias boot-windows "sudo efibootmgr --bootnext 0000 && echo 'Next boot set to Windows'"

# Fish-specific
alias nd "nextd"
alias pd "prevd"
# ----------------------------------------------
# 📝 FUNCTIONS
# ----------------------------------------------

function cowask
    read -P "What should the cow say? " input
    cowsay "$input"
end

function gac
    if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
        echo "Error: "(pwd)" is not a git repository."
        return 1
    end
    echo "Processing repository: "(pwd)
    git add .
    git commit -m "General-"(date +%Y-%m-%d)
    git push
end

function gacm
    if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
        echo "Error: "(pwd)" is not a git repository."
        return 1
    end
    read -P "Enter commit message: " msg
    if test -z "$msg"
        echo "Aborting: Commit message cannot be empty."
        return 1
    end
    echo "Processing repository: "(pwd)
    git add .
    git commit -m "$msg"
    git push
end

# ----------------------------------------------
# 🚀 EVALS & STARTUP
# ----------------------------------------------

if status is-interactive
    if command -v starship >/dev/null 2>&1
        starship init fish | source
    end

    if command -v pay-respects >/dev/null 2>&1
        pay-respects fish | source
    end

    # Startup Splash
    if command -v fastfetch >/dev/null 2>&1; and command -v pokemon-colorscripts >/dev/null 2>&1
        fastfetch --data-raw "$(pokemon-colorscripts --no-title -r 1,3,6)"
    else if command -v pokemon-colorscripts >/dev/null 2>&1
        pokemon-colorscripts --no-title -r 1,3,6
    else if command -v fastfetch >/dev/null 2>&1
        fastfetch
    end
end
