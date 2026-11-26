# Tag 18 – Infrastructure as Code & Kubernetes Cluster mit ArgoCD

## Einordnung im Unterricht

Tag 18 automatisiert die Bereitstellung der TechStyle-Infrastruktur mit **Infrastructure as Code (IaC)**. Anstelle manueller Serverkonfiguration wird die gesamte Umgebung als Code definiert und durch eine automatisierte Pipeline provisioniert.

Das Setup umfasst:
1. **Terraform / OpenTofu**: Automatisiertes Provisionieren von VPC, Subnets, Security Groups und EC2-Instanzen für Master- und Worker-Knoten in AWS mit S3 Remote State & DynamoDB Locking.
2. **Ansible**: Konfiguration der EC2-Instanzen über das **AWS EC2 Dynamic Inventory Plugin** (`amazon.aws.aws_ec2`), Installation der Container Runtime (`containerd`), Bootstrappen des Kubernetes-Clusters (`kubeadm`) sowie Installation von **ArgoCD**.
3. **Kubernetes Manifeste (`k8s/`)**: Bereitstellung der TechStyle Applikation als Kubernetes Deployment und NodePort Service sowie Anbindung via ArgoCD Application.

---

## Komponenten-Übersicht

| Komponente | Pfad | Zweck |
|------------|------|-------|
| **Terraform K8s** | [`infrastruktur-k8s/`](../infrastruktur-k8s) | AWS Infrastruktur für Kubernetes Master & Worker Nodes |
| **S3 Backend** | [`infrastruktur-k8s/backend.conf`](../infrastruktur-k8s/backend.conf) | Remote State & DynamoDB Table `terraformlock` |
| **Ansible Dynamic Inventory** | [`ansible/aws_ec2.yml`](../ansible/aws_ec2.yml) | Dynamische Host-Erkennung nach AWS Tags (`role_master`, `role_worker`) |
| **Ansible Playbook** | [`ansible/cluster-setup.yml`](../ansible/cluster-setup.yml) | K8s Cluster Bootstrapping & ArgoCD Installation |
| **K8s App Deployment** | [`k8s/deployment.yaml`](../k8s/deployment.yaml) | Deployment & NodePort Service für TechStyle Webapp |
| **ArgoCD Application** | [`k8s/argocd-application.yaml`](../k8s/argocd-application.yaml) | GitOps Deklaration für automatisierten Sync |
| **CI/CD Pipeline** | [`.github/workflows/k8s-cluster.yml`](../.github/workflows/k8s-cluster.yml) | Orchestrierung von Terraform, Ansible und K8s/ArgoCD |

---

## Abnahmekriterien

- [x] Terraform State Management mit S3 und DynamoDB konfiguriert
- [x] Ansible mit dynamischem Inventory in Pipeline eingebunden
- [x] Kubernetes Cluster mit Terraform + Ansible aufgesetzt
- [x] Kubernetes Manifest für Applikation und ArgoCD erstellt
