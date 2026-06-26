#!/bin/bash
set -e

echo "⚠️  Starting safe teardown playbook for Project Bedrock..."

# 1. Purge all dynamic active K8s objects to release Cloud ELBs
if command -v kubectl &> /dev/null && kubectl config get-contexts | grep -q "project-bedrock"; then
    echo "🔄 Deleting Kubernetes ingresses and services to drop AWS Load Balancers..."
    kubectl delete ingress --all --all-namespaces || true
    kubectl delete service --all --all-namespaces || true
    echo "⏳ Waiting 2 minutes for AWS ELBs to cleanly untangle from subnets..."
    sleep 120
fi

# 2. Clear out the S3 versioned bucket contents (Terraform will fail to delete non-empty buckets)
BUCKET_NAME=$(terraform -chdir=terraform/environment/prod output -raw assets_bucket_name 2>/dev/null || echo "")
if [ ! -z "$BUCKET_NAME" ]; then
    echo "🧹 Purging all object versions from S3 Asset Bucket: $BUCKET_NAME..."
    aws s3 api delete-objects --bucket "$BUCKET_NAME" \
        --delete "$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query '{Objects: Versions[].{Key: Key, VersionId: VersionId}}')" || true
    aws s3 api delete-objects --bucket "$BUCKET_NAME" \
        --delete "$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query '{Objects: DeleteMarkers[].{Key: Key, VersionId: VersionId}}')" || true
fi

# 3. Trigger the standard declarative infrastructure purge
echo "🔥 Running Terraform Destroy..."
terraform -chdir=terraform/environment/prod destroy -auto-approve

echo "✅ All AWS infrastructure resources have been cleanly torn down. Cost accrual stopped."