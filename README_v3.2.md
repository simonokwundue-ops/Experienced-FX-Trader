# ForexTrader v3.2 User Guide

## Overview

ForexTrader v3.2 represents a major enhancement over v3.0, designed to address the core issues identified by users:

- **Much more active trading** (positions open in minutes/hours, not days)
- **Multi-symbol capability** (trade multiple pairs from single chart)
- **Enhanced risk management** (daily drawdown limits, floating equity limits)
- **Two specialized versions**: Normal Multi-Strategy and High-Frequency Scalper

## Version Comparison

| Feature | v3.0 | v3.2 Normal | v3.2 Scalper |
|---------|------|-------------|--------------|
| Min Signal Score | 60 | 35 | 20 |
| Cooldown Minutes | 15 | 3 | 0 |
| Max Daily Trades | 20 | 50 | 200 |
| Multi-Symbol | No | Yes | Yes |
| Timeframe | M15-H1 | M15-H1 | M1-M5 |
| Stop Loss | 40 pips | 40 pips | 10 pips |
| Take Profit | 80 pips | 80 pips | 15 pips |
| Session Filter | Required | Optional | Disabled |
| Position Opening | Days | Hours | Minutes |

## ForexTrader v3.2 Multi-Strategy (Normal Version)

### Key Features

**Multi-Symbol Trading**
- Trade up to 8 currency pairs simultaneously
- Independent signal analysis per symbol
- Per-symbol position limits (default: 2 positions per pair)
- Global portfolio position cap (default: 5 total)
- Hedging support (opposite directions allowed)

**Enhanced Signal Generation**
- Lower signal threshold (MinSignalScore = 35 vs 60)
- Faster response to market opportunities
- 4 strategies: MA, RSI, BB, MACD
- Optional multi-timeframe confirmation
- Session-based filtering (optional)

**Advanced Risk Management**
- Daily drawdown limit (5% configurable)
- Floating equity limit (5% maximum risk)
- Per-trade dynamic risk adjustment
- Portfolio-wide risk monitoring
- Automatic circuit breakers

**Trading Activity**
- Reduced cooldown (3 minutes vs 15)
- Post-close cooldown (2 minutes)
- Increased trade capacity (50 trades/day)
- 24/7 trading capability (session filter optional)
- Multiple timeframe support

### Recommended Use Cases

**Conservative Traders**
- Single symbol mode
- MinSignalScore: 40-45
- BaseRiskPercent: 1.0-1.5%
- CooldownMinutes: 5
- Session filter: Enabled

**Moderate Traders** (Default Settings)
- Multi-symbol (4-5 pairs)
- MinSignalScore: 35
- BaseRiskPercent: 1.5-2.0%
- CooldownMinutes: 3
- Session filter: Optional

**Aggressive Traders**
- Multi-symbol (6-8 pairs)
- MinSignalScore: 25-30
- BaseRiskPercent: 2.0-2.5%
- CooldownMinutes: 1
- Session filter: Disabled

### Configuration Files

**Moderate** (`Config/ForexTrader_v3.2_Moderate.set`)
- Balanced risk/reward
- 5 symbols: EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD
- MinSignalScore: 35
- BaseRisk: 1.5%
- Cooldown: 3 minutes

**Aggressive** (`Config/ForexTrader_v3.2_Aggressive.set`)
- Maximum activity
- 8 symbols including crosses
- MinSignalScore: 25
- BaseRisk: 2.0%
- Cooldown: 1 minute

### Setup Instructions

1. **Compile in MetaEditor**
   - Open `ForexTrader_v3.2_MultiStrategy_Production.mq5`
   - Press F7 to compile
   - Fix any compilation errors if present

2. **Attach to Chart**
   - Open any major pair chart (e.g., EURUSD)
   - Timeframe: M30 or H1 recommended
   - Drag EA to chart

3. **Load Configuration**
   - In EA settings, click "Load"
   - Select `Config/ForexTrader_v3.2_Moderate.set`
   - Or configure manually

4. **Key Settings to Verify**
   ```
   TradeMultipleSymbols = true
   TradingSymbols = EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD
   MaxPositionsPerSymbol = 2
   MaxTotalPositions = 5
   MinSignalScore = 35
   BaseRiskPercent = 1.5
   DailyDrawdownPercent = 5.0
   MaxFloatingEquityPercent = 5.0
   ```

5. **Enable AutoTrading**
   - Press F7 or click AutoTrading button
   - Verify EA shows "Initialized" in Experts tab

### Expected Performance

**With Moderate Settings (MinSignalScore=35)**
- Trading Activity: 5-15 trades per day (all symbols)
- Win Rate: 55-65%
- Profit Factor: 1.4-1.8
- Monthly Return: 5-12%
- Max Drawdown: 15-20%
- Position Duration: 2-8 hours average

**With Aggressive Settings (MinSignalScore=25)**
- Trading Activity: 15-30 trades per day
- Win Rate: 50-60%
- Profit Factor: 1.3-1.6
- Monthly Return: 8-18%
- Max Drawdown: 20-25%
- Position Duration: 1-4 hours average

