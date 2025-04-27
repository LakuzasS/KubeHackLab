# 🍹 Juice Shop Deployment

Ce guide explique comment déployer **OWASP Juice Shop**, une application web volontairement vulnérable, sur votre cluster Kubernetes.

---

## 🚀 Déploiement de Juice Shop

### 1. Créer un fichier de déploiement YAML
Voici un exemple de fichier `juice-shop-deployment.yaml` :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: juice-shop
  labels:
    app: juice-shop
spec:
  replicas: 1
  selector:
    matchLabels:
      app: juice-shop
  template:
    metadata:
      labels:
        app: juice-shop
    spec:
      containers:
      - name: juice-shop
        image: bkimminich/juice-shop:v13.0.2
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: juice-shop
spec:
  selector:
    app: juice-shop
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: NodePort
```

### 2. Appliquer le fichier de déploiement
1. Sauvegardez le fichier YAML sous `DEPLOYMENTS/juice-shop-deployment.yaml`.
2. Déployez Juice Shop avec cette commande :
   ```bash
   kubectl apply -f DEPLOYMENTS/juice-shop-deployment.yaml
   ```

### 3. Vérifier le déploiement
1. Listez les pods pour vérifier que Juice Shop est actif :
   ```bash
   kubectl get pods
   ```

2. Accédez à l'application via le navigateur :
   - Récupérez le port exposé :
     ```bash
     kubectl get service juice-shop
     ```
   - Accédez à l'application via :
     ```
     http://localhost:<port>
     ```

---

## 🛠️ Outils pour Pentest

### Vulnérabilités courantes
- **Injection SQL** : Exploitez les points d’entrée pour injecter des requêtes SQL malveillantes.
- **XSS (Cross-Site Scripting)** : Testez les champs de saisie pour injecter du code JavaScript.
- **RCE (Remote Code Execution)** : Identifiez des failles permettant d’exécuter du code à distance.

### Outils recommandés
- **Burp Suite** : Proxy pour analyser et manipuler les requêtes.
- **sqlmap** : Pour automatiser les attaques SQL.
- **OWASP ZAP** : Scanner pour identifier les vulnérabilités.

---

## 📚 Ressources supplémentaires
- [OWASP Juice Shop Documentation](https://owasp.org/www-project-juice-shop/)
- [Liste des vulnérabilités](https://owasp.org/www-project-juice-shop/part-vulnerability/)