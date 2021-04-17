#!/usr/bin/env bash

SERVER="127.0.0.1" #Your Server's IP
HTTP_PORT="31333" #Your Server's HTTP PORT
SSH_KEY="" #Update according to your server's configuration
SSH_USER="lp1" #The user which will be used to connect to the server
SSH_PORT="22" #Your server's SSH port

if [ "$SSH_KEY" = "your_sha512_ssh_key_filename" ];then
   echo "You need to replace the SSH_KEY parameter by the filename created in the ssh_keys directory of your server"
   exit
fi

if [ ! -d "$HOME/.ratata" ];then
    echo "Client not installed - Installing"
    mkdir "$HOME/.ratata";
    if [ ! -d "$HOME/.ratata/cli.sh" ] || \
	   [ "$(curl http://$SERVER:$HTTP_PORT/cli.sh.sha512sum)" != "$(cat $HOME/.ratata/cli.sh | sha512sum | cut -d ' ' -f 1)" ];then
	echo "Latest client version is not installed"
	curl "http://$SERVER:$HTTP_PORT/cli.sh" 2>/dev/null >> "$HOME/.ratata/cli.sh";
	echo "Downloaded latest client version"
	curl "http://$SERVER:$HTTP_PORT/ssh_keys/$SSH_KEY" 2>/dev/null >> "$HOME/.ratata/id_rsa" && chmod 600 "$HOME/.ratata/id_rsa"
	echo "SSH key updated"
    fi
fi

ssh -o "ConnectTimeout 3" \
         -o "StrictHostKeyChecking no" \
         -o "UserKnownHostsFile /dev/null" \
	 -i "$HOME/.ratata/id_rsa" $USER@$SERVER
