# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="gentoo_new"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git python django)

export PATH=$PATH:~/bin/

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

alias mci='mvn clean install -Dmaven.test.skip'
alias maa='mvn assembly:assembly -Dmaven.test.skip'

alias get_pass='echo -e "import string\nfrom random import choice\nprint(str().join([choice(string.ascii_letters + string.digits) for i in range(30)]))" | python3'

alias ctaghere="ack -f | grep -vE \"/(bower_components|\.tmp|dist)/\" | ctags -L - --python-kinds=-i"

disable_ssh_agent_here() {
  export SSH_AGENT_PID=""
  export SSH_AUTH_SOCK=""
}


autoload bashcompinit
bashcompinit
bindkey '^X/' _bash_complete-word

if [ -f "$HOME/.oh-my-zsh/locals.zsh" ]
    then
      source "$HOME/.oh-my-zsh/locals.zsh"
fi

bindkey -v

return_code="%(?..%{$fg[red]%}%? %{$reset_color%})"

function zle-line-init zle-keymap-select {
    RPS1="${return_code}${${KEYMAP/vicmd/-N-}/(main|viins)/-I-}"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search


PERL_MB_OPT="--install_base \"/home/bak1an/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/bak1an/perl5"; export PERL_MM_OPT;

if [ $(which direnv 2> /dev/null) ]; then
    eval "$(direnv hook zsh)"
fi

if [ -f /usr/libexec/java_home ]; then
    #list available jdks
    alias jdks="/usr/libexec/java_home -V"
    # jdk version switching - e.g. `jdk 6` will switch to version 1.6
    function jdk() {
        echo "Switching java version $1";

        requestedVersion=$1
        oldStyleVersion=8
        # Set the version
        if [ $requestedVersion -gt $oldStyleVersion ]; then
            export JAVA_HOME=$(/usr/libexec/java_home -v $1);
        else
            export JAVA_HOME=`/usr/libexec/java_home -v 1.$1`;
        fi

        echo "Setting JAVA_HOME=$JAVA_HOME"

        which java
        java -version;
    }

    # set default to java 8
    export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
fi
