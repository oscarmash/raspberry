SHELL := /bin/bash
PATH := bin:$(PATH)
KUBESPRAY_VERSION=v2.28.0
KUBE_VERSION ?= 1.31.4
TAG := xxx

BIN=docker run --rm -it --name kubespray --hostname kubespray \
	--mount type=bind,source="${HOME}"/.ansible/roles/,dst=/ilimit/roles/ \
	--mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
	--mount type=bind,source="${HOME}"/.ssh/known_hosts,dst=/root/.ssh/known_hosts \
	--mount type=bind,source="$(PWD)/cluster-apps",dst=/kubespray/cluster-apps \
	--mount type=bind,source="$(PWD)/inventory",dst=/kubespray/inventory \
	--mount type=bind,source="$(PWD)/playbooks_custom",dst=/kubespray/playbooks_custom \
	-v "$(PWD)/variables_kubespray.yml:/kubespray/variables_kubespray.yml" \
	quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION)

shell:
	$(BIN) bash

pre_install:
	$(BIN) ansible-playbook -i inventory/inventory.ini playbooks_custom/pre_install.yaml -b

install_kubespray:
	$(BIN) ansible-playbook -i inventory/inventory.ini playbooks/cluster.yml -e kube_version=$(KUBE_VERSION) -e "@variables_kubespray.yml" -b

########################

install_applications_tag:
	$(BIN) ansible-playbook -i inventory/inventory.ini playbooks_custom/install_applications.yaml -t $(TAG)
