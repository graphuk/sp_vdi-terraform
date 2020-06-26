$owner = "graphuk"
$repo_name = "sp_vdi-terraform"
$branch = "master"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$wc = New-Object System.Net.WebClient

Function DownloadProject
{
    $uri = "https://github.com/$owner/$repo_name/archive/$branch.zip"
    $zip = Join-Path $PSScriptRoot "$branch.zip"
    $wc.DownloadFile($uri, $zip)
    Expand-Archive -Path $zip -DestinationPath $PSScriptRoot -Force
    Remove-Item -Path $zip
}

Function DownloadTerraform([string] $directory)
{
    $version = "0.12.24"
    $os = "windows"
    $arch = "amd64"
    $terraform_uri = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip"
    $terraform_zip = Join-Path $directory "terraform.zip"
    $wc.DownloadFile($terraform_uri, $terraform_zip)
    Expand-Archive -Path $terraform_zip -DestinationPath $directory -Force
    Remove-Item -Path $terraform_zip
}

$vars =
""

DownloadProject

$repo_directory = Join-Path $PSScriptRoot "$repo_name-$branch"
pushd $repo_directory

$tfvars_file = "user-vars.tfvars"
New-Item -Path . -Name $tfvars_file -ItemType "file" -Force -Value $vars

DownloadTerraform($repo_directory)

.\terraform.exe init
.\terraform.exe apply -var-file="$tfvars_file"

popd