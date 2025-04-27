# Documentation de Configuration de Kubernetes sur Ubuntu 24.04 🚀

## 🏗️ Architecture actuelle du cluster

| Noeud | vCPU | RAM (Go) | OS |
|-------|------|----------|----|
| Master | 2 | 4 | Ubuntu 24.04 |
| Worker | 2 | 4 | Ubuntu 24.04 |

## 🔄 Mise à Jour des Paquets du Serveur

```bash
sudo apt-get update && sudo apt-get -y upgrade
```

## ❌ Désactiver l'Échange sur les Nœuds de Cluster

1. 🔒 Pour **désactiver** de façon **temporaire** :

    ```bash
    sudo swapoff -a
    ```
2. 🔒 Pour **désactiver** de façon **permanente** :
   
   ```bash
   sudo sed -i '/swap/s/^/#/' /etc/fstab
   ```

## 🌐 Activer le Transfert d'Adresse IP du Noyau

1. 🌐 Pour activer le **Transfert** d'Adresse IP du Noyau :
   
   ```bash
   echo "net.ipv4.ip_forward=1" | sudo tee -a  /etc/sysctl.conf
   ```
2. 🔄 **Appliquer** les modifications :
   ```bash
   sudo sysctl -p
   ```

## 🛠 Charger les Modules de Noyau Nécessaires

1. 📝 **Vérifiez** si ces modules sont activés/chargés :
   
   ```bash
   sudo lsmod | grep -E "overlay|br_netfilter"
   ```
2. ➕ **Ajouter** les configurations suivantes :
   
   ```bash
   sudo tee -a /etc/sysctl.conf << 'EOL'
   net.bridge.bridge-nf-call-iptables = 1
   net.bridge.bridge-nf-call-ip6tables = 1
   EOL
   ```
3. ⚙️ **Appliquer** les modifications :

    ```bash
   sudo sysctl -p
   ```

## 📦 Installer Container Runtime

```bash
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -sc) stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list
sudo apt update
sudo apt install -y containerd.io
```

## ⚙️ Configurer le Pilote Cgroup pour ContainerD

1. 🗂️ **Créer** le dossier de configuration si nécessaire :
   
    ```bash
    [ -d /etc/containerd ] || sudo mkdir /etc/containerd
    ```
2. 📄 **Générer** le fichier de configuration par défaut :

    ```bash
    containerd config default | sudo tee /etc/containerd/config.toml
    ```
3. 🔧 **Changer** la valeur de `SystemdCgroup` de **false** à **true** :
   
    ```bash
    sudo sed -i '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml
    ```
4. 📦 **Mettre à jour** la version de pause :
   
    ```bash
    sudo sed -i '/pause:3.8/s/3.8/3.9/' /etc/containerd/config.toml
    ```
5. 🔍 **Vérifier** la version de pause :

    ```bash
    grep sandbox_image /etc/containerd/config.toml
    ```
6. 🚀 **Démarrer** et **activer** containerd pour qu’il s’exécute au démarrage :
   
    ```bash
    sudo systemctl enable --now containerd
    ```

    > 🚫 Attention ! 🚫
    Il est possible pour les étapes suivantes que le lancement du cluster **échoue**, car parfois, certains services alternatifs à kubernetes sont **préinstallés** lors de la configuration de l'**OS** ; Afin d'y remédier, **supprimer en amont** le sevice `microk8s` s'il existe : `sudo snap remove microk8s`
7. 📊 **Redémarrer** et **vérifier** l'état de containerd :
   
    ```bash
    systemctl restart containerd && systemctl status containerd
    ```

## 🛡️ Installer Kubernetes sur Ubuntu 24.04

1. 🔑 **Installer** la Clé de Signature GPG :
   
    ```bash
    sudo apt install gnupg2 -y
    VER=1.30
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v${VER}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
    ```
2. ➕ **Ajouter** le Référentiel Kubernetes :
   
    ```bash
    echo "deb https://pkgs.k8s.io/core:/stable:/v${VER}/deb/ /" | sudo tee /etc/apt/sources.list.d/kurbenetes.list
    ```
3. 🛠️ **Installer** les Composants Kubernetes :

    ```bash
    sudo apt update
    sudo apt install kubelet kubeadm kubectl -y
    ```
4. 📦 **Marquer** les Packages Kubernetes :
   
    ```bash
    sudo apt-mark hold kubeadm kubelet kubectl
    ```
## 🌀 Initialiser le Cluster Kubernetes :

