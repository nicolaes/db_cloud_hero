


export CLUSTER_REGION=us-west1



export CLUSTER_NAME=central
export GCLOUD_PROJECT=$(gcloud config get-value project)

gcloud container clusters \
  get-credentials $CLUSTER_NAME \
  --region $CLUSTER_REGION \
  --project $GCLOUD_PROJECT

istioctl install --set profile=demo -y
git clone https://github.com/istio/istio.git
cd istio && kubectl apply -f samples/addons

cd $LAB_DIR
git clone https://github.com/GoogleCloudPlatform/istio-samples.git
cd istio-samples/security-intro

mkdir ./hipstershop
curl -o ./hipstershop/kubernetes-manifests.yaml \
    https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml
istioctl kube-inject -f hipstershop/kubernetes-manifests.yaml -o ./hipstershop/kubernetes-manifests-withistio.yaml
kubectl apply -f ./hipstershop/kubernetes-manifests-withistio.yaml

curl -o ./hipstershop/istio-manifests.yaml \
    https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml
kubectl apply -f hipstershop/istio-manifests.yaml

# Security
kubectl apply -f ./manifests/mtls-frontend.yaml
kubectl apply -f ./manifests/mtls-default-ns.yaml
