import argparse
import yt_dlp
import ffmpeg
import whisper
import srt
from datetime import timedelta


def download_reel(url: str, output_path: str = "reel.mp4") -> str:
    """
    Download an Instagram reel using yt-dlp.
    """
    ydl_opts = {
        "format": "mp4",
        "outtmpl": output_path,
        # If downloading private reels, uncomment and set cookie file:
        # "cookiefile": "/path/to/instagram_cookies.txt",
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])
    return output_path


def extract_audio(video_path: str, audio_path: str = "reel.wav") -> str:
    """
    Extract a mono, 16 kHz WAV audio track from the video using ffmpeg.
    """
    (
        ffmpeg
        .input(video_path)
        .output(audio_path, ac=1, ar="16k")
        .overwrite_output()
        .run(quiet=True)
    )
    return audio_path


def transcribe(audio_path: str, model_size: str = "base") -> dict:
    """
    Transcribe the given audio file with OpenAI Whisper.
    Assumes English audio.
    """
    model = whisper.load_model(model_size)
    result = model.transcribe(audio_path, language="en")
    return result


def make_srt(transcription: dict, srt_path: str = "reel.srt") -> str:
    """
    Convert Whisper transcription segments into SRT subtitle format.
    """
    segments = transcription.get("segments", [])
    subs = []
    for i, seg in enumerate(segments, start=1):
        start = timedelta(seconds=seg["start"])
        end = timedelta(seconds=seg["end"])
        content = seg.get("text", "").strip()
        subs.append(srt.Subtitle(index=i, start=start, end=end, content=content))

    srt_content = srt.compose(subs)
    with open(srt_path, "w", encoding="utf-8") as f:
        f.write(srt_content)
    return srt_path


def main():
    parser = argparse.ArgumentParser(description="Download an Instagram reel and generate English subtitles.")
    parser.add_argument("url", help="Instagram reel URL")
    parser.add_argument("--model", default="base", choices=["tiny","base","small","medium","large"],
                        help="Whisper model size to use")
    parser.add_argument("--video", default="reel.mp4", help="Output video filename")
    parser.add_argument("--audio", default="reel.wav", help="Intermediate audio filename")
    parser.add_argument("--srt", default="reel.srt", help="Output subtitles filename")
    args = parser.parse_args()

    print(f"🔄 Downloading reel from {args.url}...")
    video_path = download_reel(args.url, args.video)

    print(f"🎵 Extracting audio to {args.audio}...")
    audio_path = extract_audio(video_path, args.audio)

    print(f"📝 Transcribing audio with Whisper ({args.model})...")
    transcription = transcribe(audio_path, model_size=args.model)

    print(f"💾 Writing subtitles to {args.srt}...")
    srt_file = make_srt(transcription, args.srt)

    print(f"✅ Done! Subtitles saved to {srt_file}")


if __name__ == "__main__":
    main()
