#!/bin/bash

COLOR=$(tput setaf 4)
NC=$(tput sgr0)

clear

ssh root@172.26.0.71 -C "qm start 5111" 2> >(grep -v "Permanently added" 1>&2)
printf "Server \033[36;3mpi-k8s-cp-111.ilba.cat\033[0m is back online\n"
echo ""

ssh root@172.26.0.71 -C "qm start 5112" 2> >(grep -v "Permanently added" 1>&2)
printf "Server \033[36;3mpi-k8s-nd-112.ilba.cat\033[0m is back online\n"
echo ""

ssh root@172.26.0.72 -C "qm start 5113" 2> >(grep -v "Permanently added" 1>&2)
printf "Server \033[36;3mpi-k8s-nd-113.ilba.cat\033[0m is back online\n"
echo ""

ssh root@172.26.0.72 -C "qm start 5115" 2> >(grep -v "Permanently added" 1>&2)
printf "Server \033[36;3mpi-k8s-nd-115.ilba.cat\033[0m is back online\n"
echo ""

for i in {01..10}; do
    sleep 1
    printf "\r \033[0;33mWaiting 10 secons: $i\033[0m"
done
printf " \n"
echo ""

printf "\nConectate al equipo: \033[0;33mssh 172.26.0.111\033[0m\n"
echo ""

