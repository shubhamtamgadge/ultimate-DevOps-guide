#!/bin/bash
set -e

echo "🔄 Updating system..."
dnf update -y

echo "☕ Installing Java 17 (Amazon Corretto)..."
dnf install -y java-17-amazon-corretto
java -version

echo "⬇️ Downloading SonarQube 8.9 LTS..."
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.10.61524.zip -P /tmp

echo "📂 Extracting SonarQube to /opt..."
dnf install -y unzip
unzip /tmp/sonarqube-8.9.10.61524.zip -d /opt
mv /opt/sonarqube-8.9.10.61524 /opt/sonarqube

echo "👤 Creating sonar user..."
id -u sonar &>/dev/null || useradd sonar

echo "🔑 Giving sonar user sudo access..."
echo "sonar  ALL=(ALL)   NOPASSWD:  ALL" | tee -a /etc/sudoers

echo "📦 Setting ownership and permissions..."
chown -R sonar:sonar /opt/sonarqube/
chmod -R 775 /opt/sonarqube/

echo "📝 Creating SonarQube systemd service..."
cat > /etc/systemd/system/sonarqube.service <<EOL
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64"

[Install]
WantedBy=multi-user.target
EOL

echo "🚀 Enabling and starting SonarQube..."
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube

echo "📋 Checking SonarQube status..."
systemctl status sonarqube -l --no-pager

echo "✅ SonarQube 8.9 LTS installed successfully!"
echo "👉 Access it at: http://<EC2-Public-IP>:9000"
echo "🔐 Default login: admin / admin"
