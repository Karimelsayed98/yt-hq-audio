#!/usr/bin/env bash
#
# install.sh — install the two dependencies yt-audio needs: yt-dlp and ffmpeg.
# Supports macOS (Homebrew) and Linux (apt / dnf / pacman + pipx for yt-dlp).
#
set -euo pipefail

info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

OS="$(uname -s)"

install_macos() {
  have brew || die "Homebrew not found. Install it from https://brew.sh then re-run."
  info "Installing yt-dlp + ffmpeg via Homebrew..."
  brew install yt-dlp ffmpeg
}

install_linux() {
  # ffmpeg from the system package manager
  if have apt-get; then
    info "Installing ffmpeg via apt..."
    sudo apt-get update && sudo apt-get install -y ffmpeg
  elif have dnf; then
    info "Installing ffmpeg via dnf..."
    sudo dnf install -y ffmpeg
  elif have pacman; then
    info "Installing ffmpeg via pacman..."
    sudo pacman -S --noconfirm ffmpeg
  else
    die "No supported package manager found. Install ffmpeg manually."
  fi

  # yt-dlp via pipx (preferred) or pip
  if have pipx; then
    info "Installing yt-dlp via pipx..."
    pipx install yt-dlp || pipx upgrade yt-dlp
  elif have pip3; then
    info "Installing yt-dlp via pip3..."
    pip3 install --user --upgrade yt-dlp
  else
    die "Need pipx or pip3 to install yt-dlp. Install Python first."
  fi

  cat <<'EOF'
Note: YouTube sometimes requires a JS runtime (deno) to solve player challenges.
If downloads fail with a "challenge" error, install deno:  https://deno.land
EOF
}

case "$OS" in
  Darwin) install_macos ;;
  Linux)  install_linux ;;
  *)      die "Unsupported OS: $OS (install yt-dlp and ffmpeg manually)" ;;
esac

echo
have yt-dlp && ok "yt-dlp $(yt-dlp --version 2>/dev/null)"
have ffmpeg && ok "ffmpeg $(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}')"
echo
ok "All set. Try:  ./yt-audio 'https://www.youtube.com/watch?v=...'"
