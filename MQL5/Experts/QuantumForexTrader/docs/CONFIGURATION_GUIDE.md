# Quantum Forex Trader - Configuration Reference

## Complete Parameter Guide

This document provides detailed explanations of all EA parameters with recommended values for different trading styles.

---

## Quantum Analysis Parameters

### InpHistoryBars
**Type**: Integer  
**Default**: 256  
**Range**: 128, 256, 512, 1024 (powers of 2)  
**Description**: Number of historical bars analyzed for quantum state generation

**How it works**:
- EA collects this many bars of price history
- Converts them to binary sequence (1=up, 0=down)
- Uses for probability distribution generation
- More bars = more historical context
- Must be power of 2 for optimal algorithm performance

**Recommendations**:
| Trading Style | Value | Reasoning |
|---------------|-------|-----------|
| Scalper | 128 | Quick response, recent data focused |
| Day Trader | 256 | **Best balance** - default |
| Swing Trader | 512 | More context, longer trends |
| Position Trader | 1024 | Maximum context, very stable signals |

**Warning**: Higher values = slower computation. 256 is optimal for most use cases.

---

### InpConfidenceThreshold
**Type**: Double  
**Default**: 0.03 (3%)  
**Range**: 0.01 to 0.10  
**Description**: Minimum confidence level required to generate trading signal

**How it works**:
- Quantum analysis produces probability distribution
- Highest probability state determines confidence
- Signal only generated if confidence >= threshold
- Higher threshold = more selective, fewer signals
- Lower threshold = more signals, potentially lower quality

**Recommendations**:
| Risk Profile | Value | Expected Signals | Quality |
|--------------|-------|------------------|---------|
| Ultra Conservative | 0.07 | Very few | Very high |
| Conservative | 0.05 | Few | High |
| Moderate | 0.03 | **Moderate** | Good |
| Aggressive | 0.02 | Many | Mixed |
| Very Aggressive | 0.01 | Very many | Lower |

**Tuning Tips**:
- Start at 0.05 for conservative approach
- Lower gradually if too few signals
- Raise if too many false signals
- Monitor win rate after changes

---

### InpMomentumThreshold
**Type**: Double  
**Default**: 0.1  
**Range**: 0.05 to 0.30  
**Description**: Minimum momentum strength required for signal

**How it works**:
- Measures trend strength from quantum analysis
- Calculated as difference between bullish/bearish probability
- Acts as trend filter
- Higher threshold = only strong trends
- Lower threshold = catches weaker moves

**Recommendations**:
| Market Condition | Value | Usage |
|------------------|-------|-------|
| Ranging/Choppy | 0.20 | Only very strong trends |
| Normal | 0.10 | **Default** - balanced |
| Trending | 0.08 | Catch more moves |
| Volatile Trending | 0.05 | Maximum sensitivity |

**Combining with Confidence**:
```
High Conf + High Mom = Ultra selective (best quality)
High Conf + Low Mom = Quality signals, more frequent
Low Conf + High Mom = Risky but catches moves
Low Conf + Low Mom = Not recommended (too many signals)
```

---

## Risk Management Parameters

### InpRiskPercent
**Type**: Double  
**Default**: 1.0 (1%)  
**Range**: 0.5 to 5.0  
**Description**: Percentage of account balance to risk per trade

**How it works**:
- EA calculates lot size based on this percentage
- Formula: Lot Size = (Balance × Risk%) / (SL pips × Pip Value)
- Directly affects position sizing
- Critical for account protection

**Recommendations by Account Size**:
| Account Size | Conservative | Moderate | Aggressive | Max |
|--------------|--------------|----------|------------|-----|
| $500-$1,000 | 0.5% | 1.0% | 1.5% | 2.0% |
| $1,000-$5,000 | 1.0% | 1.5% | 2.0% | 2.5% |
| $5,000-$20,000 | 1.0% | 2.0% | 2.5% | 3.0% |
| $20,000+ | 1.5% | 2.0% | 3.0% | 5.0% |

