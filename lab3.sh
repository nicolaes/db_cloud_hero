
CLUSTER_ZONE_HERE

export GCLOUD_PROJECT=$(gcloud config get-value project)
gcloud container clusters get-credentials $CLUSTER_NAME \
    --zone $CLUSTER_ZONE --project $GCLOUD_PROJECT

kubectl get pods -n asm-system

sudo apt install siege

export GATEWAY_URL=$(kubectl get svc istio-ingressgateway \
-o=jsonpath='{.status.loadBalancer.ingress[0].ip}' -n istio-system)
echo "The gateway address is $GATEWAY_URL"

siege http://${GATEWAY_URL}/productpage > /dev/null &

kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/networking/destination-rule-all.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/networking/virtual-service-all-v1.yaml

