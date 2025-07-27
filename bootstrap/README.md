# Index:

* [Prerequisites](#id10)
* [Instalación de Kubernetes](#id20)
  * [Kubespray](#id21)
  * [CNI: Cilium](#id22)
* [Instalación de Aplicaciones](#id30)
  * [Metrics Server](#id31)

# Prerequisites: <div id='id10' />

Puntos a revisar antes de instalar Kubespray:
* Que todos los equipos se pueda acceder por la Wifi
* Que tengan una red interna configurada con el rango: 192.168.100.x/24

# Instalación de Kubernetes <div id='id20' />

## Kubespray <div id='id21' />

Instalamos Kubernetes

```
$ make pre_install
$ make install_kubespray
```

Verificamos que todo haya ido correctamente:

```
root@pi-k8s-cp-111:~# kubectl get nodes
NAME            STATUS     ROLES           AGE   VERSION
pi-k8s-cp-111   NotReady   control-plane   31m   v1.31.4
pi-k8s-nd-112   NotReady   <none>          31m   v1.31.4
pi-k8s-nd-113   NotReady   <none>          31m   v1.31.4
pi-k8s-nd-115   NotReady   <none>          31m   v1.31.4
```

## CNI: Cilium <div id='id22' />

Instalamos Helm i Cilium:

```
$ make install_applications_tag TAG=install_helm
$ make install_applications_tag TAG=cilium_installation
```

Verificamos que todo haya ido correctamente:

```
root@pi-k8s-cp-111:~# kubectl get nodes
NAME            STATUS   ROLES           AGE   VERSION
pi-k8s-cp-111   Ready    control-plane   59m   v1.31.4
pi-k8s-nd-112   Ready    <none>          58m   v1.31.4
pi-k8s-nd-113   Ready    <none>          58m   v1.31.4
pi-k8s-nd-115   Ready    <none>          58m   v1.31.4

root@pi-k8s-cp-111:~# helm ls -A
NAME    NAMESPACE       REVISION        UPDATED                                         STATUS          CHART           APP VERSION
cilium  kube-system     1               2025-07-27 10:30:22.894487773 +0200 CEST        deployed        cilium-1.17.6   1.17.6

root@pi-k8s-cp-111:~# kubectl get ippools
NAME        DISABLED   CONFLICTING   IPS AVAILABLE   AGE
pool-ilba   false      False         0               16m
```

# Instalación de Aplicaiones <div id='id30' />

## Metrics Server <div id='id31' />

```
$ make install_applications_tag TAG=metrics-server_installation
```

```
root@pi-k8s-cp-111:~# kubectl top nodes
NAME            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
pi-k8s-cp-111   416m         12%    2158Mi          30%
pi-k8s-nd-112   76m          2%     1382Mi          19%
pi-k8s-nd-113   77m          2%     1365Mi          19%
pi-k8s-nd-115   72m          2%     1465Mi          20%
```