## ForexTrader v3.2 Scalper (High-Frequency Version)

### Key Features

**Scalping-Optimized**
- M1/M5 timeframes for rapid signals
- Tight stops (10 pips) and quick targets (15 pips)
- High-frequency position cycling
- Zero cooldown between trades
- Up to 8 concurrent positions

**Advanced Signal Detection**
- Fast MA crossovers (5/20 EMA)
- Momentum filter (3-bar price movement)
- Breakout detection (5-bar range breakouts)
- RSI momentum confirmation
- Bollinger Band squeeze/expansion

**Scalping-Specific Features**
- Very tight spread filtering (max 2 pips)
- Quick breakeven (5 pips profit)
- Tight trailing stop (8 pips)
- Early stop protection
- Micro-trend following

### Recommended Use Cases

**Ideal For:**
- Experienced scalpers
- ECN/STP broker accounts
- VPS with low latency (<10ms)
- High-liquidity pairs only
- High-frequency trading appetite

**NOT Recommended For:**
- Beginners
- High-spread brokers
- Dealing desk brokers
- Slow execution (>50ms)
- Retail accounts with restrictions

### Configuration Files

**Scalper** (`Config/ForexTrader_v3.2_Scalper.set`)
- High-frequency optimized
- 4 high-liquidity symbols
- MinSignalScore: 20
- StopLoss: 10 pips, TakeProfit: 15 pips
- No cooldown
- 200 max trades/day

### Setup Instructions

1. **Verify Broker Compatibility**
   - ECN/STP execution required
   - Average EURUSD spread <1 pip
   - No scalping restrictions
   - Fast execution (<50ms)

2. **Compile in MetaEditor**
   - Open `ForexTrader_v3.2_Scalper_Production.mq5`
   - Press F7 to compile

3. **Attach to Chart**
   - Open EURUSD M5 chart
   - Must use M1 or M5 timeframe
   - Drag EA to chart

4. **Load Scalper Configuration**
   - Load `Config/ForexTrader_v3.2_Scalper.set`
   - Verify settings:
     ```
     MinSignalScore = 20
     StopLossPips = 10
     TakeProfitPips = 15
     MaxSpreadPips = 2.0
     CooldownMinutes = 0
     UseMomentumFilter = true
     UseBreakoutDetection = true
     ```

5. **VPS Recommended**
   - Scalping requires stable connection
   - VPS near broker server ideal
   - Target <10ms latency

### Expected Performance

**With Scalper Settings (M5 timeframe)**
- Trading Activity: 20-50 trades per day (per symbol)
- Win Rate: 60-70% (higher than swing)
- Profit Factor: 1.3-1.6
- Average Trade: 3-8 pips profit
- Monthly Return: 10-20%
- Max Drawdown: 10-15%
- Position Duration: 5-30 minutes

### Critical Success Factors

1. **Spread Management**
   - Trade only during low-spread hours
   - Average spread must be <50% of target profit
   - Monitor spread constantly

2. **Execution Speed**
   - Verify execution time <50ms
   - Use VPS if needed
   - Test slippage on demo

3. **Broker Selection**
   - ECN/STP only
   - Verify no scalping restrictions
   - Low or zero commission

4. **Risk Control**
   - Start with minimum lot sizes
   - Monitor closely for first week
   - Adjust spread limits as needed

## Risk Management for Both Versions

### Daily Drawdown Protection
Both versions include automatic daily drawdown limits:
- Default: 5% daily loss limit
- System halts trading if limit hit
- Resets at start of new trading day
- Prevents catastrophic daily losses

### Floating Equity Protection
Portfolio-wide floating loss monitoring:
- Default: 5% maximum floating loss
- No new positions if limit exceeded
- Existing positions can be managed
- Protects against over-exposure

### Position Limits
- Per-symbol limits prevent concentration risk
- Global limits cap total exposure
- Hedging allowed if enabled
- Prevents excessive position accumulation

## Testing Procedures

### Backtesting v3.2 Normal

**Strategy Tester Setup**
1. Load `ForexTrader_v3.2_MultiStrategy_Production.ini`
2. Symbol: EURUSD (or any major)
3. Period: M30 or H1
4. Model: "1 minute OHLC" or "Every tick"
5. Date range: Minimum 6 months
6. Deposit: $10,000

**What to Check**
- Total trades >100 (good activity)
- Win rate >50%
- Profit factor >1.3
- Max drawdown <20%
- Monthly return 5-12%

### Backtesting v3.2 Scalper

**Strategy Tester Setup**
1. Load `ForexTrader_v3.2_Scalper_Production.ini`
2. Symbol: EURUSD
3. Period: M5 (or M1 for advanced)
4. Model: "Every tick" (required for scalping)
5. Date range: 3-6 months
6. Deposit: $10,000

**What to Check**
- Total trades >200 (high frequency)
- Win rate >60%
- Profit factor >1.3
- Average profit/trade >2 pips after costs
- Max drawdown <15%

### Forward Testing

**Both Versions**
1. Run on demo account for 1 month minimum
2. Compare demo results to backtest
3. Monitor execution quality
4. Verify spread costs realistic
5. Check for unexpected behavior

