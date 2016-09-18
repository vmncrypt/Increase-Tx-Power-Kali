#!/bin/bash
#Filename: IncreaseTxPower.sh
#Description: Assumes you're running Kali 2.0 - 
#Installs required dependencies, increases txpower, sets region to BO

echo "Installing dependencies"
apt-get update
apt-get install libnl-3-dev libgcrypt11-dev libnl-genl-3-dev -y
apt-get install pkg-config -y

cd ~/Desktop
echo "Downloading required files"
wget http://kernel.org/pub/software/network/crda/crda-3.18.tar.xz
wget https://www.kernel.org/pub/software/network/wireless-regdb//wireless-regdb-2016.06.10.tar.xz

echo "Extracting files" 
unxz crda-3.18.tar.xz
unxz wireless-regdb-2016.06.10.tar.xz
tar -xf crda-3.18.tar
tar -xf wireless-regdb-2016.06.10.tar

echo "Making some changes"
cd wireless-regdb-2016.06.10
replace "(2402 - 2482 @ 40), (20)" "(2402 - 2482 @ 40), (30)" -- db.txt
make
cd /lib/crda
mv regulatory.bin regulatoryOLD.bin
cd ~/Desktop/wireless-regdb-2016.06.10
cp regulatory.bin /lib/crda
cp *.pem ~/Desktop/crda-3.18/pubkeys
cd /lib/crda/pubkeys
cp benh@debian.org.key.pub.pem ~/Desktop/crda-3.18/pubkeys
cd ~/Desktop/crda-3.18
replace "" "" -- Makefile
sed 's,/usr/lib/crda/regulatory.bin,/lib/crda/regulatory.bin,g' < Makefile > Makefile.new
mv -f Makefile.new Makefile
sleep 3
make
sleep 3
make install

echo "Increasing Tx Power"
ifconfig wlan0 down
iw reg set BO
ifconfig wlan0 up
iwconfig

echo "Done!"
