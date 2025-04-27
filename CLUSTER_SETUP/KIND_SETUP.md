# 🛠️ Configuration de Kubernetes avec Kind sur macOS 🚀

Ce guide vous montre comment mettre en place un cluster Kubernetes local à l'aide de **Kind (Kubernetes IN Docker)** sur macOS.  
Assurez-vous que **Homebrew** est déjà installé sur votre système avant de commencer. 🍺

---

## 🌟 Prérequis

1. **Docker Desktop** doit être installé et configuré :
   - Suivez ce lien pour télécharger et installer Docker Desktop :  
     👉 [Installer Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/)
   - **⚠️ Note importante** : Choisissez la version adaptée à votre puce :
     - **Apple Silicon (M1/M2/M3/M4)** ou **Intel Chip**.
   - Une fois installé, lancez Docker Desktop et configurez-le avec les **paramètres par défaut**, puis cliquez sur "Skip" jusqu'à atteindre le **dashboard principal**.

2. **Homebrew** doit être installé pour installer Kind et d'autres outils :
   - Si ce n'est pas encore le cas, installez Homebrew avec cette commande :
     ```bash
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     ```
---

## 🔧 Étape 1 : Installer Kind

1. Installez Kind avec Homebrew :
   ```bash
   brew install kind
   ```

2. Vérifiez que Kind est bien installé :
   ```bash
   kind version
   ```
   Vous devriez voir s'afficher la version installée de Kind, confirmant son bon fonctionnement.

---

## ⛏️ Étape 2 : Créer un Cluster Kubernetes

1. Créez un cluster Kubernetes avec Kind :
   ```bash
   kind create cluster
   ```
   Cette commande configure automatiquement un cluster Kubernetes local en utilisant Docker.

2. Vérifiez que le cluster est actif avec Docker :
   ```bash
   docker ps
   ```
   Vous devriez voir un conteneur nommé quelque chose comme `kind-control-plane`.

---

## 🐳 Étape 3 : Explorer le Cluster Kubernetes

1. Connectez-vous au conteneur du nœud de contrôle Kubernetes :
   ```bash
   docker exec -it kind-control-plane bash
   ```
   Cela ouvre un shell dans le conteneur représentant le nœud de contrôle de votre cluster Kubernetes.

2. Testez le bon fonctionnement de Kubernetes depuis ce conteneur :
   - Listez les pods dans tous les namespaces :
     ```bash
     kubectl get pods --all-namespaces
     ```
   - Vous devriez voir une liste vide (aucun pod actif pour l'instant).

---

# 🖥️ Kubernetes Dashboard sur Kind

Ce guide explique comment installer et configurer le **Kubernetes Dashboard** sur un cluster local créé avec **Kind**.

---

## 🚀 Étapes d'installation

### 1. Installer le Dashboard
Pour installer le Kubernetes Dashboard :
1. Appliquez le fichier officiel pour déployer le Dashboard :
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
   ```

2. Vérifiez que les pods du Dashboard sont déployés :
   ```bash
   kubectl get pods -n kubernetes-dashboard
   ```

### 2. Configurer un Utilisateur Admin
Pour accéder au Dashboard, il est nécessaire de configurer un utilisateur admin avec les droits nécessaires :
1. Créez un fichier `dashboard-admin-user.yaml` avec les informations suivantes :
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

2. Appliquez ce fichier au cluster Kind :
   ```bash
   kubectl apply -f dashboard-admin-user.yaml
   ```

3. Générez un **token d'authentification** pour vous connecter au Dashboard :
   ```bash
   kubectl -n kubernetes-dashboard create token admin-user
   ```

### 3. Lancer et Accéder au Dashboard
Pour lancer le Dashboard :
1. Démarrez un proxy Kubernetes en local :
   ```bash
   kubectl proxy
   ```

2. Accédez à l’URL suivante dans votre navigateur :
   - [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

3. Collez le token généré pour vous connecter.

---

## 📚 Utilisation du Dashboard

### Superviser le Cluster
- **Pods** : Listez les pods actifs et leur état.
- **Services** : Vérifiez les services exposés (comme Juice Shop).
- **Logs** : Consultez les logs des pods pour surveiller leur comportement.

---

## 📚 Ressources supplémentaires

- 🐳 [Documentation officielle de Docker Desktop](https://docs.docker.com/desktop/)
- 📜 [Documentation officielle de Kind](https://kind.sigs.k8s.io/)
- 🌐 [Documentation officielle de Kubernetes](https://kubernetes.io/docs/)
