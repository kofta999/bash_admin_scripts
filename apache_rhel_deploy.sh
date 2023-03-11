#!/bin/bash

# TODO
# 1-Get the commands used to run the server the organize it there
# 2-Use heredoc or so to write out to the config files
# 3-Add option to pick between Debian-based or RHEL-based configs
# 4-Testing and debugging


update_install () {
	sudo yum install httpd -y > /dev/null && \
	sudo systemctl start httpd && \
	sudo systemctl enable httpd
}


firewall_port () {
	sudo sh -c "firewall-cmd --permanent --zone=public --add-service=http && firewall-cmd --permanent --zone=public --add-service=https && firewall-cmd --reload" > /dev/null
}

copy_static () {
	sudo cp ./$1 /var/www/$1 && \
	sudo chown -R apache:apache /var/www/$1 && \
	sudo chmod 755 /var/www/$1
}

create_config () {
	cat <<- EOF | sudo tee /etc/httpd/sites-avaliable/$1.conf > /dev/null
	<VirtualHost *:80>
        ServerName $2
	ServerAlias www.$2
        DocumentRoot /var/www/$4

        ServerAdmin $3
        ErrorLog /var/log/httpd/$1_error.log
        CustomLog /var/log/httpd/$1_access.log combined

</VirtualHost>
EOF
}

enable_site () {
	ln -s /etc/httpd/sites-avaliable/$1.conf /etc/httpd/sites-enabled/$1.conf
	sudo echo "Include /etc/httpd/sites-enabled" >> /etc/httpd/conf/httpd.conf
	sudo systemctl reload-or-restart httpd
}



echo "This Bash script is used to install and configure apache2/httpd webserver on your machine running RedHat-based Linux."
echo "You should run the script next to the website directories you want to copy."
sleep 1.5


echo "Step 1/6: Installing, starting and enabling at startup Apache2..."
sleep 0.5

update_install

if [[ $? -eq 0 ]]; then
	echo "Apache2 has been successfully installed!!"
	sleep 0.5
else
	echo "An Error has occured while installing Apache2."
	sleep 0.5
	exit
fi


echo "Step 2/6: Allowing Apache2 in firewalld if you've firewalld on..."
sleep 0.5

read -p "Do you have firewalld on? (y/n) " ans_firewall

if [[ $ans_firewall == "y"  || $ans_firewall == "Y" ]]; then
	firewall_port

	if [[ $? -eq 0 ]]; then
		echo "Apache2 is successfully allowed in firewalld!"
		sleep 0.5
	else
		echo "An Error has occured while allowing Apache2 in firewalld."
		sleep 0.5
		exit
	fi

elif [[ $ans_firewall == "n" || $ans_firewall == "N" ]]; then
      :

else
	echo "Invalid option, exiting..."
	sleep 0.5
	exit
fi


echo "Step 3/6: Copying your static website to /var/www/<YOUR_WEBSITE>..."
sleep 0.5
# TODO: Update it to a for loop with a list of sites to be copied.

read -p "Enter the name of your website directory that will be copied to /var/www" site_name

copy_static $site_name

if [[ $? -eq 0 && -d /var/www/$site_name ]]; then
	echo "The website directory has been successfully copied to /var/www !"
	sleep 0.5
else
	echo "An error has occured while copying the website directory to /var/www."
	sleep 0.5
	exit
fi


echo "Step 4/6: Making sites-avaliable and sites-enabled directories in /etc/httpd ..."
sleep 0.5

sudo mkdir /etc/httpd/sites-avaliable && sudo mkdir /etc/httpd/sites-enabled

if [[ -d /etc/httpd/sites-avaliable && -d /etc/httpd/sites-enabled ]]; then
	echo "Created directories successfully!"
	sleep 0.5
else
	echo "An error has occured while creating the directories."
	sleep 0.5
	exit
fi


echo "Step 5/6: Adding the site's config file to sites-avaliable directory..."
sleep 0.5

read -p "Enter the name of the config file" config_name
read -p "Enter the website's domain name 'example.com'. " domain_name
read -p "Enter the server admin's email address. " email_name

create_config $config_name $domain_name $email_name $site_name

if [[ $? -eq 0 ]]; then
	echo "Created config file successfully!"
	sleep 0.5
else
	echo "An error has occured while creating the config, exiting..."
	sleep 0.5
	exit
fi


echo "Step 6/6: enabling the site in sites-enabled directory..."
sleep 0.5

enable_site $config_name

if [[ -e /etc/httpd/sites-enabled/$config_name.conf ]]; then
	echo "The site is successfully enabled!"
	sleep 0.5
else
	echo "An error has occured while enabling the site, exiting..."
	sleep 0.5
	exit
fi

echo "Congrats!!! Your site now is up and running!"
sleep 1
