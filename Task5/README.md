Minikube по умолчанию не поддерживает Network Policies, поэтому перезапускаем с CNI-плагином Calico:
```bash
minikube start --network-plugin=cni --cni=calico
```

В кластере, внутри одного namespace, разворачиваем четыре сервиса:
```bash
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80     
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80  
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80 
```

Применяем сетевую политику:
```bash
kubectl apply -f non-admin-api-allow.yaml
```

Проверка:
```bash
# allowed
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://back-end-api-app

# deny
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://admin-back-end-api-app

# allowed
kubectl run test-admin-$RANDOM --rm -i -t --image=alpine --labels role=admin-front-end -- sh
/ # wget -qO- --timeout=2 http://admin-back-end-api-app

# deny
kubectl run test-admin-$RANDOM --rm -i -t --image=alpine --labels role=admin-front-end -- sh
/ # wget -qO- --timeout=2 http://back-end-api-app
``` 