param(
    [switch]$SkipFfmpeg
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$venvPython = Join-Path $repoRoot ".venv\Scripts\python.exe"
$requirements = Join-Path $repoRoot "requirements-f5-tts.txt"

if (-not (Test-Path -LiteralPath $venvPython)) {
    python -m venv (Join-Path $repoRoot ".venv")
}

& $venvPython -m pip install --upgrade pip setuptools wheel
& $venvPython -m pip install -r $requirements

if (-not $SkipFfmpeg) {
    $sharedFfmpeg = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like "*Gyan.FFmpeg.Shared*" } |
        Select-Object -First 1

    if (-not $sharedFfmpeg) {
        winget install --id Gyan.FFmpeg.Shared -e --source winget --accept-package-agreements --accept-source-agreements
    }
}

New-Item -ItemType Directory -Force -Path `
    (Join-Path $repoRoot "voice-samples"), `
    (Join-Path $repoRoot "generated-audio"), `
    (Join-Path $repoRoot ".cache\matplotlib"), `
    (Join-Path $repoRoot ".cache\huggingface") | Out-Null

Write-Host "F5-TTS setup complete."
Write-Host "Copy your reference audio to:"
Write-Host "  voice-samples\clean-ref-zh.wav"
Write-Host "Reference text is tracked at:"
Write-Host "  voice-samples\clean-ref-zh.txt"
