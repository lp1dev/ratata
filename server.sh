#!/usr/bin/env bash

HOST="127.0.0.1"
PORT=31333

if [ ! -d ssh_keys ];then
    echo "Generating new ssh keypair"
    mkdir ssh_keys
    RAND_SUM=$(dd if=/dev/urandom bs=512 count=1 2> /dev/null| sha512sum -b | cut -d ' ' -f 1)
    ssh-keygen -P '' -f ssh_keys/$RAND_SUM
    echo "Installing new key"
    cat "ssh_keys/$RAND_SUM.pub" >> "$HOME/.ssh/authorized_keys"
    
fi

cd ssh_keys && python3 -m http.server --bind $HOST $PORT
