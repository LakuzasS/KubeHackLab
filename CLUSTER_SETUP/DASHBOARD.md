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