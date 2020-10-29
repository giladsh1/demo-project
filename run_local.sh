#!/bin/bash

set -eo pipefail

function install_minikube () {
  which minikube > /dev/null && return 0
  echo "Installing minikube..."
  ostype=$(echo "$(uname -s)" | tr '[:upper:]' '[:lower:]')
  curl -sLo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-${ostype}-amd64 \
  && chmod +x minikube && sudo mv minikube /usr/local/bin
}

function start_minikube () {
  minikube status | grep Running > /dev/null && return 0
  echo "Starting minikube..."
  memory=6144
  cpus=2
  disk_size=30g
  minikube_resources_flags="--memory $memory --cpus $cpus --disk-size $disk_size"
  case $OSTYPE in
    linux*)
      export MINIKUBE_WANTUPDATENOTIFICATION=false
      export MINIKUBE_WANTREPORTERRORPROMPT=false
      export MINIKUBE_HOME=$HOME
      export CHANGE_MINIKUBE_NONE_USER=true
      minikube_command="sudo -E minikube start $minikube_resources_flags --vm-driver=none --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf"
      ;;
    darwin*)
      minikube_command="minikube start $minikube_resources_flags --vm-driver=hyperkit"
      ;;
    *)
      echo "unsupported Linux distro!" && exit 1
      ;;
    esac
    echo "starting Minikube with the following command:"
    echo $minikube_command
    eval $minikube_command
}

function install_kubectl () {
  which kubectl > /dev/null && return 0
  echo "Installing kubectl..."
  ostype=$(echo "$(uname -s)" | tr '[:upper:]' '[:lower:]')
  curl -sLo kubectl https://storage.googleapis.com/kubernetes-release/release/\
$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/\
$ostype/amd64/kubectl
  chmod +x kubectl && sudo mv kubectl /usr/local/bin
}

function install_skaffold () {
  which skaffold > /dev/null && return 0
  echo "Installing skaffold..."
  ostype=$(echo "$(uname -s)" | tr '[:upper:]' '[:lower:]')
  curl -sLo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-${ostype}-amd64
  chmod +x skaffold
  sudo mv skaffold /usr/local/bin
}

# validate local cluster is installed and running
case $OSTYPE in
 linux*)
  install_minikube
  start_minikube
  context=minikube
  ;;
darwin*)
  context=docker-desktop
  kubectl get nodes --context $context | grep docker-desktop > /dev/null || \
  (echo "your local k8s cluster is not running, please check the docker daemon and enable kubernetes." \
  && exit 1)
  ;;
*)
  echo "unsupported os" && exit 1
  ;;
esac

install_kubectl
install_skaffold

skaffold dev --port-forward=true
