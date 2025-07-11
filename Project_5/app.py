from flask import Flask, request
from transformers import pipeline
from typing import Optional
from youtube_transcript_api import (
    YouTubeTranscriptApi,
    TranscriptsDisabled,
    NoTranscriptFound,
    VideoUnavailable,
)

app = Flask(__name__)

# Define summarizer once
summarizer = pipeline("summarization")

# Summarization function that returns plain string
def summarize_text(text):
    result = summarizer(text, max_length=150, min_length=30, do_sample=False)
    return result[0]['summary_text']

# Transcript fetcher
def get_full_transcript(video_id: str, lang: str = "en") -> Optional[str]:
    api = YouTubeTranscriptApi()

    try:
        fetched = api.fetch(video_id, languages=[lang])
    except (NoTranscriptFound, TranscriptsDisabled):
        try:
            fetched = api.fetch(video_id)
        except (NoTranscriptFound, TranscriptsDisabled, VideoUnavailable):
            return None

    return " ".join(snippet.text.strip() for snippet in fetched)

# API route to get summary
@app.route('/', methods=['GET'])
def summarize_video():
    video_id = "aEzjOr5Ydm0"
    if not video_id:
        return "Missing 'video_id' query parameter.", 400

    transcript = get_full_transcript(video_id)
    if transcript is None:
        return "Transcript not available for this video.", 404

    summary = summarize_text(transcript)
    return summary, 200, {'Content-Type': 'text/plain; charset=utf-8'}

# Hello route
@app.route('/')
def index():
    return "✅ YouTube Summarizer API is running!"

if __name__ == '__main__':
    app.run(debug=True)
