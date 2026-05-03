param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$InputPath,

    [string]$OutputDir = "",
    [int[]]$StartSeconds = @(60, 300, 600),
    [int]$DurationSeconds = 20,
    [string]$FfmpegPath = ""
)

$ErrorActionPreference = "Stop"

$resolvedInput = Resolve-Path -LiteralPath $InputPath
$inputFile = Get-Item -LiteralPath $resolvedInput
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $repoRoot "voice-samples"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$resolvedOutputDir = Resolve-Path -LiteralPath $OutputDir

if ([string]::IsNullOrWhiteSpace($FfmpegPath)) {
    $ffmpeg = Get-Command ffmpeg -ErrorAction Stop
    $ffmpegPath = $ffmpeg.Source
}
else {
    $ffmpegPath = (Resolve-Path -LiteralPath $FfmpegPath).Path
}

$baseName = [IO.Path]::GetFileNameWithoutExtension($inputFile.Name)
$safeBaseName = $baseName -replace '[^A-Za-z0-9._-]', '_'
if ([string]::IsNullOrWhiteSpace($safeBaseName) -or $safeBaseName -notmatch '[A-Za-z0-9]') {
    $safeBaseName = "voice_sample"
}

for ($index = 0; $index -lt $StartSeconds.Count; $index++) {
    $start = $StartSeconds[$index]
    $sampleNumber = $index + 1
    $outputPath = Join-Path $resolvedOutputDir ("{0}_{1:00}_{2}s.wav" -f $safeBaseName, $sampleNumber, $DurationSeconds)

    & $ffmpegPath -y -ss $start -i $inputFile.FullName -t $DurationSeconds -ar 24000 -ac 1 -c:a pcm_s16le $outputPath
    if ($LASTEXITCODE -ne 0) {
        throw "ffmpeg sample split failed with exit code $LASTEXITCODE"
    }

    Write-Host "Created: $outputPath"
}
