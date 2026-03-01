# ------------------------------
# Update system packages
# ------------------------------

# Updates the package list from Ubuntu repositories
sudo apt-get update -y

# Installs required dependencies:
# curl → download files
# apt-transport-https → allow apt to use HTTPS repos
# ca-certificates → SSL verification
# gnupg → manage GPG keys
sudo apt-get install -y curl apt-transport-https ca-certificates gnupg


# ------------------------------
# Load Required Kernel Modules
# ------------------------------

# Creates config file to load required modules at boot
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
# bridge-nf-call-iptables → allow iptables to inspect bridged traffic
# ip_forward → allow packet forwarding
# bridge-nf-call-ip6tables → same for IPv6
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Applies sysctl settings immediately
sudo sysctl --system


# ------------------------------
# Install and Configure Containerd
# ------------------------------

# Installs containerd (container runtime used by Kubernetes)
sudo apt-get install -y containerd

# Creates configuration directory
sudo mkdir -p /etc/containerd

# Generates default containerd configuration file
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Enables systemd cgroup driver (recommended for kubeadm clusters)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restarts containerd service
sudo systemctl restart containerd

# Enables containerd to start automatically at boot
sudo systemctl enable containerd


# ------------------------------
# Disable Swap (MANDATORY)
# ------------------------------

# Disables swap temporarily (Kubernetes requires swap OFF)
sudo swapoff -a

# Permanently disables swap by commenting it in fstab
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# ------------------------------
# Add Kubernetes Repository
# ------------------------------

# Creates directory to store Kubernetes GPG key
sudo mkdir -p /etc/apt/keyrings

# Sets correct permissions
sudo chmod 755 /etc/apt/keyrings

# Downloads Kubernetes official GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Adds Kubernetes repository to apt sources
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF


# ------------------------------
# Install Kubernetes Components
# ------------------------------

# Updates package list after adding repo
sudo apt-get update

# Installs:
# kubelet → runs pods on the worker node
# kubeadm → used to join the cluster
# kubectl → optional, useful for troubleshooting
sudo apt-get install -y kubelet kubeadm kubectl

# Prevents automatic updates of Kubernetes packages
sudo apt-mark hold kubelet kubeadm kubectl

# Enables kubelet service
sudo systemctl enable kubelet


# ------------------------------
# Worker Node Ready to Join
# ------------------------------

echo "✅ Worker Node Setup Complete!"
echo "👉 Now run the 'kubeadm join ...' command from your Master Node here."
