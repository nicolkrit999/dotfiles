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
# 🔗 abbr -aES
# ----------------------------------------------
abbr -a cat "bat --color=always"
abbr -a pcat "bat --style=plain"
abbr -a sudo "sudo "
abbr -a l "eza -lh --icons=auto"
abbr -a ls "eza -1  --icons=auto"
abbr -a ll "eza -lha --icons=auto --sort=name --group-directories-first"
abbr -a ld "eza -lhD --icons=auto"
abbr -a lt "eza --icons=auto --tree"
abbr -a c "clear"
abbr -a h "history"
abbr -a grep "grep --color=auto"
abbr -a untar "tar -xvzf"
abbr -a fishrc "source ~/.config/fish/config.fish"
if test (uname) = Linux
    abbr -a reb "reboot"
    abbr -a shut "shutdown -h now"
else
    abbr -a reb "sudo reboot"
    abbr -a shut "sudo shutdown -h now"
end
abbr -a del "sudo rm -r"
abbr -a cp "cp -i"
abbr -a mkdir "mkdir -p"
# Complex abbr -aes with arguments often need quotes in Fish
abbr -a zoxide-add-recursive "zoxide add **/"

# Navigation
abbr -a .1 "cd .."
abbr -a .2 "cd ../.."
abbr -a .3 "cd ../../.."
abbr -a .4 "cd ../../../.."
abbr -a .5 "cd ../../../../.."
abbr -a .6 "cd ../../../../../.."

abbr -a down "cd ~/Downloads"
abbr -a config "cd ~/.config"
abbr -a share "cd ~/.local/share/"
abbr -a opt "cd /opt/"
if test (uname) = Linux
    abbr -a home "cd /home/"
else
    abbr -a home "cd /Users"
end
abbr -a tmp "cd /tmp/"
abbr -a bin "cd /bin/"
if test (uname) = Linux
    abbr -a lib "cd /lib/"
end
abbr -a etc "cd /etc/"
abbr -a usr "cd /usr/"
abbr -a pictures "cd ~/Pictures/"
if test (uname) = Linux
    abbr -a videos "cd ~/Videos/"
else
    abbr -a videos "cd ~/Movies/"
end
abbr -a doc "cd ~/Documents/"
if test (uname) = Linux
    abbr -a temp "cd ~/Templates/"
end
abbr -a dot "cd ~/dotfiles"
abbr -a dev-projects "cd ~/developing-projects/"
abbr -a dev-java "cd ~/developing-projects/java-projects/"
abbr -a dev-python "cd ~/developing-projects/python-projects/"
abbr -a dev-latex "cd ~/developing-projects/latex-projects/"
abbr -a dev-html "cd ~/developing-projects/html-projects/"

# Git
abbr -a clone "git clone"
abbr -a gc "git checkout"
abbr -a gm "git commit -m"
abbr -a gmer "git merge"
abbr -a gs "git status"
abbr -a gp "git pull"
abbr -a gP "git push"
abbr -a clonedepth1 "git clone --depth=1 "
abbr -a gitkeep "find . -type d -empty -not -path './.git/*' -exec touch {}/.gitkeep \;"
abbr -a gaall "git add -A"

# SSH
abbr -a sshtailscale "ssh krit@nicol-nas"
abbr -a sshnasip "ssh krit@192.168.1.98"
abbr -a sshos "ssh -l kritpio.nicol@supsi.ch linux1-didattica.supsi.ch"

# Developing
abbr -a rebuildmvn "mvn clean install"
if test (uname) = Linux
    abbr -a dbx "DBX_CONTAINER_MANAGER=podman distrobox"
end
abbr -a drva "direnv allow ."
abbr -a drvr "direnv reload ."
abbr -a nixdev "nix develop"

# Fun
abbr -a pipes1 "pipes.sh -t 1"
abbr -a pipes2 "pipes.sh -t 2"
abbr -a pipes3 "pipes.sh -t 3"
abbr -a pipes4 "pipes.sh -t 4"
abbr -a pipes5 "pipes.sh -t 5"
abbr -a pipes6 "pipes.sh -t 6"
abbr -a pipes7 "pipes.sh -t 7"
abbr -a pipes8 "pipes.sh -t 8"
abbr -a pipes9 "pipes.sh -t 9"
abbr -a bonsailive "cbonsai -l"

# Borgmatic backup to nas
if test (uname) = Linux
    abbr -a borg-status "journalctl -fu borgmatic"
    abbr -a borg-manual "sudo borgmatic --verbosity 1 --stats --progress"
    abbr -a borg-unlock "sudo borgmatic break-lock"
end

# Virtualization
if test (uname) = Linux
    abbr -a win-start "docker start WinBoat && echo 'Winboat-windows-vm started'"
    abbr -a win-stop "docker stop WinBoat && echo 'Winboat-windows-vm stopped'"
end


# System maintenance
abbr -a nvim-recent-files-clean "rm ~/.local/state/nvim/shada/main.shada && echo 'Neovim recent files cleaned'"
if test (uname) = Linux
    abbr -a boot-windows "sudo efibootmgr --bootnext 0000 && echo 'Next boot set to Windows'"
end

# Fish-specific
abbr -a nd "nextd"
abbr -a pd "prevd"
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
end
