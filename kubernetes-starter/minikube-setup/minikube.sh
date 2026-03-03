
MINIKUBE INSTALLATION IN AMAZON LINUX 2023:
Type: c7i-flex-large (2-CPU and 4-GB-RAM) 

# 1. Install Docker

sudo yum update -y
sudo yum install docker -y


# 2. Start and Enable Docker

sudo systemctl start docker
sudo systemctl enable docker


# 3. Add Current user to docker group

sudo usermod -aG docker $USER

sudo systemctl status docker 

# 4. Exit from current session and re-connect
exit
press 'R' to re-connect  

# 5. Download and Install Kubectl Client
sudo curl --silent --location -o /usr/local/bin/kubectl \
https://dl.k8s.io/release/$(curl --silent --location https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

sudo chmod +x /usr/local/bin/kubectl

kubectl version --client 

# 6. Download and Install Minikube Software
cd ~
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube 

# 7. Start Minikube software 
minikube start 

# 8. Check Installation status using these commands$
 minikube status
 minikube version
 kubectl version --short
 kubectl cluster-info
 kubectl get nodes 

# 9. Create Pod using command

---- Kubectl run <pod-name> --image <image-name>--port <container-port> -----

kubectl run springboot-app --image=genieashwani/springboot-app:v1 --port=8080 


# ---------------------------------------------------------------------------------

### SOME COMMAND TO WORK WITH PODS

# get pod info
kubectl get pods

# get pod ip address
kubectl get pods -o wide 

#describe pod
kubectl describe pod (pod-name)
kubectl describe pod springboot-app

#check logs
kubectl logs springboot-app

#delete pod
kubectl delete pod springboot-app


