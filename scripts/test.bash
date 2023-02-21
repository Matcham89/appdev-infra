state_bucket_present=$(gcloud storage buckets list --project mm-cicd-2020 | grep bkt-mm-2020)
# Create storage bucket
if [[ -n "$state_bucket_present" ]]; then
gcloud storage buckets create gs://$state_bucket --project $cicd_project_id --location $default_region
else
  echo "Storage Bucket Present"
fi