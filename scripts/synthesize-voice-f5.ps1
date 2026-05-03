param(
    [Parameter(Mandatory = $true)]
    [string]$Text,

    [string]$RefAudio = ".\voice-samples\20250420_____01_20s.wav",
    [string]$RefText = "",
    [string]$OutputDir = "",
    [string]$OutputFile = "test-voice-f5.wav",
    [string]$FfmpegPath = "",
    [string]$Device = "cpu",
    [int]$NfeStep = 16
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$venvInfer = Join-Path $repoRoot ".venv\Scripts\f5-tts_infer-cli.exe"

if (-not (Test-Path -LiteralPath $venvInfer)) {
    throw "F5-TTS is not installed. Expected: $venvInfer"
}

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $repoRoot "generated-audio"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $repoRoot ".cache\matplotlib") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $repoRoot ".cache\huggingface") | Out-Null

$env:MPLCONFIGDIR = Join-Path $repoRoot ".cache\matplotlib"
$env:HF_HOME = Join-Path $repoRoot ".cache\huggingface"
$env:XDG_CACHE_HOME = Join-Path $repoRoot ".cache"

if ([string]::IsNullOrWhiteSpace($FfmpegPath)) {
    $sharedFfmpeg = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like "*Gyan.FFmpeg.Shared*" } |
        Select-Object -First 1
    if ($sharedFfmpeg) {
        $FfmpegPath = $sharedFfmpeg.FullName
    }
}

if (-not [string]::IsNullOrWhiteSpace($FfmpegPath)) {
    $ffmpeg = Resolve-Path -LiteralPath $FfmpegPath
    $env:PATH = "{0};{1}" -f (Split-Path -Parent $ffmpeg.Path), $env:PATH
}

$resolvedRefAudio = Resolve-Path -LiteralPath $RefAudio
$refTextArg = $RefText
if ([string]::IsNullOrWhiteSpace($refTextArg)) {
    $refTextArg = " "
}

& $venvInfer `
    --model F5TTS_v1_Base `
    --ref_audio $resolvedRefAudio `
    --ref_text $refTextArg `
    --gen_text $Text `
    --output_dir $OutputDir `
    --output_file $OutputFile `
    --remove_silence `
    --nfe_step $NfeStep `
    --device $Device

if ($LASTEXITCODE -ne 0) {
    throw "F5-TTS failed with exit code $LASTEXITCODE"
}
