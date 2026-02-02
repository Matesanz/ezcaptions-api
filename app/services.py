from . import utils, settings


def burn_and_upload(input_video: str, ass_text: str) -> str:
    """
    Burn subtitles to a video and upload the result to Google Cloud Storage.

    Args:
        input_video (str): URL or path to the input video file.
        ass_text (str): Subtitle text in ASS format.

    Returns:
        str: Signed URL of the uploaded video with burned subtitles.
    """

    process_id = utils.create_unique_id()

    temp_ass_filename = f"{process_id}.ass"
    temp_video_filename = f"{process_id}.mp4"
    temp_video_burned_filename = f"{process_id}_output.mp4"

    utils.create_text_file(text=ass_text, filename=temp_ass_filename)
    utils.download_file_from_url(url=input_video, filename=temp_video_filename)
    utils.burn_subtitles_to_video(
        input_video=temp_video_filename,
        ass_file=temp_ass_filename,
        output_video=temp_video_burned_filename,
    )
    utils.upload_to_gcs(file_path=temp_video_burned_filename, bucket_name=settings.BUCKET_NAME)
    temp_video_burned_url = utils.create_signed_url(
        bucket_name=settings.BUCKET_NAME, blob_name=temp_video_burned_filename
    )
    utils.remove_file(temp_ass_filename)
    utils.remove_file(temp_video_filename)
    utils.remove_file(temp_video_burned_filename)
    return temp_video_burned_url
