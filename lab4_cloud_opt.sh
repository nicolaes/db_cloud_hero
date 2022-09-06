
export CLUSTER_REGION=us-east4

export CLUSTER_NAME=central
export GCLOUD_PROJECT=$(gcloud config get-value project)

gcloud container clusters \
  get-credentials $CLUSTER_NAME \
  --region $CLUSTER_REGION \
  --project $GCLOUD_PROJECT

istioctl install --set profile=demo -y

mkdir -p istio_addons/extras
cd istio_addons
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/grafana.yaml
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/jaeger.yaml
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/kiali.yaml
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/prometheus.yaml

cd extras
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/extras/prometheus-operator.yaml
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/extras/prometheus_vm.yaml
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/extras/prometheus_vm_tls.yaml
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/extras/skywalking.yaml
curl -O https://raw.githubusercontent.com/istio/istio/master/samples/addons/extras/zipkin.yaml

cd ../..
kubectl apply -f istio_addons

mkdir ./hipstershop
curl -o ./hipstershop/kubernetes-manifests.yaml \
    https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml
istioctl kube-inject -f hipstershop/kubernetes-manifests.yaml -o ./hipstershop/kubernetes-manifests-withistio.yaml
kubectl apply -f ./hipstershop/kubernetes-manifests-withistio.yaml

curl -o ./hipstershop/istio-manifests.yaml \
    https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml
kubectl apply -f hipstershop/istio-manifests.yaml

# Security
curl -O https://raw.githubusercontent.com/GoogleCloudPlatform/istio-samples/master/security-intro/manifests/mtls-frontend.yaml
kubectl apply -f mtls-frontend.yaml
curl -O https://raw.githubusercontent.com/GoogleCloudPlatform/istio-samples/master/security-intro/manifests/mtls-default-ns.yaml
kubectl apply -f mtls-default-ns.yaml
