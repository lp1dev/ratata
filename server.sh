#!/usr/bin/env bash
PORT=31333

if [ -d ssh_keys ];then
   echo 
   read -p "SSH keys have been found, do you want to regenerate them? (y/N) : " CONTINUE;
   if [[ $CONTINUE == [yY] ]];then
       rm -frv ssh_keys;
       mkdir ssh_keys
       RAND_SUM=$(dd if=/dev/urandom bs=512 count=1 2> /dev/null| sha512sum -b | cut -d ' ' -f 1)
       ssh-keygen -P '' -f ssh_keys/$RAND_SUM
       CLI=$(cat cli.sh)
       echo "${CLI/SSH_KEY=[a-Z|0-9]+/SSH_KEY=$RAND_SUM}"
   fi;
   python3 -m http.server $PORT
fi;
