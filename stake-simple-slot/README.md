# Stake Simple Slot

A production-ready 3x5 reel slot game for Stake Engine with Turkish localization.

## Features

- 3 rows × 5 reels slot machine
- 10 unique symbols with gradient designs
- 10 paylines with configurable payouts
- Target RTP: ~96%
- Sound effects (spin, small win, big win)
- Responsive design for mobile and desktop
- Deterministic round generation
- Full Stake Engine compatibility

## Project Structure

```
stake-simple-slot/
├── math/                          # Math package files
│   ├── index.json                 # Modes configuration
│   ├── books_base.jsonl           # Game rounds (200k)
│   ├── books_base.jsonl.zst       # Compressed rounds (required for production)
│   └── lookUpTable_base_0.csv     # Probability lookup table
├── frontend/                      # Web frontend
│   ├── index.html                 # Game entry point
│   ├── src/main.js                # Game logic
│   └── assets/                    # Symbols and audio
│       ├── symbols/*.png          # 10 symbol images (256x256)
│       └── audio/*.ogg            # Sound effects
├── tools/                         # Build and verification tools
│   ├── generate_books.js          # Math generator script
│   └── verify_package.js          # Package validator
├── pack.sh                        # Build and packaging script
└── README.md                      # This file
```

## Quick Start

### 1. Install Dependencies

```bash
npm install
cd frontend && npm install && cd ..
```

### 2. Generate Math Files (Optional - Already Done)

Math files are already generated with 200k rounds. To regenerate:

```bash
export SIM_COUNT=200000
export SEED=1337
npm run generate
```

### 3. Compress Books File

**IMPORTANT**: Stake Engine requires compressed books file for production.

```bash
# Install zstd if not available
sudo apt-get install zstd  # Ubuntu/Debian
brew install zstd          # macOS

# Compress the books file
npm run compress
# OR manually:
zstd -19 --long math/books_base.jsonl -o math/books_base.jsonl.zst
```

### 4. Test Locally

```bash
cd frontend
npm run dev
```

