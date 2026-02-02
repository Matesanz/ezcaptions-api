#!/bin/bash

# Upload video to GCS and generate V4 signed URL
# Usage: ./upload_with_signed_url.sh <local_file> <bucket_name> <destination_name>

set -e

# Check arguments
if [ $# -ne 3 ]; then
    echo '{"status": "error", "message": "Usage: upload_with_signed_url.sh <local_file> <bucket_name> <destination_name>"}'
    exit 1
fi

LOCAL_FILE="$1"
BUCKET_NAME="$2"
DEST_NAME="$3"

# Validate local file exists
if [ ! -f "$LOCAL_FILE" ]; then
    echo "{\"status\": \"error\", \"message\": \"File not found: $LOCAL_FILE\"}"
    exit 1
fi

# Validate bucket name is set
if [ -z "$BUCKET_NAME" ]; then
    echo '{"status": "error", "message": "BUCKET_NAME is not set"}'
    exit 1
fi

# Get file info for verbose output
FILE_SIZE=$(stat -c%s "$LOCAL_FILE" 2>/dev/null || echo "unknown")
FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1024 / 1024" | bc -l 2>/dev/null || echo "unknown")

echo "Starting upload process..."
echo "Local file: $LOCAL_FILE"
echo "File size: ${FILE_SIZE} bytes (${FILE_SIZE_MB} MB)"
echo "Destination: gs://${BUCKET_NAME}/${DEST_NAME}"
echo "Upload in progress..."

# Upload file to GCS with verbose output
if ! gsutil -m cp -v "$LOCAL_FILE" "gs://${BUCKET_NAME}/${DEST_NAME}"; then
    echo "{\"status\": \"error\", \"message\": \"Failed to upload file to gs://${BUCKET_NAME}/${DEST_NAME}. Check gsutil output above for details.\"}"
    exit 1
fi

echo "Upload completed successfully!"

# Generate V4 signed URL (valid for 1 hour)
echo "Generating signed URL..."
echo "Target: gs://${BUCKET_NAME}/${DEST_NAME}"

# Check if gsutil is available and configured
echo "Checking gsutil configuration..."
if ! command -v gsutil >/dev/null 2>&1; then
    echo "{\"status\": \"error\", \"message\": \"gsutil command not found\"}"
    exit 1
fi

# Check gsutil configuration
echo "Running: gsutil version"
gsutil version

echo "Checking authentication..."
if ! gsutil ls gs://${BUCKET_NAME}/ >/dev/null 2>&1; then
    echo "{\"status\": \"warning\", \"message\": \"Cannot list bucket contents - may affect signed URL generation\"}"
fi

echo "Testing gsutil access to the object..."
if ! gsutil ls "gs://${BUCKET_NAME}/${DEST_NAME}"; then
    echo "{\"status\": \"error\", \"message\": \"Cannot access uploaded object gs://${BUCKET_NAME}/${DEST_NAME}\"}"
    exit 1
fi

echo "Running gsutil signurl command..."
echo "Command: gsutil signurl -d 1h -u \"gs://${BUCKET_NAME}/${DEST_NAME}\""

# Run gsutil signurl with verbose output to see any errors
echo "About to execute gsutil signurl..."
set +e  # Don't exit on error temporarily
SIGNURL_OUTPUT=$(gsutil signurl -d 1h -u "gs://${BUCKET_NAME}/${DEST_NAME}" 2>&1)
SIGNURL_EXIT_CODE=$?
set -e  # Re-enable exit on error

echo "Command completed"
echo "gsutil signurl output:"
echo "$SIGNURL_OUTPUT"
echo "Exit code: $SIGNURL_EXIT_CODE"

if [ $SIGNURL_EXIT_CODE -ne 0 ]; then
    if echo "$SIGNURL_OUTPUT" | grep -q "Cannot get service account email"; then
        echo "{\"status\": \"error\", \"message\": \"Signed URL generation requires a service account. Current authentication is user-based. Options: 1) Set GOOGLE_APPLICATION_CREDENTIALS to a service account key file, 2) Use 'gcloud auth activate-service-account', or 3) Use 'gsutil signurl' with '-u service-account@project.iam.gserviceaccount.com'. Error: $SIGNURL_OUTPUT\"}"
    else
        echo "{\"status\": \"error\", \"message\": \"gsutil signurl failed with exit code $SIGNURL_EXIT_CODE. Output: $SIGNURL_OUTPUT\"}"
    fi
    exit 1
fi

# Extract the signed URL from the output
SIGNED_URL=$(echo "$SIGNURL_OUTPUT" | tail -n 1 | awk '{print $NF}')

echo "Extracted signed URL: $SIGNED_URL"

if [ -z "$SIGNED_URL" ]; then
    echo "{\"status\": \"error\", \"message\": \"Failed to extract signed URL from output: $SIGNURL_OUTPUT\"}"
    exit 1
fi

# Return JSON response
echo "{\"status\": \"success\", \"url\": \"$SIGNED_URL\"}"
