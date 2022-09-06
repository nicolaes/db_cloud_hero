


export CLUSTER_NAME=central
export CLUSTER_ZONE=us-east4-b
export CLUSTER_VERSION=1.22.11-gke.400


gcloud beta container clusters create $CLUSTER_NAME \
  --zone $CLUSTER_ZONE --num-nodes 4 \
  --machine-type "e2-standard-2" --image-type "COS" \
  --cluster-version=$CLUSTER_VERSION --enable-ip-alias \
  --addons=Istio --istio-config=auth=MTLS_STRICT

export GCLOUD_PROJECT=$(gcloud config get-value project)
gcloud container clusters get-credentials $CLUSTER_NAME \
  --zone $CLUSTER_ZONE --project $GCLOUD_PROJECT

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account)

export LAB_DIR=$HOME/Projects/anthos_workspace/bookinfo-lab
export ISTIO_VERSION=1.4.6
mkdir $LAB_DIR
cd $LAB_DIR
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -

cd ./istio-*
export PATH=$PWD/bin:$PATH

kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

