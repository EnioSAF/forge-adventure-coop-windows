param(
    [string]$SourceArchive = (Join-Path $PSScriptRoot '..\downloads\forge-installer-2.0.13.tar.bz2'),
    [string]$CoopJar = (Join-Path $PSScriptRoot '..\reference\Forge-MTG-Adventure-Multiplayer\forge-gui-mobile-dev\target\forge-gui-mobile-dev-2.0.13-SNAPSHOT-jar-with-dependencies.jar'),
    [string]$OutputRoot = (Join-Path $PSScriptRoot '..\artifacts\pack-test')
)

$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$builder = Join-Path $PSScriptRoot 'build-windows-pack.ps1'
if (Test-Path -LiteralPath $OutputRoot) {
    Remove-Item -LiteralPath $OutputRoot -Recurse -Force
}
$fakeRuntime = Join-Path $OutputRoot 'fake-runtime'
New-Item -ItemType Directory -Path (Join-Path $fakeRuntime 'bin') -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $fakeRuntime 'bin\java.exe') -Force | Out-Null
Set-Content -LiteralPath (Join-Path $fakeRuntime 'runtime-marker.txt') -Value 'portable-java-test'

& $builder -SourceArchive $SourceArchive -CoopJar $CoopJar -OutputRoot $OutputRoot `
    -JavaRuntimeDir $fakeRuntime -SkipZip

$pack = Join-Path $OutputRoot 'Forge-Adventure-Coop-2.0.13-Windows'
$jar = Join-Path $pack 'forge-adventure-coop.jar'

Assert-True (Test-Path -LiteralPath $jar) 'le JAR coop doit être présent'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'res\adventure')) 'les ressources Adventure doivent être présentes'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'PLAY COOP.bat')) 'PLAY COOP.bat doit être présent'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'INSTALL.bat')) 'INSTALL.bat doit être présent'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'RESTORE-UNINSTALL.bat')) 'RESTORE-UNINSTALL.bat doit être présent'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'README-FR.txt')) 'README-FR.txt doit être présent'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'LICENSE.txt')) 'la GPL doit être incluse'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'SOURCE.txt')) 'le lien vers les sources doit être inclus'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'VERSION.txt')) 'la version exacte doit être incluse'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'SHA256SUMS.txt')) 'le manifeste SHA-256 doit être inclus'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'runtime\bin\java.exe')) 'Java portable doit être inclus'
Assert-True (Test-Path -LiteralPath (Join-Path $pack 'portable-data\user\preferences')) 'le dossier de préférences Forge doit exister au premier lancement'
Assert-True ((Get-Content -LiteralPath (Join-Path $pack 'runtime\runtime-marker.txt') -Raw).Contains('portable-java-test')) 'le runtime choisi doit être copié'

$expectedHash = (Get-FileHash -LiteralPath $CoopJar -Algorithm SHA256).Hash
$actualHash = (Get-FileHash -LiteralPath $jar -Algorithm SHA256).Hash
Assert-True ($actualHash -eq $expectedHash) 'le JAR distribué doit être le JAR coop compilé'

$launcher = Get-Content -LiteralPath (Join-Path $pack 'PLAY COOP.bat') -Raw
Assert-True ($launcher.Contains('runtime\bin\java.exe')) 'le lanceur doit préférer Java portable'
Assert-True ($launcher.Contains('-version >nul 2>&1')) 'le lanceur doit vérifier que Java démarre sans parser sa sortie'
Assert-True (-not $launcher.Contains('for /f "tokens=3"')) 'le lanceur ne doit pas utiliser le parsing fragile de java -version'
Assert-True ($launcher.Contains('-Duser.home=')) 'le lanceur doit isoler le profil utilisateur'
Assert-True ($launcher.Contains('forge-adventure-coop.jar')) 'le lanceur doit utiliser le JAR coop renommé'

$profile = Get-Content -LiteralPath (Join-Path $pack 'forge.profile.properties') -Raw
Assert-True ($profile.Contains('./portable-data/user')) 'les sauvegardes doivent rester dans le pack'
Assert-True ($profile.Contains('./portable-data/cache')) 'le cache doit rester dans le pack'

$forbidden = Get-ChildItem -LiteralPath $pack -Recurse -File | Where-Object {
    $_.Name -match '^hs_err_pid.*\.log$' -or
    $_.FullName -match '[\\/]backup-original[\\/]' -or
    $_.FullName -match '[\\/]portable-data[\\/].+[\\/](TestHOST|TestCLIENT)([\\/]|$)'
}
Assert-True ($forbidden.Count -eq 0) 'aucun crash, backup ou sauvegarde de test ne doit être distribué'

Write-Host 'PASS: contenu du pack Windows 2.0.13 valide.'
