#!/usr/bin/env bash
tmux new-session -d -s dev
tmux rename-window 'edit'
tmux send-keys 'hx .' C-m
tmux split-window -v
tmux send-keys 'just watch' C-m
tmux split-window -h
tmux send-keys 'just debug' C-m
tmux select-pane -t 0
tmux attach-session -t dev