```bash
sudo kubeadm init --apiserver-advertise-address=172.30.0.43 --pod-network-cidr=10.68.11.0/24
```
1. 👤 Passer en Mode **Utilisateur Normal** :

    ```bash
    su - lakuzass
    ```
2. 📁 **Créer** le Répertoire de Cluster Kubernetes :

    ```bash
    mkdir -p $HOME/.kube
    ```
3. 📄 **Copier** le Fichier de Configuration de l’Administrateur :

    ```bash
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```
4. 🔍 Vérifier l'État du Cluster :

    ```bash
    kubectl get nodes
    kubectl cluster-info
    ```

## 📡 Installer l'Addon Réseau Pod sur le Nœud Maître

1. ➕ **Déployer** le réseau Pod :
   
    ```bash
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    ```
2. 📥 **Installer** `Calico Pod network addon Operator` :
   
    ```bash
    CNI_VER=3.29.0
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${CNI_VER}/manifests/tigera-operator.yaml
    wget https://raw.githubusercontent.com/projectcalico/calico/v${CNI_VER}/manifests/custom-resources.yaml
    ```
3. 📂 **Afficher** le fichier :

    ```bash
    cat custom-resources.yaml
    ```
4. 🔄 **Mettre à jour** le sous-réseau :

    ```bash
    sed -i 's/192.168/10.100/' custom-resources.yaml
    ```
5. 📦 **Appliquer** les modifications :

    ```bash
    kubectl create -f custom-resources.yaml
    ```

## 📋 Obtenir des Pods en Cours d’Exécution

1. 📝 **Lister** les Pods dans les espaces de noms :

    ```bash
    kubectl get pods --all-namespaces
    ```
2. 🔍 **Répertorier** les Pods dans des espaces de noms spécifiques :

    ```bash
    kubectl get pods -n calico-system
    ```

## 🔓 Ouvrir les Ports du Cluster sur le Pare-feu

1. 🛡️<u>Ports du Plan de Contrôle :</u>
   
    | Protocole | Direction | Plage de ports | But | Utilisé par |
    |-----------|-----------|----------------|-----|-------------|
    | TCP       | Entrants  | 6443           | Serveur d’API Kubernetes | Tout |
    | TCP       | Entrants  | 2379-2380      | API du client du serveur etcd | kube-apiserver, etcd |
    | TCP       | Entrants  | 10250          | Kubelet API | Soi, Plan de contrôle |
    | TCP       | Entrants  | 10259          | kube-scheduler | Même |
    | TCP       | Entrants  | 10257          | kube-controller-manager | Même |
2. 🔓 **Ouvrir** les ports :

    ```bash
    for i in 6443 2379:2380 10250:10252; do sudo ufw allow from any to any port $i proto tcp; done
    ```
3. 🔒 **Restreindre** l’accès à l’API à partir de réseaux/IPS spécifiques :
    - ⚙️<u>Ports des Nœuds de Travail :</u>
        | Protocole | Direction | Plage de ports | But | Utilisé par |
        |-----------|-----------|----------------|-----|-------------|
        | TCP       | Entrants  | 10250          | Kubelet API | Soi, Plan de contrôle |
        | TCP       | Entrants  | 30000-32767    | NodePort Services | Tout |
4. 🔓 **Ouvrir** le port API Kubelet :

    ```bash
    ufw allow from any to any port 10250 proto tcp comment "Open Kubelet API port"
    ```

## ➕ Ajouter des Nœuds de Travail au Cluster

1. 🔍 **Vérifier** que le runtime du conteneur est en cours d’exécution :

    ```bash
    systemctl status containerd
    ```
2. 📋 **Imprimer** la commande join sur le **nœud maître** :

    ```bash
    kubeadm token create --print-join-command
    ```

3. 📥 **Exécuter** la commande reçue sur le **nœud worker** :

    ```bash
    kubeadm join 172.30.0.43:6443 --token uvtz2h.azomw8u4o2a55u57 --discovery-token-ca-cert-hash sha256:b5a3b73437440231910e77e9d76fd3e80b813d820ef39212b6e19c304608ab69
    ```
4. 🔍 **Vérifier** la présence du nœud :
   
    ```bash
    kubectl get nodes
    ```
5. 🛠️ **Mettre à jour** le rôle :

    ```bash
    kubectl label node worker node-role.kubernetes.io/worker=true
    ```

## 📊 Obtenir des Informations sur le Cluster
```bash
kubectl cluster-info
kubectl api-resources
```

---
# ✨ Installation du Dashboard Kubernetes ✨

> ✅ **Exécuter toutes les commandes en tant qu'utilisateur normal** via `su - eureka`

