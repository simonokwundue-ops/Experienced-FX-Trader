# Quantum Forex Trader EA

## Overview

This is a quantum-inspired forex trading Expert Advisor (EA) for MetaTrader 5 that uses concepts from quantum computing to analyze market conditions and generate trading signals.

## What This EA Does

The Quantum Forex Trader EA:
- Analyzes 256 bars of historical price data
- Converts price movements into binary sequences (1=up, 0=down)
- Generates probability distributions of market states
- Identifies dominant market trends (BULL/BEAR/NEUTRAL)
- Calculates confidence and momentum for each signal
- Automatically opens and manages positions
- Implements comprehensive risk management

## Files Included

1. **QuantumForexTrader_Scalper.mq5** - Main EA file
2. **QuantumSignals.mqh** - Signal generation library
3. **QuantumAnalysis.mqh** - Quantum analysis engine
4. **QuantumRiskManager.mqh** - Risk management library
5. **BinaryEncoder.mqh** - Binary encoding utilities
6. **USER_MANUAL.txt** - Complete user manual

## Installation

### Quick Start

1. **Copy all files to your MT5 Experts folder:**
   ```
   C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[BROKER_ID]\MQL5\Experts\
   ```

2. **Open MetaEditor (F4 in MT5)**

3. **Compile the EA:**
   - Open `QuantumForexTrader_Scalper.mq5`
   - Click Compile (F7)
   - Verify: "0 error(s), 0 warning(s)"

4. **Attach to chart:**
   - Drag EA from Navigator to any chart
   - Configure parameters
   - Ensure "Allow Algo Trading" is enabled
   - Click OK

## Default Configuration

### For Beginners (Conservative)
- Symbol: EUR/USD
- Timeframe: H1 (1 Hour)
- Risk Per Trade: 0.5-1.0%
- Max Positions: 1
- Stop Loss: 50 pips
- Take Profit: 100 pips

### For Experienced Traders (Moderate)
- Symbol: Any major pair
- Timeframe: H1 or H4
- Risk Per Trade: 1.0-2.0%
- Max Positions: 2-3
- Stop Loss: 50 pips
- Take Profit: 100 pips

## Key Parameters

### Quantum Analysis
- **InpHistoryBars**: Number of bars to analyze (default: 256)
- **InpConfidenceThreshold**: Minimum confidence for signals (default: 0.03)
- **InpMomentumThreshold**: Minimum momentum required (default: 0.1)

### Risk Management
- **InpRiskPercent**: Risk per trade % (default: 1.0%)
- **InpMaxDrawdown**: Maximum drawdown % (default: 20%)
- **InpMaxPositions**: Maximum concurrent positions (default: 3)

### Trade Parameters
- **InpStopLossPips**: Stop loss distance (default: 50 pips)
- **InpTakeProfitPips**: Take profit distance (default: 100 pips)

## How It Works

### 1. Data Collection
- Collects 256 bars of price data (optimized for quantum-inspired analysis)

### 2. Binary Encoding
- Converts price movements to binary: 1 = price up, 0 = price down
- Creates pattern signature of market behavior

### 3. Quantum Analysis
- Generates pseudo-quantum states representing possible market outcomes
- Calculates probability distribution
- Identifies most probable scenarios

### 4. Signal Generation
- **BUY Signal**: Bullish probability dominant + confidence met + momentum met
- **SELL Signal**: Bearish probability dominant + confidence met + momentum met

### 5. Trade Execution
- Calculates position size based on risk settings
- Opens position with automatic SL/TP
- Monitors drawdown and position limits

## Recommended Settings

### Best Currency Pairs
1. EUR/USD (most tested, lowest spread)
2. GBP/USD (good volatility)
3. USD/JPY (stable, liquid)
4. AUD/USD, USD/CAD, NZD/USD

### Best Timeframes
- **H1 (1 Hour)**: Best balance of data and responsiveness
- **H4 (4 Hours)**: Longer-term trends, fewer signals
- **M30 (30 Min)**: More signals, requires more monitoring

### Avoid
- M1, M5 timeframes (too noisy)
- Exotic pairs (spread too wide)
- Trading during major news events

## Risk Warning

⚠️ **IMPORTANT**: 
- Always test on DEMO account first
- Never risk more than you can afford to lose
- Past performance does not guarantee future results
- Start with conservative settings
- Monitor regularly during first week

## Troubleshooting

### EA doesn't compile
- Ensure all .mqh files are in same folder
- Check file extensions (.mq5 not .mq5.txt)
- Try recompiling after restarting MetaEditor

### EA shows ✗ on chart
- Enable "Algo Trading" button (should be green)
- Check EA properties: "Allow Algo Trading" is checked
- Verify in Tools -> Options -> Expert Advisors

### EA doesn't trade
- Check market conditions (spread, trading hours)
- Verify time filter settings
- Check Experts log for signal attempts
- Ensure risk limits not exceeded

## Performance Monitoring

### What to Check Daily
1. Open positions and their status
2. Account balance and equity
3. Current drawdown percentage
4. Experts log for errors or warnings
5. EA is still active (smiley face on chart)

### What to Check Weekly
1. Win rate of closed trades
2. Average profit vs average loss
3. Maximum drawdown experienced
4. Number of signals vs trades taken
5. Adjust parameters if needed

## Support

For detailed instructions, see **USER_MANUAL.txt** which includes:
- Complete installation guide
- Parameter explanations
- Startup procedures with screenshots
- Troubleshooting guide
- FAQ section
- Quick reference card

## Technical Details

### Quantum-Inspired Approach
The EA doesn't use actual quantum computers but implements quantum-inspired algorithms:
- **Superposition concept**: Analyzes multiple market scenarios simultaneously
- **Probability amplitudes**: Each scenario has associated probability
- **Measurement**: Selects most probable outcome for trading decision

### Based on Research
Inspired by quantum phase estimation (QPE) algorithms and the work on quantum computing applications in financial markets, as detailed in the IBM Quantum documentation.

## License

Open Source - Use at your own risk

## Disclaimer

This EA is provided for educational purposes. Trading forex carries substantial risk. No guarantees of profit are made. Always test thoroughly on demo accounts before live trading.

---

**Version**: 1.0  
**Compatibility**: MetaTrader 5 Build 3960+  
**Language**: MQL5  
**Category**: Trading Systems

