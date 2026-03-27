# FiveM Circle Minigame Automation

![Minigame Preview](solve_circle.png)

An intelligent AutoHotkey automation script for FiveM circular timing minigames. This tool uses computer vision techniques to detect game elements in real-time and execute perfect inputs with human-like reaction delays.

## Features

- **Computer Vision Detection**: Uses pixel search algorithms to locate the circle, target zone (red arc), and progress indicator
- **Intelligent Angle Calculation**: Calculates angular positions using `atan2` for precise timing detection
- **Dual Mode Support**: Handles both standard and "top-right" minigame orientations automatically
- **Human-Like Delays**: Configurable reaction times with randomized distribution to avoid detection
- **Real-Time Visualization**: Optional overlay to debug detection regions (Ctrl+F12)
- **Non-Intrusive**: Only reads screen pixels, does not modify game memory or files

## How It Works

The script follows this detection pipeline:

1. **Circle Detection**: Verifies the minigame is active by checking for the circle's background color
2. **Letter Recognition**: Identifies the key displayed in the center of the circle (W, A, S, D, etc.)
3. **Target Zone Detection**: Locates the red goal zone (point 'a') using color sampling
4. **Progress Tracking**: Tracks the moving progress bar (point 'b') across 8 search regions
5. **Angle Calculation**: Computes 360° angles between center-point for both target and progress
6. **Timing Logic**: Waits until progress enters the `anticipation` angle threshold before triggering
7. **Human Delay**: Applies a randomized reaction delay between `minReactionTime` and `maxReactionTime`

## Installation

### Prerequisites

- [AutoHotkey v1.1+](https://www.autohotkey.com/) (tested on v1.1)
- FiveM running in windowed or borderless window mode
- The minigame must be visible on screen (script uses pixel detection)

### Setup

1. Clone or download this repository
2. Ensure all files are in the same directory:
   - `circle.ahk` (main script)
   - `config.ini` (configuration file)
3. Double-click `circle.ahk` to run the script
4. The script will validate configuration and show instructions

## Configuration

Edit `config.ini` to adjust timing parameters:

```ini
[delays]
anticipation = 20          ; Angle threshold (degrees) to trigger anticipation
minReactionTime = 60       ; Minimum human reaction delay (ms)
maxReactionTime = 80       ; Maximum human reaction delay (ms)
```

| Parameter | Description | Recommended |
|-----------|-------------|-------------|
| `anticipation` | How many degrees before the target to trigger | 15-30 |
| `minReactionTime` | Fastest reaction time (ms) | 50-100 |
| `maxReactionTime` | Slowest reaction time (ms) | 80-150 |

**Note**: Higher anticipation values trigger earlier but risk hitting too soon. Lower values are more precise but require faster reactions.

## Usage

### Hotkeys

| Key | Function |
|-----|----------|
| `Ctrl + F11` | Toggle automation ON/OFF |
| `Ctrl + F12` | Show/Hide debug overlay (detection regions) |
| `1` | Test mode - manually search for target zone and move mouse to it |

### Workflow

1. Start the script before or during gameplay
2. Press `Ctrl+F11` to enable automation
3. When a minigame appears, the script will:
   - Detect the circle automatically
   - Track the progress bar rotation
   - Beep and display the letter when it's time to press
4. Press `Ctrl+F11` again to disable

## Technical Details

### Detection Regions

The script divides the screen into search zones for optimization:

- **9partes**: 3x3 grid for circle detection
- **8fila**: 8 horizontal strips for progress bar tracking
- **5columna**: 5 vertical strips for progress bar tracking
- **6partes/2partes**: Sub-regions for target detection

### Color Detection

- **Target Zone (Red)**: `0x0F00E9` (BGR format) with ±16 variation
- **Progress Bar**: `0x0F1416` (dark color) with ±32 variation
- **Circle Background**: `0xD8D9D8` (light gray) with ±8 variation

### Modes

- **Mode 0 (Normal)**: Standard circular progress (0°→360°)
- **Mode 1 (Top-Right)**: Special handling when target is in quadrant I (skips first lap)

## Important Notes

⚠️ **This is an incomplete script** - The key sending functionality is commented out. To complete the automation, uncomment the `sendDowSleepUp(letter)` lines in the `detectaCirculoLanza` function.

⚠️ **Screen coordinates are hardcoded** - The script uses fixed coordinates (760, 304) for the detection region. You may need to adjust `cuadroObjetivo` in the script to match your screen resolution and FiveM window position.

⚠️ **Use at your own risk** - While this script only uses pixel detection (not memory reading), automation tools may violate server rules. Check your server's TOS before using.

## Customization

### Adjusting Detection Area

If the minigame appears in a different screen location, modify this section in `main.ahk`:

```autohotkey
cuadroObjetivo := {"x1":760, "y1":304, "x2":760+149, "y2":304+149}
```

### Adding Key Sending

To enable automatic key presses, uncomment these lines in `detectaCirculoLanza()`:

```autohotkey
;sendDowSleepUp(letter)
```

And ensure `letter` variable is populated by implementing OCR or image recognition for the center text.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "config.ini > invalid values" | Check that all delay values are numeric and > 0 |
| "Goal zone missing" | The red target color may differ; adjust `colorMeta` array |
| "Progress bar missing" | Progress bar color may differ; adjust `franjaProgresiva` |
| Detection too slow | Reduce search regions or increase `SetBatchLines` |
| Overlay not showing | Run as administrator or check window coordinates |

**Disclaimer**: This tool is for educational purposes. The author is not responsible for any bans or penalties incurred from using this script on FiveM servers. Always respect server rules and terms of service.
