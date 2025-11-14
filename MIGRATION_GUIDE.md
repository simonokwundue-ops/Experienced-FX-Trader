# Migration Guide - MT5 File Tree Structure

## Overview

This repository has been reorganized to follow the official MetaTrader 5 (MT5) file tree standard. This guide will help you understand the new structure and how to use it.

## What Changed?

### Old Structure (Before)
```
Experienced-FX-Trader/
├── ForexTrader_v3.2_MultiStrategy_Production.mq5
├── ForexTrader_v3.2_Scalper_Production.mq5
├── Config/
│   ├── ForexTrader_v3.2_Moderate.set
│   └── [Other .set files...]
├── Previous Logs/
├── [PDF files in root...]
└── [Documentation files...]
```

### New Structure (MT5 Standard)
```
Experienced-FX-Trader/
├── MQL5/                          # MT5 standard directory
│   ├── Experts/                   # Expert Advisor files (.mq5)
│   │   ├── ForexTrader_v3.2_MultiStrategy_Production.mq5 ⭐
│   │   ├── ForexTrader_v3.2_Scalper_Production.mq5 ⭐
│   │   ├── ForexTrader_v3_Production.mq5 ✅
│   │   ├── ForexTrader_v3_MultiStrategy_Production.mq5 ✅
│   │   └── [Legacy versions...]
│   ├── Presets/                   # Configuration presets (.set)
│   │   ├── ForexTrader_v3.2_Moderate.set
│   │   ├── ForexTrader_v3.2_Aggressive.set
│   │   ├── ForexTrader_v3.2_Scalper.set
│   │   └── [Other presets...]
│   ├── Files/                     # Data files, logs, and .ini tester configs
│   │   ├── ForexTrader_v3.2_MultiStrategy_Production.ini
│   │   ├── ForexTrader_v3.2_Scalper_Production.ini
│   │   ├── Previous Logs/
│   │   └── [Analysis files...]
│   └── Include/                   # Header files (.mqh) - for future use
├── Docs/                          # Educational materials
│   ├── Trading_Course_Advanced.pdf
│   ├── Ebook_Forex-A-Z_copy.pdf
│   └── [Other educational PDFs...]
└── [Documentation files...]       # README, guides, etc.
```

## File Locations

| File Type | Old Location | New Location |
|-----------|-------------|--------------|
| Expert Advisors (.mq5) | Root directory | `MQL5/Experts/` |
| Configuration presets (.set) | `Config/` | `MQL5/Presets/` |
| Strategy Tester configs (.ini) | Root directory | `MQL5/Files/` |
| Previous Logs | Root `Previous Logs/` | `MQL5/Files/Previous Logs/` |
| Educational PDFs | Root directory | `Docs/` |
| Analysis files (.py, .txt, .html) | Root directory | `MQL5/Files/` |
| Documentation (.md) | Root directory | Root directory (unchanged) |

## Benefits of the New Structure

### 1. **MT5 Compatibility**
The new structure matches the official MetaTrader 5 file tree standard, making deployment straightforward.

### 2. **Easy Installation**
Simply copy the entire `MQL5/` folder to your MT5 Data Folder:
```
From: [Repository]/MQL5/
To:   [MT5 Data Folder]/MQL5/
```

### 3. **Better Organization**
- Expert Advisors are in `MQL5/Experts/`
- Configuration presets are in `MQL5/Presets/`
- All data files are in `MQL5/Files/`
- Educational materials are in `Docs/`

### 4. **Industry Best Practices**
Follows the standard used by professional MQL5 developers worldwide.

## How to Use the New Structure

### Installation Method 1: Copy Entire MQL5 Folder

1. **Locate your MT5 Data Folder:**
   - In MT5, go to `File → Open Data Folder`
   - This typically opens: `C:\Users\<USER>\AppData\Roaming\MetaQuotes\Terminal\<TERMINAL_ID>\`

2. **Copy the MQL5 folder:**
   ```
   Copy: [Repository]/MQL5/
   To:   [MT5 Data Folder]/MQL5/
   ```
   
3. **Merge/Overwrite when prompted:**
   - This will place EAs in the correct location
   - Presets will be available in MetaEditor
   - Files will be accessible to your EAs

4. **Compile the EAs:**
   - Open MetaEditor (F4 in MT5)
   - Navigate to `MQL5/Experts/`
   - Open any EA file
   - Press F7 to compile

### Installation Method 2: Selective Copy

If you only want specific files:

1. **For Expert Advisors:**
   ```
   Copy: [Repository]/MQL5/Experts/[EA_Name].mq5
   To:   [MT5 Data Folder]/MQL5/Experts/
   ```

2. **For Configuration Presets:**
   ```
   Copy: [Repository]/MQL5/Presets/[Preset_Name].set
   To:   [MT5 Data Folder]/MQL5/Presets/
   ```

3. **For Strategy Tester Configs:**
   ```
   Copy: [Repository]/MQL5/Files/[Config_Name].ini
   To:   [MT5 Data Folder]/MQL5/Files/
   ```

## Loading Configuration Presets

### Old Method (Still Works)
1. Attach EA to chart
2. In settings, click "Load"
3. Browse to preset file manually

### New Method (MT5 Standard)
1. Attach EA to chart
2. In settings, click "Load"
3. Presets from `MQL5/Presets/` appear in the list automatically
4. Select your preset (e.g., `ForexTrader_v3.2_Moderate.set`)
5. Click "OK"

## Strategy Tester Configuration

The `.ini` files in `MQL5/Files/` serve as reference configurations for Strategy Tester:

1. Open Strategy Tester (Ctrl+R)
2. Select your EA from the Expert list
3. Manually configure settings based on the `.ini` file in `MQL5/Files/`
4. Or load the corresponding `.set` file from `MQL5/Presets/`

## Frequently Asked Questions

### Q: Do I need to change anything in my existing MT5 installation?
**A:** No, this change only affects the repository structure. Your MT5 installation works the same way.

### Q: What if I already have the old files installed?
**A:** You can either:
- Keep using them (they'll continue to work)
- Replace them with files from the new structure
- Use the new structure for fresh installations

### Q: Are the EAs themselves changed?
**A:** No, the EA code is identical. Only the file locations changed.

### Q: Can I still use the old Config/ folder?
**A:** The `Config/` folder no longer exists in the repository. Use `MQL5/Presets/` instead.

### Q: Where are the educational PDFs now?
**A:** All educational materials are in the `Docs/` folder.

### Q: Where are the Previous Logs?
**A:** They're now in `MQL5/Files/Previous Logs/`.

## Documentation Updates

All documentation has been updated to reflect the new paths:
- ✅ `README.md` - Updated with structure diagram and new paths
- ✅ `QUICKSTART_v3.md` - Updated preset paths
- ✅ `README_v3.2.md` - Updated configuration paths
- ✅ `STRATEGY_TESTER_GUIDE.md` - Updated preset references

## Need Help?

If you encounter any issues with the new structure:
1. Check this migration guide
2. Review the updated [README.md](README.md)
3. Open a GitHub issue with details

## Summary

The new MT5-standard file structure provides:
- ✅ Better organization
- ✅ Easier deployment
- ✅ Industry-standard layout
- ✅ Professional development practices
- ✅ Simpler file management

**Ready to use the new structure?** Start with the [Quick Start Guide](QUICKSTART_v3.md)!
