===========================================
QuantumForexTrader EA
===========================================

Quantum-Enhanced Multi-Strategy Expert Advisor for MetaTrader 5

VERSION: 1.0
TARGET WIN RATE: 60-70%
BASED ON: IBM Quantum Phase Estimation Theory

===========================================
QUICK START
===========================================

1. Copy entire FOREX_TRADER folder to: MT5/MQL5/Experts/
2. Restart MT5 or refresh Navigator (F4)
3. Drag QuantumForexTrader_Base.mq5 onto M15/M30/H1 chart
4. Load Config/QuantumForexTrader_Base.set
5. Enable AutoTrading (F7)
6. Start with DEMO account!

===========================================
WHAT'S INCLUDED
===========================================

EA Files:
- QuantumForexTrader_Base.mq5 (1398 lines) - Main EA
- QuantumForexTrader_Scalper.mq5 (612 lines) - Scalper variant

Include Files:
- QuantumSignals.mqh - Signal generation
- QuantumAnalysis.mqh - Market state analysis
- BinaryEncoder.mqh - Price encoding
- QuantumRiskManager.mqh - Risk management
- PythonBridge.mqh - Optional Python integration

Configuration:
- Base.set/.ini - Default settings
- Scalper.set/.ini - Scalping settings

Python Scripts (Optional):
- quantum_analysis.py - Quantum calculations
- quantum_visual.py - Visualization
- run_quantum_python.bat - Auto-runner

Documentation:
- USAGE_INSTRUCTIONS.txt - Complete guide
- INSTALLATION.txt - Step-by-step setup
- CONFIGURATION.txt - Parameter reference
- QUANTUM_THEORY.txt - IBM Quantum article

===========================================
KEY FEATURES
===========================================

Quantum Analysis:
✓ 256-candle quantum lookback (2^8 optimal)
✓ 10-candle prediction horizon
✓ Quantum Phase Estimation (QPE) simulation
✓ Binary price encoding for quantum states
✓ Probability distribution analysis
✓ Quantum entropy measurement
✓ Multi-timeframe quantum confirmation

Trading Strategies:
✓ Moving Average crossover
✓ RSI reversal
✓ Bollinger Bands bounce
✓ MACD momentum
✓ Quantum-weighted signal combination

Risk Management:
✓ Quantum-adjusted position sizing
✓ Adaptive SL/TP based on entropy
✓ Portfolio risk limits
✓ Breakeven + trailing stop
✓ Partial take profit
✓ Max drawdown protection

===========================================
FOLDER STRUCTURE
===========================================

FOREX_TRADER/
├── QuantumForexTrader_Base.mq5
├── QuantumForexTrader_Scalper.mq5
├── run_quantum_python.bat
├── PYTHON_COMMANDS.txt
├── README.txt (this file)
├── Include/
│   ├── QuantumSignals.mqh
│   ├── QuantumAnalysis.mqh
│   ├── BinaryEncoder.mqh
│   ├── QuantumRiskManager.mqh
│   └── PythonBridge.mqh
├── Config/
│   ├── QuantumForexTrader_Base.set
│   ├── QuantumForexTrader_Scalper.set
│   ├── QuantumForexTrader_Base.ini
│   └── QuantumForexTrader_Scalper.ini
├── Python/
│   ├── quantum_analysis.py
│   └── quantum_visual.py
└── Docs/
    ├── USAGE_INSTRUCTIONS.txt
    ├── INSTALLATION.txt
    ├── CONFIGURATION.txt
    └── QUANTUM_THEORY.txt

===========================================
RECOMMENDED USAGE
===========================================

Base EA:
- Timeframes: M15, M30, H1
- Pairs: EURUSD, GBPUSD, USDJPY
- Risk: 1.5% per trade
- Max Positions: 3-5
- Best for: Swing/trend trading

Scalper:
- Timeframes: M1, M5
- Pairs: Major pairs with low spread
- Risk: 0.5% per scalp
- Max Scalps: 50 per day
- Best for: Fast scalping

===========================================
IMPORTANT NOTES
===========================================

✓ ALWAYS test on DEMO first (2-4 weeks minimum)
✓ Python integration is OPTIONAL (EA works standalone)
✓ Start with conservative settings
✓ Monitor quantum confidence levels
✓ Target: 60-70% win rate
✓ Adjust QuantumConfidenceThreshold for optimization
✓ Use appropriate timeframe for each variant
✓ Ensure low spread for scalping
✓ Enable AutoTrading in MT5

===========================================
SUPPORT & DOCUMENTATION
===========================================

Complete instructions: Docs/USAGE_INSTRUCTIONS.txt
Installation guide: Docs/INSTALLATION.txt
Parameter tuning: Docs/CONFIGURATION.txt
Theory explained: Docs/QUANTUM_THEORY.txt

GitHub Repository:
https://github.com/simonokwundue-ops/Experienced-FX-Trader

IBM Quantum Article:
https://www.mql5.com/en/articles/17171

===========================================
DISCLAIMER
===========================================

Trading forex carries substantial risk. Test thoroughly
on demo accounts. Never risk more than you can afford
to lose. Past performance does not guarantee future
results. Use appropriate risk management.

===========================================
LICENSE
===========================================

MIT License
Copyright (c) 2024

Based on IBM Quantum Phase Estimation concepts
Implements quantum-inspired algorithms in MQL5
Production-ready and fully standalone

===========================================
