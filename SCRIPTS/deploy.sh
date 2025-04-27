#!/bin/bash

echo "💻 Déploiement du cluster Kubernetes avec Kind..."
kind create cluster

echo "🚀 Déploiement de Juice Shop..."
kubectl apply -f DEPLOYMENTS/juice-shop-deployment.yaml

echo "🔐 Configuration du Dashboard sécurisé..."
kubectl apply -f DEPLOYMENTS/dashboard-rbac.yaml

echo "✅ Déploiement terminé !"