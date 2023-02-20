#!/bin/bash

function delete_subfolders()
{
    local current_folder=$1

    # Delete projects directly under current folder
    delete_project $current_folder

    # Fetch list of subfolders
    subfolders=$( gcloud resource-manager folders list --folder="$current_folder" --format='value(name)' )

    # Iterate over each subfolder, deleting projects and subfolders
    for folder in $subfolders
    do 
        delete_subfolders $folder
        echo "Deleting folder: $folder"
        gcloud resource-manager folders delete $folder --quiet
    done
}

function delete_project()
{
    local current_folder=$1

    projects=$( gcloud projects list --filter="parent.id=$current_folder" --format='value(projectId)' )

    for project in $projects
    do 
        echo "Deleting project: $project"
        delete_project_lien $project
        gcloud projects delete $project --quiet
    done
}

function delete_project_lien()
{
    local project_id=$1

    project_liens=$( gcloud alpha resource-manager liens list --format="value(name)" --project=${project_id} )

    for lien in $project_liens
    do 
        echo "Deleting project lien: $lien"
        gcloud alpha resource-manager liens delete ${lien} --project=${project_id}
    done
}

# Delete all subfolders and projects under folder ID "XXXXX"
folder_id="1029706125675"
delete_subfolders $folder_id