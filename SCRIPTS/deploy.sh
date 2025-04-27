#!/bin/bash

echo "💻 Déploiement du cluster Kubernetes avec Kind..."
kind create cluster --config CLUSTER_SETUP/kind-config.yaml

echo "🚀 Déploiement de Juice Shop..."
kubectl apply -f DEPLOYMENTS/juice-shop-deployment.yaml

echo "🔐 Configuration du Dashboard sécurisé..."
kubectl apply -f DEPLOYMENTS/dashboard-admin-user.yaml

echo "🔐 Récupération du token de connexion..."
kubectl -n kubernetes-dashboard create token admin-user

echo "✅ Déploiement terminé !"