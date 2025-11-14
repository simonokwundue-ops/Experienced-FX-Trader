# Quantum Forex Trader - Quick Start Guide

## 5-Minute Setup for Beginners

### Step 1: Install Files (2 minutes)

1. **Find your MT5 data folder:**
   - Open MetaTrader 5
   - Click: File → Open Data Folder
   - Navigate to: MQL5 → Experts

2. **Copy these 5 files to the Experts folder:**
   - QuantumForexTrader_Scalper.mq5
   - QuantumSignals.mqh
   - QuantumAnalysis.mqh
   - QuantumRiskManager.mqh
   - BinaryEncoder.mqh

### Step 2: Compile (1 minute)

1. Press **F4** in MT5 to open MetaEditor
2. In Navigator, find **QuantumForexTrader_Scalper.mq5**
3. Double-click to open it
4. Press **F7** to compile
5. Check bottom panel: Should show "**0 error(s), 0 warning(s)**"
6. Close MetaEditor

### Step 3: Attach to Chart (2 minutes)

1. Open **EUR/USD** chart in MT5
2. Change timeframe to **H1** (1 Hour)
3. In Navigator, expand "Expert Advisors"
4. **Drag** QuantumForexTrader_Scalper onto the chart
5. In the dialog that appears:
   - **Common tab**: Check "Allow Algo Trading" ✓
   - **Inputs tab**: Leave everything default for now
   - Click **OK**

### Step 4: Verify It's Working (30 seconds)

Look for these signs:
- ☺ **Smiley face** in top-right corner of chart (good!)
- ✗ If you see an X, click the **"Algo Trading"** button in toolbar
- Check **Toolbox** → **Experts** tab for initialization messages

## Expected Log Messages

When EA starts successfully, you'll see:
```
=== Quantum Forex Trader Initializing ===
Symbol: EURUSD
Timeframe: H1
Account Balance: [your balance]
=== Configuration ===
History Bars: 256
Confidence Threshold: 3.0%
Risk Per Trade: 1.0%
=== Quantum Forex Trader Initialized Successfully ===
```

## What Happens Next?

The EA will:
1. **Wait 60 seconds** between signal checks
2. **Analyze 256 bars** of price history
3. **Generate signals** when conditions are met
4. **Open trades automatically** with SL and TP

**Time to first trade**: Could be 1 hour to 1 day depending on market conditions

## Recommended First Settings

For **demo testing** (start here!):

| Parameter | Value | Why |
|-----------|-------|-----|
| Symbol | EUR/USD | Most liquid, lowest spread |
| Timeframe | H1 | Good balance |
| Risk % | 0.5% | Very conservative |
| Max Positions | 1 | Safest start |
| Stop Loss | 50 pips | Reasonable for EUR/USD |
| Take Profit | 100 pips | 2:1 reward ratio |

## Common Issues & Quick Fixes

### Issue: EA shows ✗ instead of ☺
**Fix**: Click "Algo Trading" button in toolbar (should turn green)

### Issue: No trades after several hours
**Possible reasons**:
- Market conditions don't meet criteria (normal)
- Spread too wide (wait for better conditions)
- Outside trading hours (check time filter settings)

**Action**: Be patient! Check Experts log for "SIGNAL DETECTED" messages

### Issue: Compilation errors
**Fix**: 
1. Ensure ALL 5 files (.mq5 and .mqh) are in Experts folder
2. Check file extensions (not .txt)
3. Re-download files if corrupted

## Safety Checklist

Before going live:

- [ ] Tested on **demo** account for at least 1-2 weeks
- [ ] Understand all parameter settings
- [ ] Started with **conservative** settings (0.5-1% risk)
- [ ] Checked Experts log shows no errors
- [ ] Account balance sufficient ($500+ recommended)
- [ ] Using **major pair** (EUR/USD, GBP/USD, USD/JPY)
- [ ] Monitoring daily for first week

## Quick Reference: Parameter Presets

### Ultra Conservative (Recommended for beginners)
```
InpRiskPercent = 0.5
InpMaxPositions = 1
InpConfidenceThreshold = 0.05
InpMomentumThreshold = 0.15
```

### Conservative
```
InpRiskPercent = 1.0
InpMaxPositions = 1
InpConfidenceThreshold = 0.04
InpMomentumThreshold = 0.12
```

### Moderate
```
InpRiskPercent = 1.5
InpMaxPositions = 2
InpConfidenceThreshold = 0.03
InpMomentumThreshold = 0.10
```

### Aggressive (Not recommended for beginners!)
```
InpRiskPercent = 2.0
InpMaxPositions = 3
InpConfidenceThreshold = 0.02
InpMomentumThreshold = 0.08
```

## Monitoring Dashboard

Check these metrics daily:

| Metric | What to Look For | Action If... |
|--------|------------------|--------------|
| Balance | Increasing over time | Keep going! |
| Equity | Close to balance | Normal |
| Drawdown | < 20% | Good |
| Open Positions | Within max limit | Normal |
| Smiley Face | ☺ showing | EA active |

## Need More Help?

1. **Full instructions**: Read USER_MANUAL.txt
2. **Technical details**: Read QUANTUM_EA_README.md
3. **Troubleshooting**: See USER_MANUAL.txt section 9
4. **FAQ**: See USER_MANUAL.txt section 10

## Remember

✓ **DO:**
- Test on demo first
- Start conservative
- Monitor regularly
- Keep learning

✗ **DON'T:**
- Use on live without testing
- Risk more than 2% per trade
- Disable risk management
- Panic on first loss

## Next Steps

After 1-2 weeks of demo testing:
1. Review trade history
2. Check win rate (aim for >50%)
3. Verify drawdown stayed under limit
4. If satisfied, consider live with small account
5. Start with same conservative settings
6. Gradually adjust based on results

---

**Questions?** Read the complete USER_MANUAL.txt file!

**Ready?** Let's start trading! 🚀

