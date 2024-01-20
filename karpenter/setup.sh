#! /bin/bash

#vars
KARPENTER_IAM_ROLE_ARN=""
CLUSTER_ID=""
CLUSTER_ENDPOINT=""
KARPENTER_PROFILE=""

if ! helm repo list | grep -q 'karpenter'; then
    helm repo add karpenter https://charts.karpenter.sh/
else
    echo "Karpenter Helm repo installed already!"
fi


# Running Helm chart

helm upgrade --install --namespace karpenter --create-namespace \
    karpenter karpenter/karpenter \
    --version 0.16.3 \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN} \
    --set clusterName=${CLUSTER_ID} \
    --set clusterEndpoint=${CLUSTER_ENDPOINT} \
    --set aws.defaultInstanceProfile=${KARPENTER_PROFILE}-${CLUSTER_ID} 

