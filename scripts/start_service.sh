#!/usr/bin/env bash

URL="http://169.254.169.254/latest/meta-data/public-ipv4"

ipv4=$(curl ${URL})

cd /home/ubuntu/ejabberd/

if ps -C inet_gethost &> /dev/null
then
	sudo ejabberdctl stop
fi

sudo ejabberdctl start

echo "Service started"

#------------------------------------------

ejabberdctl register testuser1 $ipv4 pass123
ejabberdctl register testuser2 $ipv4 pass123


