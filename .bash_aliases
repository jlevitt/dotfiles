#!/bin/bash
# ~/.bash_aliases

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -AlF --color=auto'
alias l='ls'
alias v='vim'
alias tf='tail -f'
if command -v ack-grep >/dev/null; then
  alias ack='ack-grep'
fi
# Enables alias expansion while using sudo
alias sudo='sudo '
alias como-webhooks="cd $GOPATH/src/github.com/omnivore/como-webhooks"
alias giganto="cd $GOPATH/src/github.com/omnivore/giganto"
alias flush-redis="redis-cli -p 16390 flushdb"
alias a=". ./env/bin/activate"
alias d=deactivate

# Titanoboa
alias api="cd om/api-v1.0"
alias tasks="cd om/tasks"
alias t="cd ../.."
alias idt="pip install pipdeptree"
alias dt="pipdeptree"

function c() { curl -vvv $@; echo; }
