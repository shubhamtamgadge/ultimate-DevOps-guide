# ------------------------------
# Update system packages
# ------------------------------

# Updates package list from Ubuntu repositories
sudo apt-get update -y

# Installs required dependencies:
# curl → to download files
# apt-transport-https → allow apt to use HTTPS repos
# ca-certificates → verify SSL certificates
# gnupg → manage GPG keys
sudo apt-get install -y curl apt-transport-https ca-certificates gnupg


# ------------------------------
# Load Required Kernel Modules
# ------------------------------

# Creates a config file to load required kernel modules at boot
# overlay → required for container filesystem
# br_netfilter → allows iptables to see bridged traffic
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Loads overlay module immediately
sudo modprobe overlay

# Loads bridge netfilter module immediately
sudo modprobe br_netfilter


# ------------------------------
# Configure Networking (Sysctl)
# ------------------------------

# Enables required networking settings for Kubernetes
# bridge-nf-call-iptables → allow iptables to manage bridged traffic
# ip_forward → allow forwarding of packets between interfaces
# bridge-nf-call-ip6tables → same for IPv6
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl settings without reboot
sudo sysctl --system


# ------------------------------
# Install and Configure Containerd
# ------------------------------

# Installs containerd (container runtime used by Kubernetes)
sudo apt-get install -y containerd

# Creates containerd configuration directory
sudo mkdir -p /etc/containerd

# Generates default containerd configuration file
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Enables systemd cgroup driver (recommended for kubeadm setup)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restarts containerd to apply changes
sudo systemctl restart containerd

# Enables containerd to start automatically on boot
sudo systemctl enable containerd


# ------------------------------
# Disable Swap (MANDATORY)
# ------------------------------

# Disables swap temporarily (Kubernetes requires swap OFF)
sudo swapoff -a

# Permanently disables swap by commenting swap entry in fstab
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# ------------------------------
# Add Kubernetes Repository
# ------------------------------

# Creates directory to store Kubernetes GPG keys
sudo mkdir -p /etc/apt/keyrings

# Sets correct permissions
sudo chmod 755 /etc/apt/keyrings

# Downloads Kubernetes GPG key and stores it
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Adds Kubernetes official repository to apt sources
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF


# ------------------------------
# Install Kubernetes Components
# ------------------------------

# Updates package list again after adding repo
sudo apt-get update

# Installs:
# kubelet → runs pods on node
# kubeadm → used to initialize cluster
# kubectl → command line tool
sudo apt-get install -y kubelet kubeadm kubectl

# Prevents automatic updates of Kubernetes packages
sudo apt-mark hold kubelet kubeadm kubectl

# Enables kubelet service
sudo systemctl enable kubelet


# ------------------------------
# Initialize Kubernetes Cluster (Master Node)
# ------------------------------

# Initializes the control plane
# --pod-network-cidr must match network plugin (Calico uses 192.168.0.0/16 here)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16


# ------------------------------
# Configure kubectl for Current User
# ------------------------------

# Creates .kube directory
mkdir -p $HOME/.kube

# Copies admin kubeconfig file
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Changes ownership so normal user can use kubectl
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# ------------------------------
# Install Calico Network Plugin
# ------------------------------

# Installs Calico CNI plugin (required for pod networking)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml


# ------------------------------
# Print Worker Join Command
# ------------------------------

echo "✅ Kubernetes Master Node Setup Complete!"
echo "👉 Use the command below to join worker nodes:"

# Generates join token command for worker nodes
kubeadm token create --print-join-command
