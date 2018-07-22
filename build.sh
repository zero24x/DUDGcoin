#!/bin/bash

set -e

date

#################################################################
# Update Ubuntu and install prerequisites for running DudgCoin   #
#################################################################
sudo apt-get update
#################################################################
# Build DudgCoin from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building DudgCoin           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# By default, assume running within repo
repo=$(pwd)
file=$repo/src/dudgcoind
if [ ! -e "$file" ]; then
	# Now assume running outside and repo has been downloaded and named dudgcoin
	if [ ! -e "$repo/dudgcoin/build.sh" ]; then
		# if not, download the repo and name it dudgcoin
		git clone https://github.com/dudgcoind/source dudgcoin
	fi
	repo=$repo/dudgcoin
	file=$repo/src/dudgcoind
	cd $repo/src/
fi
make -j$NPROC -f makefile.unix

cp $repo/src/dudgcoind /usr/bin/dudgcoind

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.dudgcoin
if [ ! -e "$file" ]
then
        mkdir $HOME/.dudgcoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | tee $HOME/.dudgcoin/dudgcoin.conf
file=/etc/init.d/dudgcoin
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo dudgcoind' | sudo tee /etc/init.d/dudgcoin
        sudo chmod +x /etc/init.d/dudgcoin
        sudo update-rc.d dudgcoin defaults
fi

/usr/bin/dudgcoind
echo "DudgCoin has been setup successfully and is running..."

