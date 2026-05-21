#!/bin/bash

for socket in $XDG_RUNTIME_DIR/nvim.* ; do
  nvim --server "$socket" --remote-expr 'execute("set background='"$1"'")'
done
