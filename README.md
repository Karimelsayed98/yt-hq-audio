# yt-hq-audio

Download **high-quality audio** from YouTube (and most other sites) by just
pasting links. Grabs the best available audio stream and, by default, keeps it
in its **native codec with no lossy re-encoding**.

## 1. Install dependencies (one time)

```bash
./install.sh
```

This installs the only two tools needed:

| Tool      | Role                                              |
|-----------|---------------------------------------------------|
| **yt-dlp** | Downloads the audio stream                        |
| **ffmpeg** | Extracts / converts audio, embeds metadata + art  |

- **macOS:** uses Homebrew (`brew install yt-dlp ffmpeg`). Install Homebrew first from <https://brew.sh> if you don't have it.
- **Linux:** installs ffmpeg via apt/dnf/pacman and yt-dlp via pipx/pip.

Or just install them yourself:

```bash
brew install yt-dlp ffmpeg          # macOS
# or: sudo apt install ffmpeg && pipx install yt-dlp   # Debian/Ubuntu
```

## 2. Download audio

```bash
# One link — best quality, native Opus, no re-encoding (default)
./yt-audio "https://www.youtube.com/watch?v=k2CjGx_mLOg"

# Several links at once
./yt-audio "https://youtu.be/AAA" "https://youtu.be/BBB"

# From a file of links (one URL per line)
./yt-audio -b links.txt
```

Files land in `./downloads/` by default.

## Options

```
-f, --format FMT   opus (default) | m4a | mp3 | flac | wav
-o, --outdir DIR   output directory (default: ./downloads)
-b, --batch FILE   read URLs from FILE (one per line, # comments allowed)
-h, --help         show help
```

### Which format?

| Format   | Quality                          | Use when…                                  |
|----------|----------------------------------|--------------------------------------------|
| **opus** | Best — native, no re-encode      | Default. You just want the best audio.     |
| **m4a**  | Native AAC, no double-compress   | You need Apple/QuickTime compatibility.    |
| **mp3**  | Lossy re-encode                  | You need it to play literally everywhere.  |
| **flac** | Lossless container               | A tool requires FLAC input.                |
| **wav**  | Lossless 16-bit/48 kHz PCM       | A DAW/editor requires WAV input. (~650 MB/hr) |

> ⚠️ YouTube audio is already lossy (~130–160 kbps). Converting to **wav/flac**
> does **not** improve quality — it only makes a much bigger file. Use them only
> when a specific app demands that format.

## Examples

```bash
./yt-audio -f mp3 "https://youtu.be/dQw4w9WgXcQ"
./yt-audio -f wav -o ~/Music/stems "https://youtu.be/dQw4w9WgXcQ"
./yt-audio -b links.txt -f m4a
```

## Troubleshooting

- **`yt-dlp not found` / `ffmpeg not found`** → run `./install.sh`.
- **YouTube "challenge" / signature errors** → update yt-dlp (`brew upgrade yt-dlp`
  or `pipx upgrade yt-dlp`). On Linux you may also need [deno](https://deno.land).
- **Age-restricted / private videos** → may require passing cookies; see
  `yt-dlp --help` (`--cookies-from-browser`).
