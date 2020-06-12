#!/usr/bin/env bash
apt update
apt upgrade -y
apt install python3-pip unzip language-pack-nl -y

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

curl -sL https://deb.nodesource.com/setup_13.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

apt update
apt install -y nodejs yarn

yarn global add wetty
echo "# systemd unit file
#
# place in /etc/systemd/system
# systemctl enable wetty.service
# systemctl start wetty.service

[Unit]
Description=Wetty Web Terminal
After=network.target

[Service]

ExecStart=/usr/local/bin/wetty -p 3000

[Install]
WantedBy=multi-user.target"> /etc/systemd/system/wetty.service
systemctl enable wetty
systemctl start wetty

wget "https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip" -O /root/terraform.zip
unzip /root/terraform.zip -d /root/
mv /root/terraform /usr/local/bin/terraform
wget https://github.com/yaron/tf-workshop/archive/master.zip -O /root/workshop.zip
unzip /root/workshop.zip -d /etc/skel
mkdir /etc/skel/.ssh

# Enable the use of passwords to ssh login.
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
service ssh restart

for i in {0..31}; do
    useradd -m -s /bin/bash "tfuser$i"
    echo "tfuser$i:tfpass$i" | chpasswd
    echo "export TF_VAR_user=\"tfuser$i\"" >> /home/tfuser$i/.bashrc
    echo "export TF_VAR_resource_group=\"terraformWorkshop\"" >> /home/tfuser$i/.bashrc
    sudo -u tfuser$i ssh-keygen -b 2048 -t rsa -f /home/tfuser$i/.ssh/id_rsa -q -N ""
    sudo -H -u tfuser$i az login -u tfWorkshop$i@harryfranzenkpn.onmicrosoft.com -p tfWorkshoppass$i
done
