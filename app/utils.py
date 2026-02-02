from google.cloud import storage
import os
from datetime import datetime, timedelta, timezone
import ffmpeg
from typing import Optional
import requests
import uuid


def create_unique_id() -> str:
    """
    Creates a unique identifier string.

    Returns:
        str: A unique UUID string
    """
    return str(uuid.uuid4())


def download_file_from_url(url: str, filename: str) -> bool:
    """
    Downloads a file from a URL and saves it locally.

    Args:
        url (str): The URL to download the file from
        filename (str): The local path/filename to save the file

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()

        with open(filename, "wb") as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)
        return True
    except requests.RequestException as e:
        print(f"Error downloading file: {e}")
        return False


def remove_file(file_path: str) -> bool:
    """
    Removes a file from the filesystem.

    Args:
        file_path (str): Path to the file to remove

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        os.remove(file_path)
        return True
    except OSError as e:
        print(f"Error removing file: {e}")
        return False


def create_text_file(text: str, filename: str) -> None:
    """
    Creates a file with the given text content.

    Args:
        text (str): The text content to write to the file
        filename (str): The name/path of the file to create
    """
    with open(filename, "w", encoding="utf-8") as file:
        file.write(text)


def upload_to_gcs(file_path: str, bucket_name: str, blob_name: str = None) -> str:
    """
    Uploads a file to Google Cloud Storage bucket.

    Args:
        file_path (str): Local path to the file to upload
        bucket_name (str): Name of the GCS bucket
        blob_name (str, optional): Name for the file in the bucket.
                                    If None, uses the filename from file_path

    Returns:
        str: The public URL of the uploaded file
    """

    # Initialize the GCS client
    client = storage.Client()
    bucket = client.bucket(bucket_name)

    # Use filename if blob_name not provided
    blob_name = blob_name or os.path.basename(file_path)

    # Create blob and upload file
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(file_path)

    # Return the public URL
    return f"gs://{bucket_name}/{blob_name}"


def create_signed_url(
    bucket_name: str, blob_name: str, expiration_time: int = 3600
) -> str:
    """
    Creates a signed URL for downloading a file from Google Cloud Storage.

    Args:
        bucket_name (str): Name of the GCS bucket
        blob_name (str): Name of the blob/file in the bucket
        expiration_time (int, optional): URL expiration time in seconds. Defaults to 3600 (1 hour)

    Returns:
        str: The signed URL for downloading the file
    """

    # Initialize the GCS client
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)

    # Generate signed URL
    signed_url = blob.generate_signed_url(
        version="v4",
        expiration=datetime.now(timezone.utc) + timedelta(seconds=expiration_time),
        method="GET",
    )

    return signed_url


def burn_subtitles_to_video(
    input_video: str,
    ass_file: str,
    output_video: str,
    fonts_directory: Optional[str] = None,
) -> bool:
    """
    Burns subtitles from an ASS file into a video using ffmpeg.

    Args:
        input_video (str): Path to the input video file
        ass_file (str): Path to the ASS subtitle file
        output_video (str): Path for the output video file
        fonts_directory (str, optional): Path to fonts directory for subtitle rendering

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # Define the input stream
        stream = ffmpeg.input(input_video)

        # Apply the video filter
        if fonts_directory:
            stream = ffmpeg.filter(
                stream, "subtitles", ass_file, fontsdir=fonts_directory
            )
        else:
            stream = ffmpeg.filter(stream, "subtitles", ass_file)

        # Define output with audio copying
        out = ffmpeg.output(stream, output_video, acodec="copy")

        # Run it (overwrite_output=True is same as -y)
        ffmpeg.run(out, overwrite_output=True)
        return True
    except ffmpeg.Error as e:
        print(f"Error: {e.stderr.decode()}")
        return False
