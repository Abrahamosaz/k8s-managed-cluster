# Initialize cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16


# Configure kubectl for your user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Install CNI (Networking) – Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml


# Verify master node
kubectl get nodes


# Get join command (IMPORTANT)
kubeadm token create --print-join-command

# Example output:
kubeadm join 192.168.1.10:6443 --token abc123.xyz \
--discovery-token-ca-cert-hash sha256:xxxxx



# Reset cluster (if needed)
sudo kubeadm reset -f