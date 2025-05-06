#!/usr/bin/env bash
set -e

# -------------------------------------------
# Instagram Reel → Subtitles Environment Setup
# -------------------------------------------

# 1. Create and activate Python virtual environment
if [ ! -d "venv" ]; then
  echo "Creating virtual environment..."
  python3 -m venv venv
else
  echo "Virtual environment already exists. Skipping creation."
fi

# Activate venv
echo "Activating virtual environment..."
# shellcheck disable=SC1091
source venv/bin/activate

# 2. Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# 3. Install Python dependencies
echo "Installing Python packages: yt-dlp, ffmpeg-python, openai-whisper, srt..."
pip install yt-dlp ffmpeg-python openai-whisper srt

# 4. Ensure ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
  echo "ffmpeg not found. Installing system ffmpeg..."
  if [ "$(uname)" = "Darwin" ]; then
    if command -v brew &> /dev/null; then
      brew install ffmpeg
    else
      echo "Homebrew not found. Please install Homebrew and rerun."
      exit 1
    fi
  else
    sudo apt-get update
    sudo apt-get install -y ffmpeg
  fi
else
  echo "ffmpeg is already installed"
fi

# 5. Final message
echo "\n✅ Environment setup complete!"
echo "To activate, run: source venv/bin/activate"
