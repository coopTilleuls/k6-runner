# k6-runner

## Introduction

Image pour k6-operator ajoutant les extensions "redis" et "prometheus-rw"

## Installation

### K6 operator
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install k6-operator grafana/k6-operator
```

## Configuration

### Prometheus

Prometheus doit être lancé avec l'option : `--web.enable-remote-write-receiver`

###  Variables d'environnement

* Configmap

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: prometheus-config
      namespace: k6-operator-system
    data:
      K6_PROMETHEUS_RW_SERVER_URL: http://<prometheus_url>:9090/api/v1/write
      K6_PROMETHEUS_RW_TREND_STATS:  "count,sum,min,max,avg,med"
    ```

* Secret (si utilisation de Redis avec Authentification)

    ```sh
    kubectl create secret generic k6-secrets --from-literal REDIS_URL=redis://user:passwd@redis_url:6379
    ```
### Fichier de configuration du test

* k6-tmc.yaml
    ```yaml
    apiVersion: k6.io/v1alpha1
    kind: K6
    metadata:
      name: k6-tmc
    spec:
      parallelism: 1 # le target de test doit être au moins égale ceci
      runner:
        image: ghcr.io/cooptilleuls/k6-runner:main
        envFrom:
         - configMapRef:
             name: prometheus-config
         - secretRef:
             name: k6-secrets
      arguments: -o xk6-prometheus-rw
      script:
        configMap:
          name: mon-test
          file: "archive.tar"
    ```

## Lancement d'un TMC

* Suppression du test précédent
    ```sh
    kubectl delete -f k6-tmc.yaml
    kubectl delete configmaps reply-to-feedback
    ```
* Créer une Configmap contenant le test à lancer:
    ```sh
    k6 archive Course/get_course_sheets.js
    kubectl create configmap reply-to-feedback --from-file archive.tar
    ```

* Lancer le test
    ```
    kubectl apply -f k6-tmc.yaml
    ```
