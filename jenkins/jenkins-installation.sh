#!/bin/bash
set -e

echo "=== Updating system packages ==="
sudo yum upgrade -y

echo "=== Installing Java 21 (Amazon Corretto) ==="
sudo yum install -y java-21-amazon-corretto

echo "=== Adding Jenkins repo ==="
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "=== Installing Jenkins ==="
sudo yum install -y jenkins

echo "=== Installing Maven ==="
sudo yum install -y maven

echo "=== Installing Git ==="
sudo yum install -y git

echo "=== Reloading systemd and enabling Jenkins service ==="
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "=== Checking Jenkins status ==="
sudo systemctl status jenkins --no-pager || true

echo "=== Opening firewall for port 8080 (if firewalld exists) ==="
if command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
    sudo firewall-cmd --reload
else
    echo "No firewalld detected, skipping firewall step."
fi

echo "=== Installation Summary ==="
java -version
mvn -version
git --version

echo "=== Jenkins installation complete ==="
echo "Open your browser at: http://<YOUR-SERVER-IP>:8080/"
echo "Initial admin password (copy this):"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