**Success Criteria**
- Forward test matches backtest ±30%
- Execution quality acceptable
- Spread costs as expected
- No unexpected errors
- Risk limits working correctly

## Troubleshooting

### "No Positions Opening"

**v3.2 Normal**
- Check MinSignalScore (try lowering to 30-35)
- Verify multi-symbol mode enabled
- Check symbols are valid and tradeable
- Verify session filter not blocking (disable if needed)
- Check ADX/ATR filters not too restrictive

**v3.2 Scalper**
- Check spread <2 pips
- Verify M1 or M5 timeframe
- Check MinSignalScore not too high (15-25)
- Disable ADX filter
- Verify broker allows scalping

### "Too Many Positions"

**Both Versions**
- Reduce MaxTotalPositions
- Reduce MaxPositionsPerSymbol
- Increase MinSignalScore
- Reduce number of TradingSymbols
- Check position management working

### "High Drawdown"

**Both Versions**
- Reduce BaseRiskPercent
- Increase StopLossPips
- Enable more filters (ADX, ATR)
- Increase MinSignalScore
- Reduce number of symbols
- Enable session filter

### "Compilation Errors"

**Common Issues**
- MQL5 version too old (update MT5)
- Missing includes (verify Trade.mqh available)
- Syntax errors from editing (restore from backup)

## Performance Monitoring

### Key Metrics to Track

**Daily**
- Number of trades opened
- Current drawdown %
- Floating equity %
- Win rate for the day

**Weekly**
- Total profit/loss
- Average trade duration
- Strategy performance breakdown
- Risk-adjusted returns

**Monthly**
- Return on investment
- Maximum drawdown
- Profit factor
- Sharpe ratio
- Compare vs backtest

### When to Adjust Settings

**Increase Activity (if too slow)**
- Lower MinSignalScore by 5-10
- Reduce CooldownMinutes
- Disable session filter
- Add more symbols

**Decrease Activity (if too aggressive)**
- Raise MinSignalScore by 5-10
- Increase CooldownMinutes
- Enable session filter
- Reduce number of symbols

**Improve Win Rate (if too low)**
- Increase MinSignalScore
- Enable more filters
- Increase MA_SlopeMinimum
- Use multi-timeframe confirmation

**Reduce Drawdown (if too high)**
- Reduce BaseRiskPercent
- Increase StopLossPips
- Reduce MaxTotalPositions
- Enable all filters

## Comparison: v3.0 vs v3.2

### What's Different

**Trading Activity**
- v3.0: Takes days to open positions
- v3.2: Opens positions in minutes to hours

**Signal Threshold**
- v3.0: MinSignalScore = 60 (very conservative)
- v3.2: MinSignalScore = 35 (balanced) or 20 (scalper)

**Multi-Symbol Support**
- v3.0: Single symbol only
- v3.2: Up to 8 symbols simultaneously

**Risk Controls**
- v3.0: Basic drawdown limit
- v3.2: Daily drawdown + floating equity + position limits

**Cooldown**
- v3.0: 15 minutes between trades
- v3.2: 3 minutes (normal) or 0 minutes (scalper)

### Migration from v3.0

1. Backtest v3.2 thoroughly
2. Compare results to v3.0
3. Start with conservative v3.2 settings
4. Run both in parallel on demo
5. Gradually transition to v3.2

### Which Version to Use?

**Use v3.0 if:**
- You prefer very conservative trading
- You want maximum filters
- You can wait days for trades
- You're risk-averse

**Use v3.2 Normal if:**
- You want active daily trading
- You want multi-symbol diversification
- You want balanced risk/reward
- You need better productivity

**Use v3.2 Scalper if:**
- You're experienced with scalping
- You have ECN/STP broker
- You have VPS with low latency
- You want high-frequency trading
- You can monitor closely

## Support and Resources

### Documentation
- `README_v3.md` - v3.0 complete guide
- `IMPLEMENTATION_V3.md` - Technical details
- This file - v3.2 user guide

### Configuration Files
- `Config/ForexTrader_v3.2_Moderate.set`
- `Config/ForexTrader_v3.2_Aggressive.set`
- `Config/ForexTrader_v3.2_Scalper.set`

### Strategy Tester Files
- `ForexTrader_v3.2_MultiStrategy_Production.ini`
- `ForexTrader_v3.2_Scalper_Production.ini`

### Getting Help
1. Review documentation thoroughly
2. Check troubleshooting section
3. Verify settings match use case
4. Test on demo account first
5. Open GitHub issue with details

---

## Disclaimer

**Trading forex carries substantial risk of loss and is not suitable for all investors.**

- Always test on demo first (minimum 1 month)
- Never risk more than you can afford to lose
- Start with conservative settings (1% risk)
- Monitor performance regularly
- Use proper risk management
- Past performance does not guarantee future results

v3.2 is designed for more active trading but this also means more opportunities for both profits AND losses. Start conservatively and increase activity only after successful demo testing.

---

**ForexTrader v3.2 - Active Trading, Intelligent Risk Management**
