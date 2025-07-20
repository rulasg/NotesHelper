
function Get-TemplatePath{
    param (
        [Parameter(Mandatory,Position=0)][string]$Name
    )

    $filename = $name + ".template.md"

    $local = $PSScriptRoot
    $templatePath = $local | join-path -Child $filename

    if (-not (Test-Path -Path $templatePath)) {
        Write-Warning "Template file not found: $Name"
        return $null
    }

    return $templatePath
}

function Get-FileContent{
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$FilePath
    )

    if (-not (Test-Path -Path $FilePath)) {
        throw "File not found: $FilePath"
    }

    return Get-Content -Path $FilePath -Raw
}