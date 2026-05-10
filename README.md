# VoiceTool

這個 repo 是個人語音工具箱。目前已可做中文語音轉文字，之後會把文字轉語音也整合在同一個專案裡。

## 功能

- 語音轉文字：把音檔轉成 `.txt` 和 `.srt`
- 文字轉語音：預留中，未實作

## 目錄

```text
audio-inbox/       # 放入要轉文字的原始音檔
voice-samples/     # 放入文字轉語音使用的個人聲音範例
generated-audio/   # 之後放文字轉語音產生的音檔
transcripts/       # 語音轉文字輸出
scripts/           # 可執行腳本
docs/              # 使用說明
models/            # 本機模型，不提交 git
tools/             # 本機工具，不提交 git
```

## 語音轉文字

```powershell
.\transcribe-zh.cmd ".\audio-inbox\sample.m4a"
```

輸出會放在 `transcripts/`。

更多說明請看：

```text
docs\中文語音轉文字使用說明.md
```

## 文字轉語音

文字轉語音目前使用 F5-TTS 做本機測試。輸出會放在 `generated-audio/`。

```text
scripts\synthesize-voice-f5.ps1
docs\文字轉語音使用說明.md
voice-samples\
generated-audio\
```

聲音範例建議放在 `voice-samples/`。這邊有我的音檔範例，之後可以先來這邊找。請使用 10 到 30 秒、背景安靜、只有單一說話者的短音檔。

長錄音可以用這個腳本切成幾段 20 秒範例：

```powershell
.\scripts\split-voice-samples.ps1 ".\audio-inbox\20250420練講三寶.m4a"
```

如果剛安裝 FFmpeg 後系統還找不到 `ffmpeg`，可以先關掉並重開終端機，或用 `-FfmpegPath` 指定 `ffmpeg.exe`。

產生測試語音：

```powershell
.\scripts\synthesize-voice-f5.ps1 -Text "各位同學大家好，今天我們一起練習中文語音合成。"
```

## 新電腦準備

第一次在新電腦使用 F5-TTS：

```powershell
.\scripts\setup-f5-tts.ps1
```

再把參考聲音檔手動放到：

```text
voice-samples\clean-ref-zh.wav
```

對應文字已放在：

```text
voice-samples\clean-ref-zh.txt
```

聲音檔不會提交到 git，請用 USB、雲端硬碟或其他私密方式帶到新電腦。
