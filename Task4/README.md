# 1. Запустить пустой Minikube
```bash
minikube start
```

# 2. Запустить последовательно
```bash
./create-cluster-users.sh
./create-cluster-roles.sh
./bind-cluster-roles.sh
```

# 3. Проверка (примеры)
```bash
kubectl config use-context alice-dev-context
kubectl auth can-i create deployments -n development   # yes
kubectl auth can-i get secrets -n development          # no

kubectl config use-context bob-view-context
kubectl auth can-i get pods                            # yes
kubectl auth can-i create deployments                  # no

kubectl config use-context charlie-sec-context
kubectl auth can-i get secrets                         # yes
kubectl auth can-i delete secrets                      # no
```