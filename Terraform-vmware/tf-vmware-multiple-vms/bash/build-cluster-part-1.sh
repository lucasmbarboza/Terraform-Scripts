#!/bin/bash

#Create containerd config file
sudo touch /etc/modules-load.d/containerd.conf

#Add conf for containerd
cat <<EOF > /etc/modules-load.d/containerd.conf 
overlay
br_netfilter
EOF

#modprobe
sudo modprobe overlay
sudo modprobe br_netfilter

#Set system configurations for Kubernetes networking
touch /etc/sysctl.d/99-kubernetes-cri.conf


#Add conf for containerd
cat <<EOF > /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

#Apply new settings
sudo sysctl --system

#install containerd
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

#disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#install and configure dependencies
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

#Create kubernetes repo file
touch /etc/apt/sources.list.d/kubernetes.list

#Add K8s Source
cat  <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

#install kubernetes
sudo apt-get update
sudo apt-get install -y kubelet=1.22.0-00 kubeadm=1.22.0-00 kubectl=1.22.0-00
sudo apt-mark hold kubelet kubeadm kubectl