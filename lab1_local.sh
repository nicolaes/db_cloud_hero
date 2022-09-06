gcloud auth login

export PROJECT_ID=$(gcloud projects list --filter="qwiklabs-gcp-" \
    --format 'value(projectId)' --limit=1)
gcloud config set project $PROJECT_ID

export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")
export CLUSTER_NAME=central
export CLUSTER_ZONE=us-west1-c
export WORKLOAD_POOL=${PROJECT_ID}.svc.id.goog
export MESH_ID="proj-${PROJECT_NUMBER}"

gcloud config set compute/zone ${CLUSTER_ZONE}
gcloud beta container clusters create ${CLUSTER_NAME} \
    --machine-type=n1-standard-4 \
    --num-nodes=4 \
    --workload-pool=${WORKLOAD_POOL} \
    --enable-stackdriver-kubernetes \
    --subnetwork=default \
    --release-channel=regular \
    --labels mesh_id=${MESH_ID}

curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.12 > asmcli
chmod +x asmcli

./asmcli install \
  --project_id $PROJECT_ID \
  --cluster_name $CLUSTER_NAME \
  --cluster_location $CLUSTER_ZONE \
  --fleet_id $PROJECT_ID \
  --output_dir ./asm_output \
  --enable_all \
  --option legacy-default-ingressgateway \
  --ca mesh_ca \
  --enable_gcp_components

echo "READY ASMCLI INSTALL"

export GATEWAY_NS=istio-gateway
kubectl create namespace $GATEWAY_NS

kubectl get deploy -n istio-system -l app=istiod -o \
jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}'

REVISION=$(kubectl get deploy -n istio-system -l app=istiod -o \
jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}')

kubectl label namespace $GATEWAY_NS \
istio.io/rev=$REVISION --overwrite

cd ./asm_output
kubectl apply -n $GATEWAY_NS -f samples/gateways/istio-ingressgateway
kubectl label namespace default istio-injection- istio.io/rev=$REVISION --overwrite

cd istio-1.12.9-asm.0
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
