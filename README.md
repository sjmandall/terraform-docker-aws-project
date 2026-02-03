End-to-End Kubernetes on AWS: Automated Deployment, Observability, and CI/CD

This repository documents a production-style, self-managed Kubernetes implementation on AWS EC2. The project demonstrates how a real application can be built, containerized, deployed, observed, and continuously delivered without using managed services like EKS, relying instead on core cloud and Kubernetes primitives.

The work reflects real-world DevOps engineering: dealing with infrastructure constraints, debugging networking and runtime failures, stabilizing a cluster, and building reliable automation rather than following a scripted tutorial.

---

Project Overview

This system delivers:

- Infrastructure as Code using Terraform
- A two-node kubeadm-based Kubernetes cluster
- containerd as the container runtime with systemd cgroups enabled
- Calico CNI for pod networking
- A containerized web application deployed via:
   - Kubernetes Deployment
   - NodePort Service
   - Optional NGINX Ingress
- Cluster observability using Prometheus + Grafana (Helm-based)
- Automated build-and-deploy pipeline using GitHub Actions + Docker Hub

The result is a working cloud-native application stack that resembles what you would see in many startup and mid-size production environments.

---

Repository Structure

.
├── realcode/
│   ├── Dockerfile          # Application build definition
│   └── (Website source code)
│
├── terraform/
│   ├── main.tf
│   ├── vpc.tf
│   ├── securitygroup.tf
│   ├── k8s-master.tf
│   ├── k8s-worker.tf
│   └── scripts/
│       ├── master.sh       # Bootstraps Kubernetes control plane
│       └── worker.sh       # Joins worker node to cluster
│
├── k8s/
│   ├── deployment.yaml     # Application workload
│   ├── service.yaml        # NodePort exposure
│   └── ingress.yaml        # Optional ingress routing
│
└── .github/
    └── workflows/
        └── k8s-ci-cd.yaml  # Automated CI/CD pipeline

The Dockerfile resides inside "realcode/" because this directory contains the actual application source — a structure consistent with real production repositories.

---

Infrastructure Provisioning

From the "terraform/" directory:

terraform init
terraform apply -auto-approve

This provisions:

- Custom VPC and public subnet
- Internet Gateway
- Security Group configured for Kubernetes and NodePort access
- One control-plane (master) EC2 instance
- One worker EC2 instance

Each instance is bootstrapped with:

- Kernel modules required for Kubernetes
- containerd configured for systemd cgroups
- kubeadm, kubelet, and kubectl
- Pre-requisites for stable cluster networking

---

Kubernetes Cluster Setup

After Terraform completes, SSH into the master node:

ssh -i realcode-key.pem ubuntu@<MASTER_PUBLIC_IP>

Verify cluster health:

kubectl get nodes

A healthy cluster shows both nodes in Ready state before proceeding.

---

Application Deployment

On the master node:

git clone <your-repo>
cd terraform-docker-aws-project
kubectl apply -f k8s/

Confirm service exposure:

kubectl get svc

The application is reachable via:

http://<WORKER_PUBLIC_IP>:<NODEPORT>

This validates that Kubernetes scheduling, pod networking, and external access are functioning correctly.

---

Monitoring with Prometheus and Grafana (Helm)

Install observability stack:

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace

Verify all monitoring components are running:

kubectl get pods -n monitoring

Retrieve Grafana access details:

kubectl get svc -n monitoring
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

Grafana is then accessible via:

http://<WORKER_PUBLIC_IP>:<GRAFANA_NODEPORT>

Prometheus can be accessed securely via port-forwarding when needed:

kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

---

CI/CD Pipeline

A GitHub Actions workflow in:

.github/workflows/k8s-ci-cd.yaml

automates:

1. Docker image build from "realcode/Dockerfile"
2. Push to Docker Hub
3. Kubernetes deployment update

This pipeline runs on the k8s-upgrade branch, preserving the integrity of the main Terraform project while enabling continuous delivery of the Kubernetes workload.

---

Real Problems Faced and Solved

1. Kubernetes API unreachable

Error:

connection to server localhost:8080 refused

Root cause: containerd was not using systemd cgroups, causing kubelet instability.
Fix: Forced "SystemdCgroup = true" in containerd configuration and restarted the service.

---

2. Nodes stuck in NotReady

Root cause: Calico BGP mesh did not stabilize immediately after cluster bootstrap.
Fix: Re-applied Calico manifest and allowed time for BGP peering to establish.

---

3. Application not accessible externally

Root cause: AWS Security Group did not allow NodePort traffic.
Fix: Explicitly opened:

30000–32767 TCP

---

4. Grafana showing “0 data”

Root cause: Grafana could not resolve Prometheus service DNS inside the cluster.
Fix: Verified CoreDNS health and used the correct internal service endpoint:

http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090

---

5. Prometheus UI inaccessible

Fix: Used Kubernetes port-forwarding rather than direct NodePort access to avoid firewall and routing issues.

---

Cleanup

To remove all resources:

terraform destroy -auto-approve

---