**Examples** (EUR/USD, 50 pip SL, $10 pip value):
- Balance $10,000, Risk 1% = $100 risk = 0.20 lot
- Balance $10,000, Risk 2% = $200 risk = 0.40 lot
- Balance $5,000, Risk 1% = $50 risk = 0.10 lot

**IMPORTANT**: Never risk more than 5% per trade!

---

### InpMaxDrawdown
**Type**: Double  
**Default**: 20.0 (20%)  
**Range**: 10.0 to 50.0  
**Description**: Maximum drawdown percentage before EA stops trading

**How it works**:
- Monitors: Drawdown = (Balance - Equity) / Balance × 100
- If drawdown >= threshold, EA stops opening new positions
- Protects account from excessive losses
- Existing positions not closed automatically

**Recommendations**:
| Account Type | Value | Risk Level |
|--------------|-------|------------|
| Small Account (<$1,000) | 15% | Very protective |
| Standard Account | 20% | **Balanced** |
| Large Account (>$10,000) | 25% | More flexibility |
| Aggressive Trading | 30% | Higher risk tolerance |

**Example**:
- Balance: $10,000
- Open positions losing $1,500
- Equity: $8,500
- Drawdown: (10000-8500)/10000 = 15%
- If threshold is 20%, EA continues
- If threshold is 10%, EA stops

**Note**: Set this based on your risk tolerance and account recovery ability.

---

### InpMaxPositions
**Type**: Integer  
**Default**: 3  
**Range**: 1 to 10  
**Description**: Maximum number of concurrent positions

**How it works**:
- EA counts open positions before opening new ones
- If count >= threshold, no new positions opened
- Prevents overexposure to market
- Applies across all positions (not per direction)

**Recommendations**:
| Trading Style | Value | Risk | Capital Required |
|---------------|-------|------|------------------|
| Ultra Safe | 1 | Lowest | $500+ |
| Conservative | 2 | Low | $1,000+ |
| Moderate | 3 | **Medium** | $2,000+ |
| Aggressive | 5 | High | $5,000+ |
| Very Aggressive | 7+ | Very High | $10,000+ |

**Calculation**:
Minimum balance = MaxPositions × RiskAmount × 10
Example: 3 positions × $100 risk × 10 = $3,000 minimum

**Warning**: More positions = more risk exposure. Ensure adequate capital.

---

## Trade Parameters

### InpStopLossPips
**Type**: Double  
**Default**: 50.0  
**Range**: 20.0 to 200.0  
**Description**: Distance of stop loss from entry in pips

**How it works**:
- EA automatically sets SL when opening position
- For Buy: SL = Entry - (StopLossPips × PipSize)
- For Sell: SL = Entry + (StopLossPips × PipSize)
- Protects against large losses

**Recommendations by Pair**:
| Currency Pair | Tight | Normal | Wide |
|---------------|-------|--------|------|
| EUR/USD | 30 | 50 | 70 |
| GBP/USD | 40 | 60 | 80 |
| USD/JPY | 40 | 60 | 80 |
| AUD/USD | 35 | 55 | 75 |
| USD/CAD | 35 | 55 | 75 |
| EUR/JPY | 50 | 70 | 100 |

**Recommendations by Timeframe**:
| Timeframe | Value | Reasoning |
|-----------|-------|-----------|
| M30 | 30-40 | Tighter for shorter-term |
| H1 | 40-50 | **Default range** |
| H4 | 60-80 | Wider for longer-term |
| D1 | 100+ | Very wide for daily |

**ATR-Based Adjustment**:
- Check Average True Range (ATR) indicator
- Typical: SL = 1.5 × ATR
- Conservative: SL = 2.0 × ATR
- Aggressive: SL = 1.0 × ATR

---

### InpTakeProfitPips
**Type**: Double  
**Default**: 100.0  
**Range**: 40.0 to 500.0  
**Description**: Distance of take profit from entry in pips

