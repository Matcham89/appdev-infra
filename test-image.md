
### Test Image
For the infrastructure to be built, an image needs to be avaliable in the Artifact Registry
For testing purposes paste the output of the below commands in the Google Cloud Console


```bash
export _ARTIFACTREGISTRY=$( cat ./outputs.json | jq '.google_artifact_registry_repository_name.value' | tr -d '"' )
echo "Artifact Registry name: $_ARTIFACTREGISTRY"

export _CICDPROJECT=$( cat ./outputs.json | jq '.google_artifact_registry_repository_project_id.value' | tr -d '"' )
echo "Project name: $_CICDPROJECT"

export _REGION=$( cat ./outputs.json | jq '.google_artifact_registry_repository_project_region.value' | tr -d '"' )
echo "Region name: $_REGION"
```

```bash
echo docker pull us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
echo docker tag us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0 $_REGION-docker.pkg.dev/$_CICDPROJECT/$_ARTIFACTREGISTRY/webapp-ingest-image
echo docker push europe-west2-docker.pkg.dev/$_CICDPROJECT/$_ARTIFACTREGISTRY/webapp-ingest-image

echo docker pull us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
echo docker tag us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0 $_REGION-docker.pkg.dev/$_CICDPROJECT/$_ARTIFACTREGISTRY/yougov-ingest-image
echo docker push europe-west2-docker.pkg.dev/$_CICDPROJECT/$_ARTIFACTREGISTRY/yougov-ingest-image

echo docker pull us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
echo docker tag us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0 $_REGION-docker.pkg.dev/$_CICDPROJECT/$_ARTIFACTREGISTRY/did-ingest-image
echo docker push europe-west2-docker.pkg.dev/$_CICDPROJECT/$_ARTIFACTREGISTRY/did-ingest-image

echo docker pull us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
echo docker tag us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0 $_REGION-docker.pkg.dev/$_CICDPROJECT/$_ARTIFACTREGISTRY/nielsen-ingest-image:test
echo docker push europe-west2-docker.pkg.dev/$_CICDPROJECT/$_ARTIFACTREGISTRY/nielsen-ingest-image:test
```


Take the output commands and paste them into the Google Cloud Console terminal.

This will build the inital images for the infrastructure build.
