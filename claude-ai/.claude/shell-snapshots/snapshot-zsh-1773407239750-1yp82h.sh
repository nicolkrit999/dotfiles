# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
__arguments () {
	# undefined
	builtin autoload -XUz /etc/profiles/per-user/krit/share/zsh/5.9/functions
}
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
compaudit () {
	# undefined
	builtin autoload -XUz /etc/profiles/per-user/krit/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz /etc/profiles/per-user/krit/share/zsh/5.9/functions
}
compinit () {
	# undefined
	builtin autoload -XUz /etc/profiles/per-user/krit/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /etc/profiles/per-user/krit/share/zsh/5.9/functions
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
is-at-least () {
	emulate -L zsh
	local IFS=".-" min_cnt=0 ver_cnt=0 part min_ver version order 
	min_ver=(${=1}) 
	version=(${=2:-$ZSH_VERSION} 0) 
	while (( $min_cnt <= ${#min_ver} ))
	do
		while [[ "$part" != <-> ]]
		do
			(( ++ver_cnt > ${#version} )) && return 0
			if [[ ${version[ver_cnt]} = *[0-9][^0-9]* ]]
			then
				order=(${version[ver_cnt]} ${min_ver[ver_cnt]}) 
				if [[ ${version[ver_cnt]} = <->* ]]
				then
					[[ $order != ${${(On)order}} ]] && return 1
				else
					[[ $order != ${${(O)order}} ]] && return 1
				fi
				[[ $order[1] != $order[2] ]] && return 0
			fi
			part=${version[ver_cnt]##*[^0-9]} 
		done
		while true
		do
			(( ++min_cnt > ${#min_ver} )) && return 0
			[[ ${min_ver[min_cnt]} = <-> ]] && break
		done
		(( part > min_ver[min_cnt] )) && return 0
		(( part < min_ver[min_cnt] )) && return 1
		part='' 
	done
}
# Shell Options
setopt noappendhistory
setopt nobeep
setopt nohashdirs
setopt histfcntllock
setopt histignoredups
setopt histignorespace
setopt login
setopt sharehistory
# Aliases
alias -- .1='cd ..'
alias -- .2='cd ../..'
alias -- .3='cd ../../..'
alias -- .4='cd ../../../..'
alias -- .5='cd ../../../../..'
alias -- .6='cd ../../../../../..'
alias -- aliasdelete='find . -type l -print -delete'
alias -- bin='cd /bin/'
alias -- c=clear
alias -- cat='bat --color=always'
alias -- clone='git clone'
alias -- clonedepth1='git clone --depth=1 '
alias -- config='cd ~/.config'
alias -- cp='cp -i'
alias -- dbx='DBX_CONTAINER_MANAGER=podman distrobox'
alias -- del='sudo rm -r'
alias -- dev-html='cd ~/developing-projects/html-projects/'
alias -- dev-java='cd ~/developing-projects/java-projects/'
alias -- dev-latex='cd ~/developing-projects/latex-projects/'
alias -- dev-projects='cd ~/developing-projects/'
alias -- dev-python='cd ~/developing-projects/python-projects/'
alias -- doc='cd ~/Documents/'
alias -- dot='cd ~/dotfiles'
alias -- down='cd ~/Downloads'
alias -- drva='direnv allow .'
alias -- egrep='egrep --color=auto'
alias -- etc='cd /etc/'
alias -- fgrep='fgrep --color=auto'
alias -- gaall='git add -A'
alias -- gc='git checkout'
alias -- gitkeep='find . -type d -empty -not -path '\''./.git/*'\'' -exec touch {}/.gitkeep \;'
alias -- gm='git commit -m'
alias -- gmer='git merge'
alias -- gp='git push'
alias -- gpul='git pull'
alias -- grep='grep --color=auto'
alias -- gs='git status'
alias -- h=history
alias -- home='cd /home/'
alias -- l='eza -lh --icons=auto'
alias -- ld='eza -lhD --icons=auto'
alias -- lib='cd /lib/'
alias -- ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias -- ls='eza -1  --icons=auto'
alias -- lt='eza --icons=auto --tree'
alias -- mkdir='mkdir -p'
alias -- nas-ssh='cloudflared access ssh --hostname ssh.nicolkrit.ch'
alias -- opt='cd /opt/'
alias -- pcat='bat --style=plain'
alias -- pictures='cd ~/Pictures/'
alias -- reb=reboot
alias -- rebuildmvn='cd ~/developing-projects/java-projects && mvn clean install'
alias -- run-help=man
alias -- share='cd ~/.local/share/'
alias -- shut='shutdown -h now'
alias -- sshnasip='ssh krit@192.168.1.98'
alias -- sshos='ssh -l kritpio.nicol@supsi.ch linux1-didattica.supsi.ch'
alias -- sshtailscale='ssh krit@nicol-nas'
alias -- sudo='sudo '
alias -- temp='cd ~/Templates/'
alias -- tmp='cd /tmp/'
alias -- untar='tar -xvzf'
alias -- usr='cd /usr/'
alias -- videos='cd ~/Videos/'
alias -- which='type -a'
alias -- which-command=whence
alias -- zoxide-add-recursive='zoxide add **/'
alias -- zshrc='source ~/.zshrc'
# Check for rg availability
if ! (unalias rg 2>/dev/null; command -v rg) >/dev/null 2>&1; then
  alias rg='rg'
fi
export PATH=/nix/store/dbabbbmjibhmgxv4bysq9fq2h2b20vab-procps-1003.1-2008/bin\:/nix/store/rk7ybrjczvghr8bqs20gw8zpfh2ywc27-ripgrep-15.1.0/bin\:/nix/var/nix/profiles/per-user/krit/profile/bin\:/opt/homebrew/bin\:/Users/krit/.nix-profile/bin\:/etc/profiles/per-user/krit/bin\:/run/current-system/sw/bin\:/nix/var/nix/profiles/default/bin\:/usr/local/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin
