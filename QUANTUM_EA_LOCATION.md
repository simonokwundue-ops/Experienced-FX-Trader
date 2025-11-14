# Quantum Forex Trader EA

The Quantum Forex Trader EA has been organized into a proper MetaTrader 5 directory structure.

## Location

All Quantum EA files are now located in:
```
MQL5/Experts/QuantumForexTrader/
```

## Quick Links

- **Installation Guide**: [MQL5/Experts/QuantumForexTrader/README.md](MQL5/Experts/QuantumForexTrader/README.md)
- **Quick Start**: [MQL5/Experts/QuantumForexTrader/docs/QUICKSTART_QUANTUM.md](MQL5/Experts/QuantumForexTrader/docs/QUICKSTART_QUANTUM.md)
- **Complete Manual**: [MQL5/Experts/QuantumForexTrader/docs/USER_MANUAL.txt](MQL5/Experts/QuantumForexTrader/docs/USER_MANUAL.txt)

## Directory Structure

```
MQL5/Experts/QuantumForexTrader/
├── QuantumForexTrader_Scalper.mq5    # Main EA file
├── README.md                          # Installation guide
├── core/                              # Risk management
│   └── QuantumRiskManager.mqh
├── strategies/                        # Analysis and signals  
│   ├── QuantumAnalysis.mqh
│   └── QuantumSignals.mqh
├── include/                           # Utilities
│   └── BinaryEncoder.mqh
├── docs/                              # Complete documentation
│   ├── USER_MANUAL.txt
│   ├── MASTER_GUIDE.md
│   ├── QUICKSTART_QUANTUM.md
│   ├── TESTING_GUIDE.md
│   ├── CONFIGURATION_GUIDE.md
│   ├── QUANTUM_EA_README.md
│   └── IMPLEMENTATION_SUMMARY.md
├── configs/                           # Config files
└── tester/                            # Strategy tester files
```

## Installation

Copy the entire `QuantumForexTrader` folder to your MT5 Experts directory:

```
C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[BROKER_ID]\MQL5\Experts\
```

See the [Installation Guide](MQL5/Experts/QuantumForexTrader/README.md) for detailed instructions.
