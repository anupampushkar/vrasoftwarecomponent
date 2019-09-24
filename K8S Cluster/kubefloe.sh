export OPSYS=linux
curl -s https://api.github.com/repos/kubeflow/kubeflow/releases/latest |grep browser_download | grep $OPSYS | cut -d '"' -f 4 | xargs curl -O -L &&  tar -zvxf kfctl_*_${OPSYS}.tar.gz
export PATH=$PATH:$PWD
export KFAPP="kf-poc"
export VERSION=`curl -s https://api.github.com/repos/kubeflow/kubeflow/releases/latest |    grep tag_name | head -1 |    cut -d '"' -f 4`
export CONFIG="https://raw.githubusercontent.com/kubeflow/kubeflow/${VERSION}/bootstrap/config/kfctl_k8s_istio.yaml"
kfctl init ${KFAPP} --config=${CONFIG} -V
cd ${KFAPP}
kfctl generate all -V
kfctl apply all -V
# Add kfctl to PATH, to make the kfctl binary easier to use.
 export PATH=$PATH:"<path to kfctl>"
export KFAPP="<your choice of application directory name>"
# Installs Istio by default. Comment out Istio components in the config file to skip Istio installation. See https://github.com/kubeflow/kubeflow/pull/3663
 export CONFIG="https://raw.githubusercontent.com/kubeflow/kubeflow/v0.
cd ${KFAPP}
kfctl generate all -V
kfctl apply all -V
kubectl -n kubeflow get  all
watch -c -n 10 kubectl -n kubeflow get po
echo `kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'`
