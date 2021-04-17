#!/usr/bin/env bash

SERVER="127.0.0.1" #Your Server's IP
PORT="31333" #Your Server's PORT
SSH_KEY="your_sha512_ssh_key_filename"

if [ ! -d "$HOME/.ratata" ];then
    echo "Client not installed - Installing"
    mkdir "$HOME/.ratata";
    curl "http://$SERVER:$PORT/cli.sh" 2>/dev/null >> "$HOME/.ratata/cli.sh";
    echo "Downloaded latest client version"
    curl "http://$SERVER:$PORT/ssh_keys/$SSH_KEY" 2>/dev/null >> "$HOME/.ratata/id_rsa" && chown 600 "$HOME/.ratata/id_rsa"
fi
