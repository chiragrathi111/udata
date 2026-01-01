#!/bin/bash

# Working S3 Migration Script for 1250 objects
set -e

echo "=== S3 Migration for 1250 Objects (4.8 GiB) ==="

# Configuration
SOURCE_BUCKET="cogito-videos"
SOURCE_REGION="us-east-2"
SOURCE_ACCESS_KEY=""
SOURCE_SECRET_KEY=""

DEST_BUCKET="cogito-videos-new"
DEST_REGION="us-east-1"
DEST_ACCESS_KEY=""
DEST_SECRET_KEY=""

# Create temp directory
TEMP_DIR="/tmp/s3-migration-$$"
mkdir -p "$TEMP_DIR"

# Functions for credential switching
set_source_creds() {
    export AWS_ACCESS_KEY_ID="$SOURCE_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$SOURCE_SECRET_KEY"
    export AWS_DEFAULT_REGION="$SOURCE_REGION"
}

set_dest_creds() {
    export AWS_ACCESS_KEY_ID="$DEST_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$DEST_SECRET_KEY"
    export AWS_DEFAULT_REGION="$DEST_REGION"
}

echo "Source: s3://$SOURCE_BUCKET (1250 objects, 4.8 GiB)"
echo "Destination: s3://$DEST_BUCKET"
echo ""

# Get complete list of all objects (with pagination)
echo "Getting complete list of all 1250 objects..."
set_source_creds

# Use aws s3 ls which handles pagination automatically
aws s3 ls "s3://$SOURCE_BUCKET" --recursive > "$TEMP_DIR/all_objects.txt"

# Extract just the object keys (4th column onwards)
awk '{for(i=4;i<=NF;i++) printf "%s%s", $i, (i==NF?"\n":" ")}' "$TEMP_DIR/all_objects.txt" > "$TEMP_DIR/object_keys.txt"

TOTAL_OBJECTS=$(wc -l < "$TEMP_DIR/object_keys.txt")
echo "Found $TOTAL_OBJECTS objects to migrate"

if [ "$TOTAL_OBJECTS" -eq 0 ]; then
    echo "No objects found!"
    exit 1
fi

# Confirm migration
echo ""
read -p "Start migration of $TOTAL_OBJECTS objects? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    rm -rf "$TEMP_DIR"
    exit 0
fi

# Start migration
echo ""
echo "Starting migration..."
echo "Progress will be shown every 50 objects"

COPIED=0
FAILED=0
BATCH_SIZE=50

# Process objects in batches
while IFS= read -r object_key; do
    if [ -n "$object_key" ]; then
        # Download from source
        set_source_creds
        if aws s3 cp "s3://$SOURCE_BUCKET/$object_key" "$TEMP_DIR/current_file" >/dev/null 2>&1; then
            
            # Upload to destination
            set_dest_creds
            if aws s3 cp "$TEMP_DIR/current_file" "s3://$DEST_BUCKET/$object_key" >/dev/null 2>&1; then
                COPIED=$((COPIED + 1))
            else
                echo "Failed to upload: $object_key"
                FAILED=$((FAILED + 1))
            fi
            
            # Clean up temp file
            rm -f "$TEMP_DIR/current_file"
        else
            echo "Failed to download: $object_key"
            FAILED=$((FAILED + 1))
        fi
        
        # Progress update every 50 objects
        PROCESSED=$((COPIED + FAILED))
        if [ $((PROCESSED % BATCH_SIZE)) -eq 0 ]; then
            PERCENT=$((PROCESSED * 100 / TOTAL_OBJECTS))
            echo "Progress: $PROCESSED/$TOTAL_OBJECTS ($PERCENT%) - Copied: $COPIED, Failed: $FAILED"
        fi
    fi
done < "$TEMP_DIR/object_keys.txt"

# Final results
echo ""
echo "=== Migration Results ==="
echo "Total objects: $TOTAL_OBJECTS"
echo "Successfully copied: $COPIED"
echo "Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo "✓ All objects migrated successfully!"
else
    echo "! $FAILED objects failed to migrate"
fi

# Verify destination
echo ""
echo "Verifying destination bucket..."
set_dest_creds
DEST_COUNT=$(aws s3 ls "s3://$DEST_BUCKET" --recursive | wc -l)
echo "Objects in destination: $DEST_COUNT"

if [ "$DEST_COUNT" -eq "$COPIED" ]; then
    echo "✓ Object count matches!"
else
    echo "! Count mismatch - Expected: $COPIED, Found: $DEST_COUNT"
fi

# Get destination size
DEST_SIZE=$(aws s3 ls "s3://$DEST_BUCKET" --recursive --summarize | grep "Total Size" | awk '{print $3, $4}')
echo "Destination size: $DEST_SIZE"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "=== Migration Complete ==="
echo "Your 4.8 GiB data has been migrated from cogito-videos to cogito-videos-new"