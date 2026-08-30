$ErrorActionPreference = 'Stop'

function Assert-Contains {
    param([string]$Text, [string]$Expected, [string]$Message)
    if (-not $Text.Contains($Expected)) { throw "ASSERTION FAILED: $Message" }
}

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$workflowPath = Join-Path $root '.github\workflows\windows-pack.yml'
if (-not (Test-Path -LiteralPath $workflowPath -PathType Leaf)) {
    throw 'ASSERTION FAILED: le workflow GitHub Windows doit exister'
}

$workflow = Get-Content -LiteralPath $workflowPath -Raw
Assert-Contains $workflow 'c1139d5c1f7ceb3e17ce50718a9929e9134867e2' 'le fork doit être épinglé au commit testé'
Assert-Contains $workflow 'forge-installer-2.0.13.tar.bz2' 'la base officielle 2.0.13 doit être téléchargée'
Assert-Contains $workflow 'mvn' 'le fork doit être compilé par Maven'
Assert-Contains $workflow 'jlink' 'Java portable doit être produit'
Assert-Contains $workflow 'build-windows-pack.ps1' 'le même constructeur local doit être utilisé'
Assert-Contains $workflow 'actions/upload-artifact@v4' 'le ZIP doit être publié comme artifact'
Assert-Contains $workflow 'gh release' 'les tags doivent publier une GitHub Release'

Write-Host 'PASS: workflow GitHub Windows valide.'
