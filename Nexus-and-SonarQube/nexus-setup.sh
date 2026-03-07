#!/bin/bash
set -e

echo "🔄 Updating system..."
sudo dnf update -y

echo "☕ Installing Java 21 (Amazon Corretto)..."
sudo dnf install -y java-21-amazon-corretto
java -version

echo "⬇️ Downloading Nexus Repository OSS 3.83.2-01..."
cd /tmp
wget https://download.sonatype.com/nexus/3/nexus-3.90.0-21-linux-x86_64.tar.gz -O nexus.tar.gz

echo "📂 Extracting Nexus to /opt..."
sudo tar -xvzf nexus.tar.gz -C /opt
sudo ln -sfn /opt/nexus-3.90.0-21 /opt/nexus   # symlink for easy upgrades

echo "👤 Creating nexus user..."
id -u nexus &>/dev/null || sudo useradd nexus

echo "📦 Setting ownership on Nexus installation..."
sudo chown -R nexus:nexus /opt/nexus-3.90.0-21 /opt/nexus

echo "📦 Creating Nexus data directory..."
sudo mkdir -p /opt/sonatype-work/nexus3
sudo chown -R nexus:nexus /opt/sonatype-work

echo "⚙️ Configuring Nexus to run as nexus user..."
echo "run_as_user=\"nexus\"" | sudo tee /opt/nexus/bin/nexus.rc

echo "📝 Creating Nexus systemd service..."
sudo bash -c "cat > /etc/systemd/system/nexus.service <<EOL
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort
Environment=JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto

[Install]
WantedBy=multi-user.target
EOL"

echo "🚀 Enabling and starting Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

echo "📋 Checking Nexus status..."
sudo systemctl status nexus -l --no-pager

echo "✅ Nexus Repository Manager installed successfully!"
echo "👉 Access it at: http://<EC2-Public-IP>:8081"
echo "🔐 Default login: admin / \$(cat /opt/sonatype-work/nexus3/admin.password)"
