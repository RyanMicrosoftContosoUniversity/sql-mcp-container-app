# Deploy an image from ACR to a new ACA



### Get the name of the resource group where you want to create the Container App
```
$rg = 'private-apps-rg'
```


### Get the container apps environment name
```
$environment = 'cae-multillm-swc'
```


### Choose the container app name
```
$app = 'sql-mcp-products-ca'
```


### Get the azure container registry name where the image you want to use is stored
```
$acrName = 'crmultillmcontosouniversity'
```




### Get the image and tag you'd like to deploy from the ACR Repository
```
$imageTag = 'sql-mcp-app:2.0'
```


### Create an identity name, identity will be created later
```
$identityName = 'sql-mcp-app-pull-mi'
```


# Get needed ACR values
```
$acr = az acr show --name "$acrName" --output json | ConvertFrom-Json
```




### Get ACR login server
```
$server = $acr.loginServer
```




### Create image name
```
$image = "${server}/${imageTag}"
```


### Validate that the image exists
```
az acr repository show --name "$acrName" --image "$imageTag" --output table
```


### Get the container app resource ID
```
$envId = az containerapp env show --name "$environment" --resource-group "$rg" --query id --output tsv
```


### Create the user-assigned identity that will pull the image
```
$identity = az identity create --name "$identityName" --resource-group "$rg" --output json | ConvertFrom-Json

$pullIdentityId = $identity.id

$pullPrincipalId = $identity.principalId
```


### Grant the identity permission to pull from ACR.  Handle for both modes
```
$pullRole = switch ($acr.roleAssignmentMode) {
    'LegacyRegistryPermissions' { 'AcrPull' }
    'AbacRepositoryPermissions' { 'Container Registry Repository Reader' }
    default { throw 'Registry permission mode was not recognized. Stop here.' }
}

Write-Host "Granting role: $pullRole"
```



### Create role assignment
```
az role assignment create --assignee-object-id "$pullPrincipalId" --assignee-principal-type ServicePrincipal --role "$pullRole" --scope "$($acr.id)" --output none
```




### Supply the SQL Connection String
```
$secureSql = Read-Host 'Paste the complete SQL connection string' -AsSecureString

$sqlConnectionString = [System.Net.NetworkCredential]::new('', $secureSql).Password
```


###  Create the container app
```
$createArgs = @(
    'containerapp', 'create'
    '--name', $app
    '--resource-group', $rg
    '--environment', $envId
    '--container-name', 'mcp-products'
    '--image', $image
    '--user-assigned', $pullIdentityId
    '--registry-server', $server
    '--registry-identity', $pullIdentityId
    '--secrets', "sql-connection=$sqlConnectionString"
    '--env-vars', 'MSSQL_CONNECTION_STRING=secretref:sql-connection'
    '--ingress', 'internal'
    '--target-port', '5000'
    '--min-replicas', '1'
    '--max-replicas', '1'
    '--revision-suffix', 'release-v1'
    '--output', 'none'
)
```


### Create container app
```
az @createArgs
```