#!/usr/bin/env bash

cd /home/ubuntu/

EJABBERD_BRANCH="TempBans_CHN"

requirements="make libexpat1 libexpat1-dev libyaml-0-2 libyaml-dev \
erlang openssl zlib1g zlib1g-dev libssl-dev libpam0g autoconf g++"

echo "-------------------------Add User-------------------------"
sudo useradd -m -b /var/lib -r ejabberd

echo "-------------------------Update-------------------------"
sudo apt-get update

echo "-------------------------Install requirements-------------------------"
sudo apt-get install -y $requirements

echo "-------------------------Clean up-------------------------"
rm -rf ejabberd
sudo rm -rf /usr/local/lib/ejabberd-*

echo "-------------------------Get build from github-------------------------"
git clone https://github.com/ccpgames/ejabberd.git \
       --branch $EJABBERD_BRANCH --single-branch --depth=1

echo "-------------------------Setup ejabberd build-------------------------"
cd ejabberd
chmod +x autogen.sh
./autogen.sh
./configure --enable-user=ejabberd
make
sudo make install

echo "Setup done!"