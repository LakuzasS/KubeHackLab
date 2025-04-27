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

## 📚 Ressources supplémentaires

- 🐳 [Documentation officielle de Docker Desktop](https://docs.docker.com/desktop/)
- 📜 [Documentation officielle de Kind](https://kind.sigs.k8s.io/)
- 🌐 [Documentation officielle de Kubernetes](https://kubernetes.io/docs/)
