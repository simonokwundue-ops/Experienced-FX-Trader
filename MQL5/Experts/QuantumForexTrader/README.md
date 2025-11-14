# Quantum Forex Trader EA

## Installation

The Quantum Forex Trader EA files have been organized in a proper MetaTrader 5 directory structure.

### Directory Structure

```
MQL5/Experts/QuantumForexTrader/
├── QuantumForexTrader_Scalper.mq5    # Main EA file (entry point)
├── core/                              # Trade engine, risk, logging
│   └── QuantumRiskManager.mqh
├── strategies/                        # Modular strategy files
│   ├── QuantumAnalysis.mqh
│   └── QuantumSignals.mqh
├── include/                           # Utilities, indicators, helpers
│   └── BinaryEncoder.mqh
├── configs/                           # Optional config/INI files
├── tester/                            # Optional .set files for tester
└── docs/                              # Complete documentation
    ├── USER_MANUAL.txt
    ├── MASTER_GUIDE.md
    ├── QUICKSTART_QUANTUM.md
    ├── TESTING_GUIDE.md
    ├── CONFIGURATION_GUIDE.md
    ├── QUANTUM_EA_README.md
    └── IMPLEMENTATION_SUMMARY.md
```

### Quick Start

1. **Copy the entire `MQL5` folder to your MetaTrader 5 data directory:**
   ```
   C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[BROKER_ID]\
   ```

2. **The EA files will be at:**
   ```
   C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[BROKER_ID]\MQL5\Experts\QuantumForexTrader\
   ```

3. **Compile the EA:**
   - Open MetaEditor (F4)
   - Navigate to Experts → QuantumForexTrader
   - Open `QuantumForexTrader_Scalper.mq5`
   - Press F7 to compile
   - Expected: 0 errors, 0 warnings

4. **Read the documentation:**
   - Start with: `MQL5/Experts/QuantumForexTrader/docs/MASTER_GUIDE.md`
   - Quick setup: `MQL5/Experts/QuantumForexTrader/docs/QUICKSTART_QUANTUM.md`
   - Complete reference: `MQL5/Experts/QuantumForexTrader/docs/USER_MANUAL.txt`

### Documentation

All documentation files are located in:
```
MQL5/Experts/QuantumForexTrader/docs/
```

**Available guides:**
- **MASTER_GUIDE.md** - Navigation hub for all documentation
- **QUICKSTART_QUANTUM.md** - 5-minute setup guide
- **USER_MANUAL.txt** - Complete user manual (27 KB)
- **TESTING_GUIDE.md** - 8-phase testing methodology
- **CONFIGURATION_GUIDE.md** - Complete parameter reference
- **QUANTUM_EA_README.md** - Technical overview
- **IMPLEMENTATION_SUMMARY.md** - Implementation details

### Support

For installation help, troubleshooting, and configuration guidance, see the documentation files in the `docs/` directory.

---

**Version**: 1.0  
**Platform**: MetaTrader 5  
**Language**: MQL5  
**Status**: Production-ready (after demo testing)