**How it works**:
- EA automatically sets TP when opening position
- For Buy: TP = Entry + (TakeProfitPips × PipSize)
- For Sell: TP = Entry - (TakeProfitPips × PipSize)
- Locks in profit when reached

**Recommendations**:
| Risk-Reward Ratio | TP (if SL=50) | Quality |
|-------------------|---------------|---------|
| 1:1 | 50 | Not recommended |
| 1:1.5 | 75 | Minimum |
| 1:2 | 100 | **Good** |
| 1:2.5 | 125 | Better |
| 1:3 | 150 | Best |

**By Trading Style**:
| Style | SL | TP | Ratio |
|-------|----|----|-------|
| Scalper | 30 | 60 | 1:2 |
| Day Trader | 50 | 100 | 1:2 |
| Swing Trader | 70 | 210 | 1:3 |
| Position Trader | 100 | 300 | 1:3 |

**Calculation Tips**:
- Conservative: TP = SL × 2
- Balanced: TP = SL × 2.5
- Aggressive: TP = SL × 3

---

### InpMagicNumber
**Type**: Integer  
**Default**: 777777  
**Range**: 100000 to 999999  
**Description**: Unique identifier for EA's trades

**How it works**:
- Each trade opened by EA tagged with this number
- Allows EA to identify its own trades
- Prevents interference with manual trades or other EAs
- Each EA instance should have unique magic number

**Recommendations**:
| Scenario | Magic Number | Example |
|----------|--------------|---------|
| Single EA | 777777 | Default |
| Multiple EAs | Different per EA | EA1=777777, EA2=888888 |
| Multiple Symbols | Different per symbol | EUR=111111, GBP=222222 |
| Testing vs Live | Different per environment | Demo=777777, Live=999999 |

**Best Practices**:
- Use 6-digit numbers for clarity
- Document which EA uses which number
- Don't change after going live (tracking issues)

---

## Trading Schedule Parameters

### InpUseTimeFilter
**Type**: Boolean  
**Default**: true  
**Range**: true/false  
**Description**: Enable/disable time-based trading restrictions

**How it works**:
- When true: EA only trades during specified hours
- When false: EA trades 24/7
- Useful for avoiding low-liquidity periods or news events
- Based on broker's server time

**Recommendations**:
| Scenario | Setting | Reason |
|----------|---------|--------|
| Beginner | true | More control |
| Experienced | false | Maximum opportunities |
| News Avoider | true | Skip volatile periods |
| All Sessions | false | Catch all moves |

---

### InpStartHour & InpEndHour
**Type**: Integer  
**Default**: Start=0, End=23  
**Range**: 0 to 23  
**Description**: Trading hours (24-hour format)

**How it works**:
- EA checks current hour before opening positions
- Only trades if: StartHour <= CurrentHour < EndHour
- Based on broker's server time (usually GMT+2 or GMT+3)
- Applies only when InpUseTimeFilter = true

**Trading Session Times** (GMT):
| Session | GMT Time | Pairs |
|---------|----------|-------|
| Asian | 23:00-08:00 | JPY, AUD, NZD |
| European | 07:00-16:00 | EUR, GBP, CHF |
| US | 13:00-22:00 | USD, CAD |
| Overlap (Euro-US) | 13:00-16:00 | Best liquidity |

**Recommended Settings**:
| Strategy | Start | End | Target Session |
|----------|-------|-----|----------------|
| European Focus | 8 | 16 | European only |
| US Focus | 14 | 22 | US only |
| Best Liquidity | 14 | 16 | Euro-US overlap |
| Avoid Asian | 8 | 23 | Skip quiet hours |
| 24/7 Trading | 0 | 23 | All sessions |

**Tips**:
- Check your broker's server time zone
- Adjust for DST (Daylight Saving Time) changes
- Consider major news release times
- Test different sessions to find best performance

---

## Signal Generation Parameters

### InpSignalInterval
**Type**: Integer  
**Default**: 60  
**Range**: 30 to 300  
**Description**: Seconds between signal generation checks

