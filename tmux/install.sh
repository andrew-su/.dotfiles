#!/bin/env sh

[[ -f ~/.tmux.conf ]] && mv ~/.tmux.conf{,.bak}
ln -sf $(pwd)/.tmux.conf ~/.tmux.conf