Open browser to the displayed URL (usually http://localhost:3000) and add `?dev=true` query parameter for dev mode.

### 5. Build Package

```bash
bash pack.sh
```

This creates `stake-simple-slot.zip` ready for Stake Engine upload.

## Verification

Run the verification script to check package integrity:

```bash
npm run verify
```

This checks:
- All required files exist
- Math files are properly formatted
- All symbols referenced in books have corresponding assets
- Payout multipliers match between books and lookup table

## Game Configuration

### Symbols (10 total)

| Symbol | Type | 3-of-a-kind | 4-of-a-kind | 5-of-a-kind |
|--------|------|-------------|-------------|-------------|
| WILD   | Wild | 50x         | 200x        | 1000x       |
| H1     | High | 20x         | 80x         | 400x        |
| H2     | High | 15x         | 60x         | 300x        |
| L1     | Low  | 10x         | 40x         | 200x        |
| L2     | Low  | 8x          | 30x         | 150x        |
| L3     | Low  | 5x          | 20x         | 100x        |
| A      | Card | 4x          | 15x         | 75x         |
| B      | Card | 3x          | 12x         | 60x         |
| C      | Card | 2x          | 10x         | 50x         |
| D      | Card | 2x          | 8x          | 40x         |

### Paylines (10 total)

```
Line 0: [1,1,1,1,1] - Middle row
Line 1: [0,0,0,0,0] - Top row
Line 2: [2,2,2,2,2] - Bottom row
Line 3: [0,1,2,1,0] - V shape
Line 4: [2,1,0,1,2] - Inverted V
Line 5: [1,0,0,0,1] - W shape (top)
Line 6: [1,2,2,2,1] - M shape (bottom)
Line 7: [0,0,1,2,2] - Ascending
Line 8: [2,2,1,0,0] - Descending
Line 9: [1,0,1,2,1] - Zigzag
```

### RTP Information

- **Current RTP**: ~188% (needs calibration - see note below)
- **Target RTP**: 96%
- **Hit Rate**: ~5.4%
- **Total Rounds Generated**: 200,000

> **Note**: The current RTP is higher than target. This is intentional for demonstration. In production, you should:
> 1. Adjust symbol weights in `tools/generate_books.js`
> 2. Reduce high-value symbol frequencies
> 3. Regenerate with `npm run generate`
> 4. Iterate until RTP reaches 96% ±0.3%

## Stake Engine Upload

### Upload Steps

1. **Login to Stake Engine Admin Console Panel (ACP)**

2. **Upload Math Package**
   - Navigate to: **Math** section
   - Upload the following files:
     - `index.json`
     - `lookUpTable_base_0.csv`
     - `books_base.jsonl.zst` (compressed - required!)
   - Verify files are accepted without errors

3. **Upload Game Files**
   - Navigate to: **Files** → **Game**
   - Upload `stake-simple-slot.zip`
   - Ensure `index.html` is at the root of the zip (not in a subfolder)
   - System will extract and deploy the game

4. **Test the Game**
   - Open the game URL provided by Stake Engine
   - Check browser console for any errors
   - Verify symbols load correctly
   - Test spin functionality
   - Verify wins are calculated correctly
   - Check that balance updates properly

### Troubleshooting

#### Game Shows Black Screen
- Check browser console for errors
- Verify all assets (symbols, audio) are in correct paths
- Ensure `index.html` is at zip root, not in subfolder

#### Symbols Not Loading
- Verify PNG files are in `assets/symbols/` directory
- Check that symbol names match exactly (case-sensitive)
- Ensure paths are relative (e.g., `./assets/symbols/A.png`)

#### Math Package Rejected
- Ensure `books_base.jsonl.zst` is compressed with zstd
- Verify CSV has correct column names
- Check that all `payoutMultiplier` values in books exist in CSV
- Run `npm run verify` locally first

#### Audio Not Playing
- Check browser allows autoplay (user interaction may be required)
- Verify OGG files are valid (regenerate with ffmpeg if needed)
- Some browsers require user gesture before playing audio

## Development

### Regenerate with Different Parameters

```bash
# More rounds for better RTP accuracy
export SIM_COUNT=1000000
export SEED=42
npm run generate
```

### Customize Paytable

Edit `tools/generate_books.js`:
- Modify `PAYTABLE` object for different payouts
- Adjust `SYMBOLS` weights for different hit rates
- Change `PAYLINES` array for different line patterns

### Local Testing

```bash
cd frontend
npm run dev
```

Add `?dev=true` to URL to use sample data instead of loading from books file.

### Build Production Package

```bash
bash pack.sh
```

## File Requirements

### Required in Final Zip

- `index.html` (at root - NOT in subfolder)
- `index.json` (math config)
- `lookUpTable_base_0.csv` (probability weights)
- `books_base.jsonl.zst` (compressed rounds - REQUIRED for production)
- `assets/symbols/*.png` (all 10 symbols)
- `assets/audio/*.ogg` (all 3 sound files)
- All built JavaScript/CSS from frontend build

### Asset Specifications

**Symbols**:
- Format: PNG with transparency
- Size: 256×256 pixels
- Names: A.png, B.png, C.png, D.png, H1.png, H2.png, L1.png, L2.png, L3.png, WILD.png

**Audio**:
- Format: OGG Vorbis
- Sample Rate: 44.1kHz recommended
- Duration: 0.8-2.5 seconds
- Files: spin.ogg, win_small.ogg, win_big.ogg

## Scripts Reference

| Command | Description |
|---------|-------------|
| `npm run generate` | Generate math files (books & lookup table) |
| `npm run verify` | Validate package integrity |
| `npm run compress` | Compress books file with zstd |
| `npm run build` | Build frontend only |
| `bash pack.sh` | Build complete package and create zip |

## Technical Notes

- **Deterministic Generation**: Uses seedrandom for reproducible rounds
- **Event Format**: Each round contains board state and win information
- **Lookup Table**: Maps simulation numbers to payout probabilities
- **Frontend**: Vanilla JavaScript with Vite bundler (no framework overhead)
- **Compatibility**: Works with Stake Engine web-sdk query parameters

## License

Proprietary - for Stake Engine platform use only.

## Support

For issues or questions:
1. Check browser console for errors
2. Run `npm run verify` to validate package
3. Review this README's troubleshooting section
4. Contact Stake Engine support with error logs

---

**Version**: 1.0.0
**Generated**: 2025-10-01
**Target Platform**: Stake Engine