**How it works**:
- EA waits this many seconds between signal checks
- Prevents excessive computation
- Balance between responsiveness and efficiency
- Shorter = more CPU usage

**Recommendations**:
| Timeframe | Interval (sec) | Checks per Hour |
|-----------|----------------|-----------------|
| M30 | 30 | 120 |
| H1 | 60 | 60 |
| H4 | 120 | 30 |
| D1 | 300 | 12 |

**By CPU/VPS Performance**:
| System | Setting | Reason |
|--------|---------|--------|
| Low-end VPS | 120-180 | Reduce load |
| Standard VPS | 60 | **Balanced** |
| High-end VPS | 30 | Maximum responsiveness |
| Local PC | 60-90 | Moderate use |

**Impact on Performance**:
- Lower interval = catch signals faster, more CPU
- Higher interval = miss some signals, less CPU
- 60 seconds is optimal for most scenarios

---

## Configuration Presets

### Preset 1: Ultra Conservative (Beginners)
```
InpHistoryBars = 256
InpConfidenceThreshold = 0.07
InpMomentumThreshold = 0.15
InpRiskPercent = 0.5
InpMaxDrawdown = 15.0
InpMaxPositions = 1
InpStopLossPips = 50.0
InpTakeProfitPips = 150.0
InpUseTimeFilter = true
InpStartHour = 8
InpEndHour = 16
InpSignalInterval = 90
```
**Target**: Maximum safety, minimal risk, very selective trading

---

### Preset 2: Conservative (Recommended Start)
```
InpHistoryBars = 256
InpConfidenceThreshold = 0.05
InpMomentumThreshold = 0.12
InpRiskPercent = 1.0
InpMaxDrawdown = 20.0
InpMaxPositions = 1
InpStopLossPips = 50.0
InpTakeProfitPips = 100.0
InpUseTimeFilter = true
InpStartHour = 7
InpEndHour = 22
InpSignalInterval = 60
```
**Target**: Safe trading with reasonable opportunity

---

### Preset 3: Moderate (Default)
```
InpHistoryBars = 256
InpConfidenceThreshold = 0.03
InpMomentumThreshold = 0.10
InpRiskPercent = 1.0
InpMaxDrawdown = 20.0
InpMaxPositions = 3
InpStopLossPips = 50.0
InpTakeProfitPips = 100.0
InpUseTimeFilter = false
InpSignalInterval = 60
```
**Target**: Balanced approach, good opportunity/risk ratio

---

### Preset 4: Aggressive (Experienced Only)
```
InpHistoryBars = 256
InpConfidenceThreshold = 0.02
InpMomentumThreshold = 0.08
InpRiskPercent = 2.0
InpMaxDrawdown = 25.0
InpMaxPositions = 5
InpStopLossPips = 40.0
InpTakeProfitPips = 120.0
InpUseTimeFilter = false
InpSignalInterval = 45
```
**Target**: Maximum signals, higher risk, requires monitoring

---

### Preset 5: Scalper (M30-H1)
```
InpHistoryBars = 128
InpConfidenceThreshold = 0.03
InpMomentumThreshold = 0.10
InpRiskPercent = 1.0
InpMaxDrawdown = 20.0
InpMaxPositions = 2
InpStopLossPips = 30.0
InpTakeProfitPips = 60.0
InpUseTimeFilter = true
InpStartHour = 8
InpEndHour = 22
InpSignalInterval = 30
```
**Target**: Quick trades, tighter SL/TP, higher frequency

---

### Preset 6: Swing Trader (H4-D1)
```
InpHistoryBars = 512
InpConfidenceThreshold = 0.04
InpMomentumThreshold = 0.12
InpRiskPercent = 1.5
InpMaxDrawdown = 25.0
InpMaxPositions = 2
InpStopLossPips = 80.0
InpTakeProfitPips = 240.0
InpUseTimeFilter = false
InpSignalInterval = 120
```
**Target**: Longer-term trades, wider SL/TP, fewer signals

---

