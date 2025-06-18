# Installation for Fred and Knowledge-flow dependencies

## Requirements

- Have a fonctionnal K8s cluster, eventually using K3s (https://docs.k3s.io/installation)
- [Install helm](https://helm.sh/docs/intro/install/)

## Prepare hosts file

This step is needed only if you use k3s

```
IP_K3S=$(hostname -I | awk '{print $1}')

echo $IP_K3S keycloak.test | sudo tee -a /etc/hosts
echo $IP_K3S opensearch-dashboards.test | sudo tee -a /etc/hosts
echo $IP_K3S minio.test | sudo tee -a /etc/hosts
```

## Install dependencies

```
kubectl create namespace test

helm dependency build ./postgresql/
helm upgrade -i postgresql ./postgresql/ -n test

helm dependency build ./keycloak/
helm upgrade -i keycloak ./keycloak/ -n test

helm upgrade -i opensearch-certs-shared-volume ./opensearch-certs-shared-volume/ -n test
helm upgrade -i opensearch-pre-install-job ./opensearch-pre-install-job/ -n test

helm dependency build ./opensearch/
helm upgrade -i opensearch ./opensearch/ -n test

helm upgrade -i opensearch-post-install-job ./opensearch-post-install-job/ -n test

helm dependency build ./opensearch-dashboards/
helm upgrade -i opensearch-dashboards ./opensearch-dashboards/ -n test

helm dependency build ./minio
helm upgrade -i minio ./minio -n test
```

## Access to interfaces


Keycloak

url : http://keycloak.test
login : admin
pass : Azerty123_


Opensearch

url : http://opensearch-dashboards.test
login : admin
pass : Azerty123_


Minio

url : http://minio.local
login : admin
pass : Azerty123_
