# Join cluster
# Paste the join command from master:

sudo kubeadm join <MASTER_IP>:6443 \
--token <TOKEN> \
--discovery-token-ca-cert-hash sha256:<HASH>

# Verify from master
kubectl get nodes