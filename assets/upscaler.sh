#!/bin/bash

# Check if upscaler is installed
if ! command -v upscaler &> /dev/null; then
    echo "Error: upscaler is not installed. Please install it first."
    exit 1
fi

# Process images with direction prefixes
for direction in north east west south; do
    # Find all matching PNG files
    for img in ${direction}*.png; do
        # Check if file exists (to handle case when no matches are found)
        if [ -f "$img" ]; then
            # Get current dimensions
            dimensions=$(identify -format "%wx%h" "$img")
            
            # If dimensions are not 128x128, resize and upscale the image
            if [ "$dimensions" != "128x128" ]; then
                echo "Processing $img..."
                # First upscale the image
                upscaler -s 2x "$img"
                # Rename the upscaled output back to original filename
                mv "${img%.*}_upscaled.png" "$img"
                # Then resize to exact dimensions
                convert "$img" -resize 128x128! "$img"
            else
                echo "$img is already 128x128"
            fi
        fi
    done
done

echo "Processing complete!"