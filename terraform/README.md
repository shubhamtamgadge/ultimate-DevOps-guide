go to google and search "terraform installation" ---> select the os type {if default amazon
select the amaxon linux 2023 ---> copy below commands}

**switch to root user first**
```bash
sudo su - 
```
```bash
sudo dnf install -y dnf-plugins-core
```

```bash
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
```

```bash
sudo dnf -y install terraform
```
---------------- Install successfully ----------------

**check version**
```bash
terraform -v
```
