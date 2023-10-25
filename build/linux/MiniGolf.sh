#!/bin/sh
echo -ne '\033c\033]0;MiniGolf\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/MiniGolf.x86_64" "$@"
