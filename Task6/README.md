```bash
mkdir -p ~/.minikube/files/etc/ssl/certs
mkdir -p ~/.minikube/files/var/log
cp audit-policy.yaml ~/.minikube/files/etc/ssl/certs
minikube start --image-mirror-country=cn --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml --extra-config=apiserver.audit-log-path=/var/log/audit.log
```

```bash
./simulate-incident.sh
```