## Parameter Optimization Guide

### Step 1: Start with Preset
Choose appropriate preset based on your:
- Experience level
- Risk tolerance
- Trading style
- Time availability

### Step 2: Test on Demo
Run for minimum 2 weeks with chosen preset

### Step 3: Analyze Results
Check these metrics:
- Win rate (target: >50%)
- Profit factor (target: >1.3)
- Max drawdown (target: <20%)
- Number of trades (reasonable frequency)
- Average profit vs loss

### Step 4: Adjust One Parameter
If results need improvement, adjust ONE parameter:

**Too few trades**:
- Lower InpConfidenceThreshold by 0.01
- OR lower InpMomentumThreshold by 0.02
- OR disable time filter

**Too many trades**:
- Raise InpConfidenceThreshold by 0.01
- OR raise InpMomentumThreshold by 0.02
- OR enable time filter

**Low win rate**:
- Raise InpConfidenceThreshold
- OR raise InpMomentumThreshold
- OR widen stop loss

**Large losses**:
- Reduce InpRiskPercent
- OR reduce InpMaxPositions
- OR lower InpMaxDrawdown threshold

### Step 5: Re-test
Test for another 2 weeks with new setting

### Step 6: Iterate
Repeat until results satisfactory

**IMPORTANT**: Only change ONE parameter at a time!

---

## Advanced Configuration Tips

### For Different Account Sizes

**Micro Account ($500-$1,000)**:
- Risk: 0.5-1.0%
- Max Positions: 1
- Focus on: Capital preservation

**Small Account ($1,000-$5,000)**:
- Risk: 1.0%
- Max Positions: 1-2
- Focus on: Steady growth

**Standard Account ($5,000-$20,000)**:
- Risk: 1.0-1.5%
- Max Positions: 2-3
- Focus on: Balanced growth

**Large Account ($20,000+)**:
- Risk: 1.0-2.0%
- Max Positions: 3-5
- Focus on: Diversification

### For Different Market Conditions

**Trending Markets**:
- Lower momentum threshold (0.08)
- Wider TP (150+ pips)
- Allow more positions

**Ranging Markets**:
- Higher confidence threshold (0.05)
- Tighter SL/TP (40/80)
- Fewer positions

**Volatile Markets**:
- Wider SL (60-80 pips)
- Higher confidence (0.05)
- Lower risk per trade

**Quiet Markets**:
- Lower thresholds
- Consider time filter
- Be patient

---

## Configuration Mistakes to Avoid

❌ **Too Aggressive**: High risk% + many positions + low thresholds
✅ **Better**: Start conservative, increase gradually

❌ **Mismatched SL/TP**: SL=100, TP=50 (bad ratio)
✅ **Better**: TP should be at least 1.5× SL

❌ **No Time Filter**: Trading during Asian session for EUR
✅ **Better**: Enable filter, focus on active sessions

❌ **Too Many Changes**: Adjusting multiple parameters at once
✅ **Better**: Change one parameter, test, evaluate

❌ **Insufficient Capital**: $500 account with 3 positions, 2% risk
✅ **Better**: Adequate capital for position count

❌ **Ignoring Drawdown**: Set to 50% "just in case"
✅ **Better**: Set realistic limit (15-25%) you can tolerate

---

## Summary

**Key Principles**:
1. Start conservative
2. Test thoroughly
3. Adjust gradually
4. Monitor continuously
5. Keep adequate capital
6. Respect risk management
7. Be patient

**Most Important Settings**:
- InpRiskPercent (protects account)
- InpMaxDrawdown (prevents disaster)
- InpMaxPositions (controls exposure)

**Least Critical Settings**:
- InpMagicNumber (just needs to be unique)
- InpSignalInterval (60 is fine for most)

**For Best Results**:
- Use recommended presets as starting point
- Test on demo minimum 2 weeks
- Adjust one parameter at a time
- Document all changes and results
- Move to live only when confident

---

**Need Help?** Refer to USER_MANUAL.txt for detailed guidance!

