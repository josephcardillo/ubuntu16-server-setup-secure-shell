#! /bin/bash

# Ubuntu 14.04 / 16.04 LTS
# This script will get you up and running with a secure Ubuntu 16 shell.

apt-get update && apt-get upgrade

# setup hostname
echo "The first thing you need to do is set a hostname."
sleep 2
echo
echo "A hostname is used to identify your device in an easy-to-remember format. The hostname is stored in the /etc/hostname file. Your system’s hostname should be something unique. Some people name their servers after planets, philosophers, or animals. Note that the hostname has no relationship to websites or email services hosted on it, aside from providing a name for the system itself. Your hostname should not be “www” or anything too generic."
echo
read -p "Set a hostname : " HOSTNAME
hostnamectl set-hostname $HOSTNAME
echo "The hostname you've chosen is $HOSTNAME."
sleep 2
echo "Next, you'll be prompted to enter your IP address so I can add it to your /etc/hosts file."
sleep 2
echo "The hosts file creates static associations between IP addresses and hostnames, with higher priority than DNS."
sleep 1
# Update etc/hosts file with IP address and hostname
read -p "What is your IP address? : " IP
echo "$IP   $HOSTNAME" >> /etc/hosts
echo "###############################################"
echo "Here is what it looks like in your /etc/hosts file:"
sleep 1
cat /etc/hosts
echo "###############################################"
sleep 4

# To secure the server
echo "Now it's time to add a limited user account, a/k/a your sudo user."
sleep 2
echo "Up to this point, you have accessed your Linode as the root user, which has unlimited privileges and can execute any command–even one that could accidentally disrupt your server."
sleep 3
echo "We recommend creating a limited user account and using that at all times. Administrative tasks will be done using sudo to temporarily elevate your limited user’s privileges so you can administer your server."
sleep 4

read -p "Please choose a sudo user username : " USER
adduser $USER
# Give user sudo access
adduser $USER sudo

echo "In order to secure your server -- or 'harden' your SSH access -- you will need to add your pub key."
sleep 2

if [[ ! $PUB ]]; then read -p "Please enter your SSH pubkey : " PUB; fi

#add User and sudo
echo "Making the proper directories..."
sleep 2
mkdir /home/$USER/.ssh
touch /home/$USER/.ssh/authorized_keys
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
chown $USER:$USER /home/$USER/.ssh/authorized_keys
chown $USER:$USER /home/$USER/.ssh
echo "Adding your pubkey to the /.ssh/authorized_keys file..."
echo "$PUB" > /home/$USER/.ssh/authorized_keys
sleep 2
echo "All set!"
sleep 2
echo "To further secure your server we will disable root access. Don't worry, you can still login with the sudo user you created above. This is to prevent bad guys from brute forcing your account. (That means trying to login to your account by guessing at your password until they get it.)"
sleep 3
# disable password and root over ssh
sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i -e "s/#PermitRootLogin no/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i -e "s/#PasswordAuthentication no/PasswordAuthentication no/" /etc/ssh/sshd_config
echo 'AddressFamily inet' | sudo tee -a /etc/ssh/sshd_config

echo "###############################################"
echo "Here are the changes we made to your /etc/ssh/sshd_config file:"
cat /etc/ssh/sshd_config | grep -i 'PasswordA\|root\|pub' |grep -v '#'
echo "###############################################"
sleep 5

echo "Great! Let's restart the ssh service..."
systemctl restart sshd
sleep 2

#Upgrade
apt-get update && apt-get upgrade -y
echo

echo "Almost done. Let's install some useful packages like nmap, wget, htop and iftop."

#Install packages
apt-get -y install nmap
apt-get -y install wget
apt-get -y install htop
apt-get -y install iftop

echo "Almost done. The last thing we need to do is update your timezone. Just follow the prompts."
#Set the timezone
dpkg-reconfigure tzdata
