Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$archivePath = Join-Path $root 'game.love'
$outputDir = Join-Path $root 'game'
$workspacePython = Join-Path $root '.venv\Scripts\python.exe'
$loveJsConfigPath = Join-Path $root 'lovejs.json'
$gameTitle = 'Game'

if (Test-Path $loveJsConfigPath) {
    $loveJsConfig = Get-Content $loveJsConfigPath | ConvertFrom-Json
    if ($loveJsConfig.TITLE) {
        $gameTitle = [string]$loveJsConfig.TITLE
    }
}

$excludedFiles = @(
    'package.json',
    'package-lock.json',
    'run.bat',
    'run.sh',
    'main.py',
    'game.love'
)

$excludedDirectories = @(
    'node_modules',
    'game',
    '.git',
    '.vscode',
    '__pycache__'
)

function Test-ExcludedPath {
    param(
        [string]$RelativePath
    )

    $normalized = $RelativePath -replace '\\', '/'
    $segments = $normalized.Split('/', [System.StringSplitOptions]::RemoveEmptyEntries)

    if ($segments.Length -eq 0) {
        return $true
    }

    if ($excludedFiles -contains $segments[-1]) {
        return $true
    }

    foreach ($segment in $segments) {
        if ($excludedDirectories -contains $segment) {
            return $true
        }
    }

    return $false
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $baseUri = [System.Uri]((Resolve-Path $BasePath).Path + [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri](Resolve-Path $TargetPath).Path

    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString())
}

if (Test-Path $archivePath) {
    Remove-Item $archivePath -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$archive = [System.IO.Compression.ZipFile]::Open($archivePath, [System.IO.Compression.ZipArchiveMode]::Create)

try {
    Get-ChildItem -Path $root -Recurse -File | ForEach-Object {
        $fullPath = $_.FullName
        $relativePath = Get-RelativePath -BasePath $root -TargetPath $fullPath

        if (Test-ExcludedPath $relativePath) {
            return
        }

        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $archive,
            $fullPath,
            ($relativePath -replace '\\', '/'),
            [System.IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null
    }
}
finally {
    $archive.Dispose()
}

if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
}

Push-Location $root
try {
    & npx love.js.cmd -t $gameTitle game.love game

    Copy-Item (Join-Path $root 'main.py') (Join-Path $outputDir 'main.py') -Force
    Copy-Item (Join-Path $root 'run.sh') (Join-Path $outputDir 'run.sh') -Force

    Push-Location $outputDir
    try {
        if (Get-Command bash -ErrorAction SilentlyContinue) {
            & bash ./run.sh
        }
        elseif (Test-Path $workspacePython) {
            & $workspacePython .\main.py
        }
        elseif (Get-Command py -ErrorAction SilentlyContinue) {
            & py .\main.py
        }
        elseif (Get-Command python -ErrorAction SilentlyContinue) {
            & python .\main.py
        }
        else {
            throw 'Neither bash nor Python is available to launch the generated web server.'
        }
    }
    finally {
        Pop-Location
    }
}
finally {
    Pop-Location
}