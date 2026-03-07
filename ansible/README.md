##----------in both master node and manage nodes -------------

sudo useradd ansible
sudo passwd ansible


##provide suoder permissions 
#both

sudo visudo 
paste this in file --> ansible ALL=(ALL) NOPASSWD: ALL
#ctrl o + enter + ctrl x

##set pass auth YES
#both

sudo vi /etc/ssh/sshd_config
PasswordAuthentication yes

esc :wq

#both
sudo systemctl restart sshd
sudo su - ansible

##----------------IN MASTER NODE ONLY-------------------

#generate key in MASTER
ssh-keygen

cd /home/ansible/
cd .ssh/
ls -l
cd ~

#COPY PUBLIC KEY TO MANAGE NODES
ssh-copy-id ansible@{---node-ip----}

ansible installation (MASTER)
sudo yum install python3 -y
sudo yum install python-pip -y

pip install ansible --user

ansible --version

sudo mkdir -p /etc/ansible
sudo chown ansible:ansible ansible/
cd ~ 

sudo vi /etc/ansible/ansible.cfg


sudo vi /etc/ansible/hosts







