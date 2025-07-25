# Bootstrap

Pasos:

* [Trabajando con el equipo físico](#id10)
  * [Instalación del S.O.](#id11)
  * [Networking](#id12)
* [Trabajando con el equipo remotamente](#id20)
  * [Config básica](#id21)
  * [MicroSD to NVMe](#id22)
  * [Neofetch](#id23)

# Trabajando con el equipo físico <div id='id10' />

## Instalación del S.O. <div id='id11' />

El sistema Operativo que usamos para grabar en la tarjeta MicroSD es:
* Rapsberry Pi OS (other) 
  * Rapsberry Pi OS Lite (64-bit)

Personalización del S.O.:
* Nombre: pi-k8s-cp-111
* General:
  * Usuario: oscar.mas
  * Password: sorisat
* Ajustes regionales:
  * Europe/Madrid
  * es
* Servicios:
  * Activar SSH

## Networking <div id='id12' />

```
$ sudo nmcli radio wifi on
$ nmtui
    172.26.0.111
$ sudo reboot
```

# Trabajando con el equipo remotamente <div id='id20' />

Accedemos por SSH por la WiFi:

```
$ ssh oscar.mas@172.26.0.111
```

## Config básica <div id='id21' />

```
oscar.mas@pi-k8s-cp-111:~ $ sudo apt update && sudo apt install -y vim screen
oscar.mas@pi-k8s-cp-111:~ $ sudo vim /etc/ssh/sshd_config
    PermitRootLogin yes

oscar.mas@pi-k8s-cp-111:~ $ sudo bash
root@pi-k8s-cp-111:/home/oscar.mas# passwd
    sorisat

root@pi-k8s-cp-111:/home/oscar.mas# reboot
```

```
$ ssh-copy-id -i $HOME/.ssh/id_rsa.pub 172.26.0.111
$ ssh 172.26.0.111
```

```
root@pi-k8s-cp-111:~# userdel oscar.mas
root@pi-k8s-cp-111:~# rm -rf /home/oscar.mas

root@pi-k8s-cp-111:~# echo "set mouse=c" > $HOME/.vimrc
root@pi-k8s-cp-111:~# echo "syntax on" >> $HOME/.vimrc
root@pi-k8s-cp-111:~# echo "set background=dark" >> $HOME/.vimrc

root@pi-k8s-cp-111:~# echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
root@pi-k8s-cp-111:~# echo "172.26.0.111 pi-k8s-cp-111" >> /etc/hosts

root@pi-k8s-cp-111:~# vim /etc/hosts

root@pi-k8s-cp-111:~# cat /etc/hosts
127.0.0.1       localhost.localdomain localhost
172.26.0.111    pi-k8s-cp-111
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

root@pi-k8s-cp-111:~# screen
root@pi-k8s-cp-111:~# apt-get -y upgrade && apt-get dist-upgrade -y && apt-get -y autoremove --purge && apt-get autoclean && apt-get clean && reboot
```

## MicroSD to NVMe <div id='id22' />

```
root@pi-k8s-cp-111:~# lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
mmcblk0     179:0    0 119.1G  0 disk
├─mmcblk0p1 179:1    0   512M  0 part /boot/firmware
└─mmcblk0p2 179:2    0 118.6G  0 part /
nvme0n1     259:0    0 476.9G  0 disk
```

:warning: El siguiente paso tarda muchísimo :warning:

```
root@pi-k8s-cp-111:~# sudo dd bs=4M if=/dev/mmcblk0 of=/dev/nvme0n1 status=progress oflag=sync
```

```
root@pi-k8s-cp-111:~# raspi-config
    Advanced Options -> Boot Order

root@pi-k8s-cp-111:~# poweroff
```

Sacamos la tarjeta MicroSD

## Neofetch <div id='id23' />

```
$ scp files/neofetch.conf 172.26.0.111:/etc/ssh/neofetch.conf
```

```
root@pi-k8s-cp-111:~# apt-get update && apt-get install -y neofetch
root@pi-k8s-cp-111:~# rm -rf /etc/update-motd.d/*

root@pi-k8s-cp-111:~# chown root:root /etc/ssh/neofetch.conf
root@pi-k8s-cp-111:~# chmod 0755 /etc/ssh/neofetch.conf

root@pi-k8s-cp-111:~# vim /etc/ssh/sshd_config
    PrintMotd no
    PrintLastLog no
    Banner /dev/null
root@pi-k8s-cp-111:~# touch ~/.hushlogin
root@pi-k8s-cp-111:~# grep -c "^neofetch --config /etc/ssh/neofetch.conf" /etc/profile | true
root@pi-k8s-cp-111:~# vim /etc/profile
    neofetch --config /etc/ssh/neofetch.conf
root@pi-k8s-cp-111:~# rm -rf /etc/motd
root@pi-k8s-cp-111:~# exit
```

```
$ ssh 172.26.0.111
```
