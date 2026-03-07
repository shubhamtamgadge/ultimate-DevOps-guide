
# **Ansible Setup (Master & Managed Nodes)**

This guide explains how to configure **Ansible Master Node** and **Managed Nodes** with SSH access and install Ansible on the master server.

---

# **1. Create Ansible User (Both Master & Managed Nodes)**

Run the following commands on **both the master node and managed nodes**.

```bash
sudo useradd ansible
sudo passwd ansible
```

---

# **2. Provide Sudo Permissions (Both Nodes)**

Open the sudoers configuration file.

```bash
sudo visudo
```

Add the following line inside the file:

```bash
ansible ALL=(ALL) NOPASSWD: ALL
```

Save and exit:

```
CTRL + O → ENTER → CTRL + X
```

---

# **3. Enable Password Authentication for SSH (Both Nodes)**

Edit the SSH configuration file.

```bash
sudo vi /etc/ssh/sshd_config
```

Find and update the following line:

```bash
PasswordAuthentication yes
```

Save and exit:

```
ESC :wq
```

Restart the SSH service.

```bash
sudo systemctl restart sshd
```

Switch to the ansible user.

```bash
sudo su - ansible
```

---

# **4. Generate SSH Key (Master Node Only)**

Generate an SSH key on the **Master Node**.

```bash
ssh-keygen
```

Check the SSH directory.

```bash
cd /home/ansible/
cd .ssh/
ls -l
```

Return to the home directory.

```bash
cd ~
```

---

# **5. Copy Public Key to Managed Nodes**

Copy the SSH public key from **Master Node → Managed Nodes**.

```bash
ssh-copy-id ansible@<NODE-IP>
```

---

# **6. Install Ansible (Master Node Only)**

Install required dependencies.

```bash
sudo yum install python3 -y
```

```bash
sudo yum install python-pip -y
```

Install Ansible.

```bash
pip install ansible --user
```

Verify the installation.

```bash
ansible --version
```

---

# **7. Create Ansible Configuration Directory**

Create the Ansible directory.

```bash
sudo mkdir -p /etc/ansible
```

Change ownership.

```bash
sudo chown ansible:ansible /etc/ansible
```

Go back to the home directory.

```bash
cd ~
```

---

# **8. Configure Ansible**

Edit the Ansible configuration file.

```bash
sudo vi /etc/ansible/ansible.cfg
```

press gg to go on first line

in defauld uncomment inventory

```bash
[defaults]
#some basic default values...

inventory      = /etc/ansible/hosts      <------ uncomment this
```

Edit the inventory file.

```bash
sudo vi /etc/ansible/hosts
```

---

# **Setup Complete**

Your **Ansible Master Node** is now configured and ready to manage **Managed Nodes**.


