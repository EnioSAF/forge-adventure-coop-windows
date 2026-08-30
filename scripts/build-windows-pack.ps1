param(
    [Parameter(Mandatory = $true)]
    [string]$SourceArchive,

    [Parameter(Mandatory = $true)]
    [string]$CoopJar,

    [string]$OutputRoot = (Join-Path $PSScriptRoot '..\artifacts'),

    [string]$JavaRuntimeDir,

    [switch]$SkipZip
)

$ErrorActionPreference = 'Stop'
$packName = 'Forge-Adventure-Coop-2.0.13-Windows'
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$templates = Join-Path $repoRoot 'distribution\windows'
$sourcePath = [System.IO.Path]::GetFullPath($SourceArchive)
$jarPath = [System.IO.Path]::GetFullPath($CoopJar)
$outputPath = [System.IO.Path]::GetFullPath($OutputRoot)
$packPath = [System.IO.Path]::GetFullPath((Join-Path $outputPath $packName))

if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "Archive Forge introuvable : $sourcePath"
}
if (-not (Test-Path -LiteralPath $jarPath -PathType Leaf)) {
    throw "JAR coop introuvable : $jarPath"
}
if (-not (Test-Path -LiteralPath $templates -PathType Container)) {
    throw "Modeles Windows introuvables : $templates"
}
if (-not $packPath.StartsWith($outputPath + [System.IO.Path]::DirectorySeparatorChar,
        [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Le dossier final doit rester sous OutputRoot.'
}

New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
if (Test-Path -LiteralPath $packPath) {
    Remove-Item -LiteralPath $packPath -Recurse -Force
}
New-Item -ItemType Directory -Path $packPath -Force | Out-Null

Write-Host 'Extraction de la distribution Forge 2.0.13...'
& tar -xf $sourcePath -C $packPath
if ($LASTEXITCODE -ne 0) {
    throw "Extraction impossible, code tar : $LASTEXITCODE"
}

$removeFiles = @(
    'adventure-editor.cmd',
    'adventure-editor.command',
    'adventure-editor.sh',
    'adventure-editor-jar-with-dependencies.jar',
    'forge-adventure.cmd',
    'forge-adventure.command',
    'forge-adventure.exe',
    'forge-adventure.sh',
    'forge.cmd',
    'forge.command',
    'forge.exe',
    'forge.sh',
    'forge-gui-desktop-2.0.13-jar-with-dependencies.jar',
    'forge-gui-mobile-dev-2.0.13-jar-with-dependencies.jar',
    'forge.profile.properties.example'
)
foreach ($relative in $removeFiles) {
    $candidate = Join-Path $packPath $relative
    if (Test-Path -LiteralPath $candidate) {
        Remove-Item -LiteralPath $candidate -Force
    }
}

Copy-Item -LiteralPath $jarPath -Destination (Join-Path $packPath 'forge-adventure-coop.jar') -Force
Copy-Item -LiteralPath (Join-Path $templates 'PLAY COOP.bat') -Destination $packPath -Force
Copy-Item -LiteralPath (Join-Path $templates 'INSTALL.bat') -Destination $packPath -Force
Copy-Item -LiteralPath (Join-Path $templates 'RESTORE-UNINSTALL.bat') -Destination $packPath -Force
Copy-Item -LiteralPath (Join-Path $templates 'README-FR.txt') -Destination $packPath -Force
Copy-Item -LiteralPath (Join-Path $templates 'VERSION.txt') -Destination $packPath -Force
Copy-Item -LiteralPath (Join-Path $templates 'SOURCE.txt') -Destination $packPath -Force
Copy-Item -LiteralPath (Join-Path $templates 'forge.profile.properties') -Destination $packPath -Force
Copy-Item -LiteralPath (Join-Path $repoRoot 'reference\Forge-MTG-Adventure-Multiplayer\LICENSE') `
    -Destination (Join-Path $packPath 'LICENSE.txt') -Force

New-Item -ItemType Directory -Path (Join-Path $packPath 'portable-data\home') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $packPath 'portable-data\user') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $packPath 'portable-data\user\preferences') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $packPath 'portable-data\cache') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $packPath 'portable-data\logs') -Force | Out-Null

if ($JavaRuntimeDir) {
    $runtimeSource = [System.IO.Path]::GetFullPath($JavaRuntimeDir)
    $javaExe = Join-Path $runtimeSource 'bin\java.exe'
    if (-not (Test-Path -LiteralPath $javaExe -PathType Leaf)) {
        throw "Runtime Java invalide : $runtimeSource"
    }
    Write-Host 'Ajout du runtime Java portable...'
    Copy-Item -LiteralPath $runtimeSource -Destination (Join-Path $packPath 'runtime') -Recurse -Force
}

$manifestFiles = @(
    'forge-adventure-coop.jar',
    'PLAY COOP.bat',
    'INSTALL.bat',
    'RESTORE-UNINSTALL.bat',
    'README-FR.txt',
    'VERSION.txt',
    'SOURCE.txt',
    'LICENSE.txt',
    'forge.profile.properties'
)
$manifest = foreach ($relative in $manifestFiles) {
    $file = Join-Path $packPath $relative
    $hash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $relative"
}
Set-Content -LiteralPath (Join-Path $packPath 'SHA256SUMS.txt') -Value $manifest -Encoding utf8

if (-not $SkipZip) {
    $zipPath = Join-Path $outputPath ($packName + '.zip')
    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }
    Write-Host 'Creation du ZIP...'
    Compress-Archive -LiteralPath $packPath -DestinationPath $zipPath -CompressionLevel Optimal
    $zipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
    Set-Content -LiteralPath ($zipPath + '.sha256') -Value "$zipHash  $($packName).zip" -Encoding ascii
    Write-Host "ZIP : $zipPath"
}

Write-Host "Pack : $packPath"
