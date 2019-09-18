#Disable SELinux & setup firewall rules
exec bash
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10250/tcp
systemctl restart firewalld
systemctl reload firewalld

#Run the command below to enable the br_netfilter kernel module.

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#Disable SWAP for kubernetes installation by running the following commands.
swapoff -a
#add comment to a file
#And then edit the '/etc/fstab' file.
#Comment the swap line UUID as below.

#Install the latest version of Docker-ce from the docker repository.
#Install the package dependencies for docker-ce.
yum install -y yum-utils device-mapper-persistent-data lvm2

#Add the docker repository to the system and install docker-ce using the yum command.
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl start docker

#Add the kubernetes repository to the centos 7 system by running the following command.
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
#install the kubelet kubeadm kubectl
yum install -y kubelet kubeadm kubectl

#start the service kubelet kubeadm kubectl
systemctl enable docker.service
systemctl enable kubelet && systemctl start kubelet

#On master node
kubeadm init --pod-network-cidr=10.244.0.0/16

#Update your own user .kube config so that you can use kubectl from your own user in the future
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


#Setup Flannel virtual network:

sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml


#Setup the Nodes
#Run the following for networking to be correctly setup on each node:
sudo sysctl net.bridge.bridge-nf-call-iptables=1

#We need join token to connect each node to master. We can retrieved it from by running following command on master node.

joincmd=$(sudo kubeadm token create --print-join-command)

echo $joincmd
