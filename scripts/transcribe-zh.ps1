param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$InputPath,

    [string]$OutputDir = "",
    [string]$Model = ".\models\ggml-base.bin",
    [string]$Language = "zh",
    [string]$Prompt = ""
)

$ErrorActionPreference = "Stop"

$resolvedInput = Resolve-Path -LiteralPath $InputPath
$inputFile = Get-Item -LiteralPath $resolvedInput
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$whisper = Join-Path $repoRoot "tools\whisper-bin-x64\Release\whisper-cli.exe"
$ffmpeg = Get-Command ffmpeg -ErrorAction Stop
$modelPath = Resolve-Path -LiteralPath (Join-Path $repoRoot $Model)

if ([string]::IsNullOrWhiteSpace($Prompt)) {
    $Prompt = -join ([char[]](0x4EE5, 0x4E0B, 0x662F, 0x7E41, 0x9AD4, 0x4E2D, 0x6587, 0x6F14, 0x8B1B, 0x9010, 0x5B57, 0x7A3F, 0x3002))
}

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $repoRoot "transcripts"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$resolvedOutputDir = Resolve-Path -LiteralPath $OutputDir

$baseName = [IO.Path]::GetFileNameWithoutExtension($inputFile.Name)
$safeBaseName = $baseName -replace '[^A-Za-z0-9._-]', '_'
if ([string]::IsNullOrWhiteSpace($safeBaseName) -or $safeBaseName -notmatch '[A-Za-z0-9]') {
    $safeBaseName = "audio_{0:yyyyMMdd_HHmmss}" -f (Get-Date)
}
$safeWavPath = Join-Path $resolvedOutputDir "$safeBaseName.16k.wav"
$outputBase = Join-Path $resolvedOutputDir $safeBaseName

& $ffmpeg.Source -y -i $inputFile.FullName -ar 16000 -ac 1 -c:a pcm_s16le $safeWavPath
if ($LASTEXITCODE -ne 0) {
    throw "ffmpeg conversion failed with exit code $LASTEXITCODE"
}

& $whisper -m $modelPath -f $safeWavPath -l $Language --no-gpu --prompt $Prompt -otxt -osrt -of $outputBase
if ($LASTEXITCODE -ne 0) {
    throw "whisper transcription failed with exit code $LASTEXITCODE"
}

Write-Host "Done:"
Write-Host "  Text: $outputBase.txt"
Write-Host "  SRT : $outputBase.srt"
