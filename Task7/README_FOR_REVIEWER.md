# Задание 7: Аудит безопасности контейнеров

## Выполненные задачи

### 1. PodSecurity Admission
- Создан namespace `audit-zone` с уровнем `restricted`
- Настроены enforce, audit и warn уровни
- Небезопасные поды блокируются на этапе admission

### 2. Небезопасные манифесты (заблокированы)
- `01-privileged-pod.yaml` - privileged: true
- `02-hostpath-pod.yaml` - hostPath volume
- `03-root-user-pod.yaml` - runAsUser: 0

### 3. Безопасные манифесты (работают)
- `01-secure.yaml` - privileged: false, runAsNonRoot: true, readOnlyRootFilesystem: true
- `02-secure.yaml` - emptyDir вместо hostPath
- `03-secure.yaml` - runAsNonRoot: true, readOnlyRootFilesystem: true

### 4. OPA Gatekeeper
Установлены constraint templates:
- `NoPrivilegedContainers` - запрет privileged контейнеров
- `DisallowedHostPaths` - запрет hostPath
- `RequiredRunAsNonRoot` - требует runAsNonRoot: true и readOnlyRootFilesystem: true