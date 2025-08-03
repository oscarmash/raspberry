# Index:

* [Prerequisites](#id10)
* [Instalación de Kubernetes](#id20)
  * [Kubespray](#id21)
  * [Cilium (CNI)](#id22)
* [Instalación de Aplicaciones](#id30)
  * [Metrics Server](#id31)
  * [Ingress nginx](#id32)
  * [Rook](#id40)
    * [Instalación](#id41)
    * [Creación del cluster](#id42)
    * [Crush Map](#id43)
    * [Dashboard](#id44)
    * [Pool RBD](#id45)
      * [Create Pool RBD](#id46)
      * [Test Pool RBD](#id47)


# Prerequisites: <div id='id10' />

Puntos a revisar antes de instalar Kubespray:
* Que todos los equipos se pueda acceder por la Wifi
* Que tengan una red interna configurada con el rango: 192.168.100.x/24

# Instalación de Kubernetes <div id='id20' />

## Kubespray <div id='id21' />

Instalamos Kubernetes

:raised_hand: La instalación de K8s tarda unos 45min

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

## Cilium (CNI)<div id='id22' />

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

root@pi-k8s-cp-111:~# kubectl -n kube-system get svc cilium-ingress
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
cilium-ingress   LoadBalancer   10.233.42.200   172.26.0.110   80:31250/TCP,443:32551/TCP   5d22h
```

# Instalación de Aplicaciones <div id='id30' />

## Metrics Server <div id='id31' />

```
$ make install_applications_tag TAG=metrics-server_installation
```

```
root@pi-k8s-cp-111:~# helm ls -A
NAME            NAMESPACE       REVISION        UPDATED                                         STATUS          CHART                   APP VERSION
cilium          kube-system     1               2025-07-27 12:07:49.613462794 +0200 CEST        deployed        cilium-1.17.6           1.17.6
metrics-server  kube-system     1               2025-07-27 12:08:49.758995911 +0200 CEST        deployed        metrics-server-3.12.2   0.7.2

root@pi-k8s-cp-111:~# kubectl top nodes
NAME            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
pi-k8s-cp-111   416m         12%    2158Mi          30%
pi-k8s-nd-112   76m          2%     1382Mi          19%
pi-k8s-nd-113   77m          2%     1365Mi          19%
pi-k8s-nd-115   72m          2%     1465Mi          20%
```
## Ingress nginx <div id='id32' />

```
$ make install_applications_tag TAG=ingress-nginx_installation
```

```
root@pi-k8s-cp-111:~# helm -n ingress-nginx ls
NAME            NAMESPACE       REVISION        UPDATED                                         STATUS          CHART                   APP VERSION
ingress-nginx   ingress-nginx   1               2025-08-02 11:01:52.396616964 +0200 CEST        deployed        ingress-nginx-4.13.0    1.13.0

root@pi-k8s-cp-111:~# kubectl -n ingress-nginx get pods
NAME                             READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-2xz5h   1/1     Running   0          2m14s
ingress-nginx-controller-m62bb   1/1     Running   0          2m14s
ingress-nginx-controller-p75p6   1/1     Running   0          2m14s


root@pi-k8s-cp-111:~# kubectl -n ingress-nginx get svc ingress-nginx-controller
NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller   LoadBalancer   10.233.48.27   172.26.0.109   80:31865/TCP,443:31524/TCP   2m28s
```

## Rook <div id='id40' />
### Instalación <div id='id41' />

Antes haber hecho la particion **vda3** en todos los equipos:

```
root@pi-k8s-cp-111:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
vda    254:0    0  100G  0 disk
├─vda1 254:1    0   63G  0 part /
├─vda2 254:2    0    1K  0 part
└─vda5 254:5    0  975M  0 part

root@pi-k8s-cp-111:~# cfdisk /dev/vda
  Type: Linux

root@pi-k8s-cp-111:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
vda    254:0    0  100G  0 disk
├─vda1 254:1    0   63G  0 part /
├─vda2 254:2    0    1K  0 part
├─vda3 254:3    0   36G  0 part   <---
└─vda5 254:5    0  975M  0 part
```

```
$ kubectl label node pi-k8s-nd-112 topology.rook.io/cephnode=true
$ kubectl label node pi-k8s-nd-113 topology.rook.io/cephnode=true
$ kubectl label node pi-k8s-nd-115 topology.rook.io/cephnode=true
```

```
$ make install_applications_tag TAG=rook_installation
```

```
$ kubectl -n rook-ceph get pods
NAME                                 READY   STATUS    RESTARTS   AGE
rook-ceph-operator-d98fcf9bd-d5bxc   1/1     Running   0          114s

$ helm -n rook-ceph ls
NAME            NAMESPACE       REVISION        UPDATED                                         STATUS          CHART                   APP VERSION
rook-ceph       rook-ceph       1               2025-07-29 07:24:36.413119042 +0200 CEST        deployed        rook-ceph-v1.17.6       v1.17.6
```

### Creación del cluster <div id='id42' />

```
$ cat <<EOF > rook-cephcluster.yaml
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: rook-ceph
  namespace: rook-ceph
spec:
  cephVersion:
    image: quay.io/ceph/ceph:v19.2.3
    allowUnsupported: false
  dataDirHostPath: /var/lib/rook
  skipUpgradeChecks: false
  continueUpgradeAfterChecksEvenIfNotHealthy: false
  mon:
    count: 3
    allowMultiplePerNode: false
  mgr:
    count: 2
    allowMultiplePerNode: false
  dashboard:
    enabled: true
    ssl: false
  storage:
    useAllNodes: false
    useAllDevices: false
    nodes:
      - name: "pi-k8s-nd-112"
        devices:
          - name: "vda3"
      - name: "pi-k8s-nd-113"
        devices:
          - name: "vda3"
      - name: "pi-k8s-nd-115"
        devices:
          - name: "vda3"
EOF
```

```
root@pi-k8s-cp-111:~# k apply -f rook-cephcluster.yaml
```

:raised_hand: El siguiente paso tarda más de 45 minutos

```
root@pi-k8s-cp-111:~# kubectl -n rook-ceph get cephcluster
NAME        DATADIRHOSTPATH   MONCOUNT   AGE   PHASE         MESSAGE                  HEALTH   EXTERNAL   FSID
rook-ceph   /var/lib/rook     3          46s   Progressing   Detecting Ceph version
```

```
root@pi-k8s-cp-111:~# kubectl -n rook-ceph get cephcluster
NAME        DATADIRHOSTPATH   MONCOUNT   AGE   PHASE         MESSAGE                 HEALTH   EXTERNAL   FSID
rook-ceph   /var/lib/rook     3          28m   Progressing   Configuring Ceph Mons
```

```
root@pi-k8s-cp-111:~# kubectl -n rook-ceph get cephcluster
NAME        DATADIRHOSTPATH   MONCOUNT   AGE   PHASE   MESSAGE                        HEALTH      EXTERNAL   FSID
rook-ceph   /var/lib/rook     3          68m   Ready   Cluster created successfully   HEALTH_OK              bf12e2fc-2f7a-4def-abd1-18728ab9a438
```

```
root@pi-k8s-cp-111:~# kubectl -n rook-ceph get pods
NAME                                                      READY   STATUS    RESTARTS      AGE
csi-cephfsplugin-2xsbm                                    2/2     Running   1 (46m ago)   46m
csi-cephfsplugin-4fm7t                                    2/2     Running   1 (46m ago)   46m
csi-cephfsplugin-provisioner-57f74977cc-tskhv             5/5     Running   3 (23m ago)   46m
csi-cephfsplugin-provisioner-57f74977cc-xjz5d             5/5     Running   1 (46m ago)   46m
csi-cephfsplugin-wvsgs                                    2/2     Running   1 (46m ago)   46m
csi-rbdplugin-2nr6h                                       2/2     Running   1 (46m ago)   46m
csi-rbdplugin-cq8fj                                       2/2     Running   1 (46m ago)   46m
csi-rbdplugin-glzvx                                       2/2     Running   1 (46m ago)   46m
csi-rbdplugin-provisioner-5f4db4d7ff-h4dn6                5/5     Running   3 (22m ago)   46m
csi-rbdplugin-provisioner-5f4db4d7ff-qsjqz                5/5     Running   1 (46m ago)   46m
rook-ceph-crashcollector-pi-k8s-nd-112-5549c9ff9f-7n9l4   1/1     Running   0             6m49s
rook-ceph-crashcollector-pi-k8s-nd-113-6c46889cfd-9qfxm   1/1     Running   0             6m48s
rook-ceph-crashcollector-pi-k8s-nd-115-854d4d9db8-77x58   1/1     Running   0             7m31s
rook-ceph-exporter-pi-k8s-nd-112-5998c4c4cf-hztsf         1/1     Running   0             6m45s
rook-ceph-exporter-pi-k8s-nd-113-77bbbf7fd-dcs7s          1/1     Running   0             6m44s
rook-ceph-exporter-pi-k8s-nd-115-b7b44f64d-f7rt2          1/1     Running   0             7m30s
rook-ceph-mgr-a-f48cffcc6-f76wc                           2/2     Running   0             7m32s
rook-ceph-mgr-b-86b6d859b6-jbzn9                          2/2     Running   0             7m31s
rook-ceph-mon-a-757df954c4-v9v5k                          1/1     Running   0             23m
rook-ceph-mon-b-7b4c484dc-gzbjr                           1/1     Running   0             22m
rook-ceph-mon-c-6875464496-msksx                          1/1     Running   0             13m
rook-ceph-operator-d98fcf9bd-6whtz                        1/1     Running   0             79m
rook-ceph-osd-0-69867857cb-kl82m                          1/1     Running   0             6m49s
rook-ceph-osd-1-5949d4d484-f9x9g                          1/1     Running   0             6m48s
rook-ceph-osd-2-6f8b67d8b6-5rhgg                          1/1     Running   0             4m58s
```

```
$ wget https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/toolbox.yaml
$ k apply -f toolbox.yaml

root@pi-k8s-cp-111:~# kubectl -n rook-ceph exec deploy/rook-ceph-tools -it -- bash

bash-5.1$ ceph status
  cluster:
    id:     bf12e2fc-2f7a-4def-abd1-18728ab9a438
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum a,b,c (age 6m)
    mgr: a(active, since 6m), standbys: b
    osd: 3 osds: 3 up (since 5m), 3 in (since 5m)

  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 449 KiB
    usage:   81 MiB used, 108 GiB / 108 GiB avail
    pgs:     1 active+clean
```

### Crush Map <div id='id43' />

```
bash-5.1$ ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME               STATUS  REWEIGHT  PRI-AFF
-1         0.10556  root default
-3         0.03519      host pi-k8s-nd-112
 0    hdd  0.03519          osd.0               up   1.00000  1.00000
-5         0.03519      host pi-k8s-nd-113
 1    hdd  0.03519          osd.1               up   1.00000  1.00000
-7         0.03519      host pi-k8s-nd-115
 2    hdd  0.03519          osd.2               up   1.00000  1.00000
```

```
ceph osd crush add-bucket raspberry-pi-row1 row
ceph osd crush add-bucket raspberry-pi-row2 row

ceph osd crush move raspberry-pi-row1 root=default
ceph osd crush move raspberry-pi-row2 root=default

ceph osd crush move pi-k8s-nd-112 row=raspberry-pi-row1
ceph osd crush move pi-k8s-nd-113 row=raspberry-pi-row1
ceph osd crush move pi-k8s-nd-115 row=raspberry-pi-row2
```

```
bash-5.1$ ceph osd tree
ID   CLASS  WEIGHT   TYPE NAME                   STATUS  REWEIGHT  PRI-AFF
 -1         3.00000  root default
 -9         2.00000      row raspberry-pi-row1
 -3         1.00000          host pi-k8s-nd-112
  0    hdd  1.00000              osd.0               up   1.00000  1.00000
 -5         1.00000          host pi-k8s-nd-113
  1    hdd  1.00000              osd.1               up   1.00000  1.00000
-10         1.00000      row raspberry-pi-row2
 -7         1.00000          host pi-k8s-nd-115
  2    hdd  1.00000              osd.2               up   1.00000  1.00000
```


### Dashboard <div id='id44' />

```
root@pi-k8s-cp-111:~# kubectl -n rook-ceph exec deploy/rook-ceph-tools -it -- bash

bash-5.1$ ceph mgr services
{
    "dashboard": "http://10.1.1.109:7000/",
    "prometheus": "http://10.1.1.109:9283/"
}

bash-5.1$ echo "C@dinor1988" > /tmp/dashboard_password.yml
bash-5.1$ ceph dashboard ac-user-set-password admin -i /tmp/dashboard_password.yml
bash-5.1$ ceph mgr module enable telemetry
bash-5.1$ ceph telemetry on --license sharing-1-0

bash-5.1$ exit
```

```
$ cat <<EOF > rook-cephdashboard.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rook-ceph-dashboard
  namespace: rook-ceph
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: pi-ceph.ilba.cat
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: rook-ceph-mgr-dashboard
                port:
                  number: 7000
EOF
```

```
root@pi-k8s-cp-111:~# k apply -f rook-cephdashboard.yaml

root@pi-k8s-cp-111:~# k -n rook-ceph get ingress
NAME                  CLASS   HOSTS              ADDRESS        PORTS   AGE
rook-ceph-dashboard   nginx   pi-ceph.ilba.cat   172.26.0.109   80      43s
```

Acceso:
* URL: http://pi-ceph.ilba.cat/
* Username: admin
* Password: C@dinor1988

### Pool RBD <div id='id45' />
#### Create Pool RBD <div id='id46' />

```
root@pi-k8s-cp-111:~# kubectl -n rook-ceph exec deploy/rook-ceph-tools -it -- bash

bash-5.1$ ceph -s
  cluster:
    id:     0a0e5193-033d-49ef-8564-e5cdf615ca0b
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum a,b,c (age 14m)
    mgr: a(active, since 12m), standbys: b
    osd: 3 osds: 3 up (since 13m), 3 in (since 13m)

  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 449 KiB
    usage:   81 MiB used, 108 GiB / 108 GiB avail
    pgs:     1 active+clean

bash-5.1$ ceph osd status
ID  HOST            USED  AVAIL  WR OPS  WR DATA  RD OPS  RD DATA  STATE
 0  pi-k8s-nd-112  26.8M  35.9G      0        0       0        0   exists,up
 1  pi-k8s-nd-113  26.8M  35.9G      0        0       0        0   exists,up
 2  pi-k8s-nd-115  26.8M  35.9G      0        0       0        0   exists,up

bash-5.1$ ceph osd pool set .mgr size 2
bash-5.1$ ceph osd lspools
1 .mgr

bash-5.1$ exit
```

```
$ cat <<EOF > rook-pool-sc.yaml
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
  name: pool-rbd-k8s
  namespace: rook-ceph
spec:
  failureDomain: row
  replicated:
    size: 2
    replicasPerFailureDomain: 1
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-ceph-block
provisioner: rook-ceph.rbd.csi.ceph.com
parameters:
  clusterID: rook-ceph
  pool: pool-rbd-k8s
  imageFormat: "2"
  imageFeatures: layering
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
  csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
  csi.storage.k8s.io/fstype: ext4
allowVolumeExpansion: true
reclaimPolicy: Delete
EOF
```

```
root@pi-k8s-cp-111:~# k apply -f rook-pool-sc.yaml

root@pi-k8s-cp-111:~# k -n rook-ceph get cephblockpool
NAME           PHASE   TYPE         FAILUREDOMAIN   AGE
pool-rbd-k8s   Ready   Replicated   row             15s

root@pi-k8s-cp-111:~# k -n rook-ceph get sc
NAME              PROVISIONER                  RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
rook-ceph-block   rook-ceph.rbd.csi.ceph.com   Delete          Immediate           true                   53s
```

#### Test Pool RBD <div id='id47' />

```
$ cat <<EOF > rook-test-rbd.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-csi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-fs-apache
  namespace: test-csi
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi
  storageClassName: rook-ceph-block
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd-deployment
  namespace: test-csi
spec:
  selector:
    matchLabels:
      app: httpd
  replicas: 1
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: httpd
        ports:
        - containerPort: 80
        volumeMounts:
        - name: data
          mountPath: /mydata
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: pvc-fs-apache
EOF
```

```
root@pi-k8s-cp-111:~# k apply -f rook-test-rbd.yaml

root@pi-k8s-cp-111:~# k -n test-csi get pvc
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      VOLUMEATTRIBUTESCLASS   AGE
pvc-fs-apache   Bound    pvc-f78f3802-74a7-47e6-b445-d846ddb9564d   1Gi        RWO            rook-ceph-block   <unset>                 29s

root@pi-k8s-cp-111:~# k -n test-csi get pod
NAME                                READY   STATUS    RESTARTS   AGE
httpd-deployment-569f4f96fd-9s8dw   1/1     Running   0          43s

root@pi-k8s-cp-111:~# POD=`kubectl -n test-csi get pods | grep http | awk '{print $1}'`
root@pi-k8s-cp-111:~# k -n test-csi exec -it $POD -- df -h | grep rbd0
/dev/rbd0       974M   24K  958M   1% /mydata
```

```
root@pi-k8s-cp-111:~# k -n test-csi delete deploy httpd-deployment
root@pi-k8s-cp-111:~# k -n test-csi delete pvc pvc-fs-apache
root@pi-k8s-cp-111:~# k delete ns test-csi
```
