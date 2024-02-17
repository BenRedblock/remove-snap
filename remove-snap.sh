#!/bin/bash


# Define the color green
GREEN='\033[0;32m'

# Define the color red
RED='\033[0;31m'

# Define the color reset
RESET='\033[0m'

echo -e "${GREEN}Remove Snap${RESET}"
sleep 2s



if [ "$(id -u)" -ne  0 ]; then
    # If not run as root, re-execute with sudo
	
    echo -e "${RED}This script must be run as root. Re-executing with sudo...${RESET}"
    sudo "$0"
    exit  99
fi
echo -e "${RED}This will also uninstall the snap version of firefox.${RESET}"
read -p "Are you sure you want to remove all installed snaps? (y/n): " answer

# Process the answer
if [[ $answer == [yY] ]]; then
    echo -e "${GREEN}removing snaps...${RESET}"
else
    echo -e "${GREEN}exiting...${RESET}"
	exit 1
fi

# Get the list of installed snaps
installed_snaps=$(snap list | awk 'NR>1 {print $1}')



# for (( i=1; i<=4; i++ )); do
until [ ${#installed_snaps[@]} -eq  0 ]
do
	if [ -z "$installed_snaps" ]; then
		# Exit the script or continue with other tasks
		break
	else
		echo -e "${GREEN}uninstalling following snaps:${RESET}"
		echo -e "$installed_snaps"
		sleep 5s
	fi

	for snap_name in $installed_snaps; do
		# Attempt to remove the snap
		snap remove $snap_name
	done
	installed_snaps=$(snap list | awk 'NR>1 {print $1}')
done
echo -e "${GREEN}Disabling 'snapd' Daemon...${RESET}"
sleep 2s

sudo systemctl stop snapd

sudo systemctl disable snapd

sudo systemctl mask snapd

echo -e "${GREEN}Uninstalling 'snapd'${RESET}"
sleep 2s

sudo apt purge snapd -y

echo -e "${GREEN}Stopping snap from automatically installing again${RESET}"
sleep 2s

sudo apt-mark hold snapd

echo -e "${GREEN}Preventing future snap installation${RESET}"
sleep 2s

# Add a preference to prevent snapd from being installed automatically
cat << EOF | sudo tee -a /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# Change the ownership of the preferences file to root
sudo chown root:root /etc/apt/preferences.d/no-snap.pref

#  Remove snap package directories
echo -e "${GREEN}removing snap package directories${RESET}"
sleep 2s

rm -rf ~/snap/
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd

read -p "${GREEN}Do you want to install flatpak? (y/n): ${RESET}" answer

# Process the answer
if [[ $answer == [yY] ]]; then
    echo -e "${GREEN}Installing flatpak${RESET}"
else
    echo -e "${GREEN}exiting...${RESET}"
	exit 1
fi

apt update

apt install flatpak -y

read -p "${GREEN}Do you want to install the 'gnome-software-plugin-flatpak' package? (y(recommended)/n): ${RESET}" answer

if [[ $answer == [nN] ]]; then
	echo -e "${GREEN}continuing without the 'gnome-software-plugin-flatpak'${RESET}"
else
	sudo apt install gnome-software-plugin-flatpak -y
fi

echo -e "${GREEN}Adding Flathub repository${RESET}"

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo -e "${GREEN}Flatpak has been added. You might want to restart your system${RESET}"