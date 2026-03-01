#!/bin/bash
set -e

echo "🚀 Starting Kubernetes Worker Node Setup (Ubuntu 22.04 / 24.04)"

# Update and dependencies
sudo apt-get update -y
sudo apt-get install -y curl apt-transport-https ca-certificates gnupg

# Kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl settings
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

# Containerd install and config
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Add Kubernetes repo
sudo mkdir -p /etc/apt/keyrings
sudo chmod 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF

# Install kubeadm, kubelet, kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet

echo "✅ Worker Node Setup Complete!"
echo "👉 Now run the 'kubeadm join ...' command from your Master Node here."


apiVersion: apps/v1
kind: deployment
metadata:
  name: sb-deployment
  labels:
    app: sb-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sb-app
  template:
    metadata:
      labels:
        app: sb-app
    spec:
      containers:
        - name: sb-container
          image: genieashwani/springboot-app:v1
          ports:
            - containerPort: 8080




apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myrs
spec:
  replicas: 3
  selector:
    matchLabels:
      apptype: web-backend
  template:
    metadata:
      labels:
        apptype: web-backend
    spec:
        containers:
        - name: mycontainer
            image: nginx:latest
            ports:
            - containerPort: 80