## 📄 Installation du dashboard Kubernetes sur le noeud maître du cluster

> ⚙️ **Remplacer la valeur de la variable** `VER` par la [version actuelle](https://github.com/kubernetes/dashboard/releases)

```bash
VER=2.7.0 && kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/dashboard/v${VER}/aio/deploy/recommended.yaml
```

## 🔍 Vérification de l’installation du dashboard

1. 🔢 **Afficher les namespaces** :

    ```bash
    kubectl get namespaces
    ```
    → **Retour attendu** :
    ```bash
    NAME                   STATUS   AGE
    calico-apiserver       Active   17h
    calico-system          Active   17h
    default                Active   17h
    kube-node-lease        Active   17h
    kube-public            Active   17h
    kube-system            Active   17h
    kubernetes-dashboard   Active   17h
    tigera-operator        Active   17h
    ```

2. 📐 **Lister les pods dans l'espace `kubernetes-dashboard`** :

    ```bash
    kubectl get pods -n kubernetes-dashboard -o wide
    ```
    → **Retour attendu** :
    ```bash
    NAME                                         READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
    dashboard-metrics-scraper-795895d745-42xr5   1/1     Running   0          17h   10.68.11.194   yval0160   <none>           <none>
    kubernetes-dashboard-56cf4b97c5-s2vlp        1/1     Running   0          17h   10.68.11.193   yval0160   <none>           <none>
    ```

3. ℹ️ **Obtenir plus de détails sur un pod** :
    ```bash
    kubectl describe pod kubernetes-dashboard-56cf4b97c5-s2vlp -n kubernetes-dashboard
    ```

## 🏠 Exposer le dashboard Kubernetes pour un accès externe

1. 🛠️ **Reconfigurer le service** pour un accès via NodePort :

    ```bash
    kubectl edit service kubernetes-dashboard -n kubernetes-dashboard
    ```
    > **Sous la section** `spec`, ajouter :
    > - `nodePort: 30001`
    > - Modifier le type de `ClusterIP` en `NodePort`

    → **Exemple** :
    ```bash
    spec:
        clusterIP: 10.97.96.182
        clusterIPs:
        - 10.97.96.182
        externalTrafficPolicy: Cluster
        internalTrafficPolicy: Cluster
        ipFamilies:
        - IPv4
        ipFamilyPolicy: SingleStack
        ports:
        - nodePort: 30001
          port: 443
          protocol: TCP
          targetPort: 8443
        selector:
            k8s-app: kubernetes-dashboard
        sessionAffinity: None
        type: NodePort
    ```

2. ❓ **Vérifier les ports Node actuellement utilisés** :

    ```bash
    kubectl get services --all-namespaces -o jsonpath='{range .items[*]}{.spec.ports[*].nodePort}{"\n"}{end}'
    ```

3. 📊 **Vérifier le service et la prise en compte du port** :

    ```bash
    kubectl get services -n kubernetes-dashboard
    ```
    → **Retour attendu** :
    ```bash
    NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
    dashboard-metrics-scraper   ClusterIP   10.111.14.67   <none>        8000/TCP        17h
    kubernetes-dashboard        NodePort    10.97.96.182   <none>        443:30001/TCP   17h
    ```

## 🛡️ Créer un compte administrateur pour le dashboard

1. 📓 **Création du fichier de configuration de l'utilisateur** :

    ```bash
    vim kubernetes-dashboard-admin-user.yml
    ```
    → **Contenu à insérer** :
    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: admin-user
      namespace: kubernetes-dashboard
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: admin-user
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: admin-user
      namespace: kubernetes-dashboard
    ```

2. ✍️ **Créer le compte administrateur** :

    ```bash
    kubectl apply -f kubernetes-dashboard-admin-user.yml
    ```
    > ℹ️ **Vérification** : utiliser `kubectl get serviceaccounts -n kubernetes-dashboard` pour confirmer.

3. 🔐 **Générer un jeton d'accès** :

    ```bash
    kubectl create token admin-user -n kubernetes-dashboard
    ```
    > ❗ **Conserver ce jeton** pour la connexion web.

## 🔗 Accès au dashboard Kubernetes

✉️ **Accéder au dashboard Kubernetes** à partir d’un navigateur via l’adresse IP de n'importe quel nœud du cluster sur le port `30001/tcp` en HTTPS.

- **Exemples d’accès** :
    - [Dashboard noeud maître](https://172.30.0.43:30001)
    - [Dashboard noeud worker](https://172.30.0.45:30001)

---