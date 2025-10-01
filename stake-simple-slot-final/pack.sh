#!/bin/bash

set -e

echo "=== Stake Simple Slot - Package Builder ==="
echo ""

BUILD_DIR="build"
ZIP_NAME="stake-simple-slot.zip"

if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

echo "Installing frontend dependencies..."
cd frontend
npm install

echo "Building frontend..."
npm run build

echo "Copying frontend build to package..."
cd ..
cp -r frontend/dist/* "$BUILD_DIR/"

if [ ! -f "$BUILD_DIR/index.html" ]; then
    echo "Error: index.html not found in build output"
    exit 1
fi

echo "Copying math files..."
cp math/index.json "$BUILD_DIR/"
cp math/lookUpTable_base_0.csv "$BUILD_DIR/"

if [ -f math/books_base.jsonl.zst ]; then
    echo "Using compressed books file..."
    cp math/books_base.jsonl.zst "$BUILD_DIR/"
else
    echo "Warning: books_base.jsonl.zst not found"
    if [ -f math/books_base.jsonl ]; then
        echo "Copying uncompressed books file as fallback..."
        cp math/books_base.jsonl "$BUILD_DIR/"
        echo ""
        echo "⚠️  WARNING: Using uncompressed books file!"
        echo "For production, compress with: zstd -19 --long math/books_base.jsonl -o math/books_base.jsonl.zst"
        echo ""
    else
        echo "Error: No books file found!"
        exit 1
    fi
fi

echo "Copying assets..."
mkdir -p "$BUILD_DIR/assets/symbols"
mkdir -p "$BUILD_DIR/assets/audio"
cp frontend/assets/symbols/*.png "$BUILD_DIR/assets/symbols/" 2>/dev/null || echo "Warning: No PNG symbols found"
cp frontend/assets/audio/*.ogg "$BUILD_DIR/assets/audio/" 2>/dev/null || echo "Warning: No audio files found"

echo "Creating zip archive..."
cd "$BUILD_DIR"
if command -v zip &> /dev/null; then
    zip -r "../$ZIP_NAME" . -q
    echo "✓ Created ../$ZIP_NAME"
else
    echo "Error: 'zip' command not found. Install with: sudo apt-get install zip"
    exit 1
fi
cd ..

ZIP_SIZE=$(du -h "$ZIP_NAME" | cut -f1)
echo ""
echo "=== BUILD COMPLETE ==="
echo "Package: $ZIP_NAME ($ZIP_SIZE)"
echo "Build directory: $BUILD_DIR/"
echo ""
echo "Contents:"
ls -lh "$BUILD_DIR" | tail -n +2 | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "✓ Ready for Stake Engine upload!"
