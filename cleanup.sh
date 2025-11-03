#!/bin/bash

# SpeedLab Server - Cleanup Script
# Removes all temporary files from Storage/uploads/ directory
# Keeps .gitkeep file to preserve directory in git

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPLOADS_DIR="$SCRIPT_DIR/Storage/uploads"

echo "🧹 SpeedLab Server - Cleanup Script"
echo "=================================="

# Check if uploads directory exists
if [ ! -d "$UPLOADS_DIR" ]; then
    echo "❌ Error: Upload directory not found at $UPLOADS_DIR"
    exit 1
fi

# Count files before cleanup (excluding .gitkeep)
FILE_COUNT=$(find "$UPLOADS_DIR" -type f ! -name '.gitkeep' | wc -l | tr -d ' ')

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "✅ No files to clean. Directory is already empty."
    exit 0
fi

echo "📁 Upload directory: $UPLOADS_DIR"
echo "📊 Files to remove: $FILE_COUNT"
echo ""

# Ask for confirmation
read -p "⚠️  Continue with cleanup? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

# Remove all files except .gitkeep
echo "🗑️  Removing files..."
find "$UPLOADS_DIR" -type f ! -name '.gitkeep' -delete

# Count remaining files
REMAINING=$(find "$UPLOADS_DIR" -type f ! -name '.gitkeep' | wc -l | tr -d ' ')

if [ "$REMAINING" -eq 0 ]; then
    echo "✅ Cleanup completed successfully!"
    echo "📊 $FILE_COUNT file(s) removed"
else
    echo "⚠️  Warning: $REMAINING file(s) could not be removed"
    exit 1
fi
