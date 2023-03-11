#!/bin/bash

# TODO
# 1-Get the commands used to run the server the organize it there
# 2-Use heredoc or so to write out to the config files
# 3-Add option to pick between Debian-based or RHEL-based configs
# 4-Testing and debugging


update_install () {
	sudo yum install httpd && \
	sudo systemctl start httpd && \
	sudo systemctl enable httpd
}


firewall_port () {
	sudo sh -c "firewall-cmd --permanent --zone=public --add-service=http && firewall-cmd --permanent --zone=public --add-service=https && firewall-cmd --reload"
}








echo "This Bash script is used to install and configure apache2/httpd webserver on your machine running RedHat Enterprise Linux 7"
sleep 0.5

echo "Step 1: Installing, starting and enabling at startup Apache2..."
update_install
if [[ $? -eq 0 ]]; then
	echo "Apache2 has been successfully installed!!"
else
	echo "An Error has occured while installing Apache2"
fi


echo "Step 2: Allowing Apache2 in firewalld if you've firewalld on..."
read -p "Do you have firewalld on? (y/n) " ans_firewall
if [[ $ans_firewall == "y"  || $ans_firewall == "Y" ]]; then
	firewall_port
elif [[ $ans_firewall == "n" || $ans_firewall == "N" ]]; then
       break
fi


