
# RUN ON SNOWFLAKE
# SHOW IMAGE REPOSITORIES;
# example : gxktfis-datahub-dev.registry.snowflakecomputing.com/adm_snowflake/datahub/datahub_repository

$prefix = "urlrepository_url"
$prefix = "gxktfis-datahub-dev.registry.snowflakecomputing.com/adm_snowflake/datahub/datahub_repository"

# Get all images: repository:tag
$images = docker images --format "{{.Repository}}:{{.Tag}}"
snow spcs image-registry token --connection DATAHUB_CONN --format=JSON | docker login gxktfis-datahub-dev.registry.snowflakecomputing.com --username 0sessiontoken  --password-stdin

foreach ($image in $images) {
    # extract only repository (before ":")
    $repository = $image.Split(":")[0]
    $tag = $image.Split(":")[1]

    # Check images of Datahub
    if ($repository -like "acryldata/*" -or
        $repository -like "confluentinc/*" -or
        $repository -eq "mariadb" -or
        $repository -eq "elasticsearch") {
        
        # Extract last name (ex: datahub-gms)
        if ($repository -like "*/ *") {
            $name = $repository.Split("/")[-1]
        } else {
            $name = $repository
        }

        # Build and show tag command
        $newTag = "$prefix/$name"+":$tag"
        docker tag $image $newTag
        docker push $newTag
        Write-Output "Pushed into snowflake: $newTag"
        docker image rmi $newTag
        Write-Output "remove image/tag: $newTag"

    }
}
