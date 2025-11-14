# ForexTrader v4.0 Enhanced Scalper - Implementation Notes

## Status: In Progress

The v4.0 Enhanced Scalper version is being created based on the v3.2 Scalper with the same enhancements applied to the MultiStrategy version.

## Changes Applied So Far

### 1. Header & Version Information ✅
- Updated to v4.0 Enhanced Scalper
- Professional production-ready branding
- Enhanced descriptions

### 2. Market Regime Enumeration ✅
- Added 5 regime types: STRONG_UPTREND, STRONG_DOWNTREND, RANGING_LOW_VOL, RANGING_HIGH_VOL, NEUTRAL

### 3. Input Parameters ✅
- Added Market Regime Detection parameters (M15 timeframe for scalping)
- Added UseAdaptiveScoring parameter
- Added SignalConfluenceBonus parameter
- Reduced MA_SlopeMinimum to 1.5 pips (from 2.0) for scalping sensitivity
- Added MA_DistanceMinimum = 1.0 pips
- Added MomentumBars parameter
- Added Breakout Detection parameters (3.0 pip threshold for scalping)

### 4. Global Variables ✅
- Added lastBuyTime and lastSellTime
- Added currentMarketRegime variable
- Added regime indicator handles
- Added regime update tracking
- Set regime update interval to 180 seconds (3 minutes) for scalping

### 5. Forward Declarations ✅
- Added forward declarations for all new functions

## Changes Still Needed

### 6. OnInit() Function
- Initialize regime detection indicators (M15 timeframe)
- Set array series for regime buffers
- Update initialization logging

### 7. OnTick() Function  
- Add regime update call every 3 minutes
- Existing scalping logic should remain

### 8. Implement New Functions
Must add these functions (same logic as MultiStrategy but optimized for scalping):

```mql5
void UpdateMarketRegime()
{
   // Analyze M15 timeframe
   // Copy regime indicators
   // Classify into 5 regimes
   // Log regime changes
}

bool IsStrategyEnabledForRegime(ENUM_STRATEGY_TYPE strategy)
{
   // Filter strategies based on regime
   // Trending → MA/MACD
   // Ranging low-vol → RSI/BB
   // Ranging high-vol → Block all
}

int GetRegimeAdjustedThreshold()
{
   // Adaptive threshold based on regime
   // Trends: -20% (16 for scalping)
   // Normal: 20 (baseline)
   // Neutral: +30% (26 for scalping)
}

int CheckMomentum(string symbol, double pipSz)
{
   // 3-bar momentum filter
   // >2 pips in 3 bars = bullish
   // <-2 pips = bearish
}

int CheckBreakout(string symbol, double pipSz)
{
   // 5-bar range breakout
   // Min 3 pips for scalping
}
```

### 9. Enhanced Signal Generation
Update CheckEntrySignals() or equivalent to:
- Add regime filtering: `IsStrategyEnabledForRegime(STRATEGY_MA)`
- Add adaptive threshold: `GetRegimeAdjustedThreshold()`
- Enhanced MA scoring: 35 base + slope +10 + momentum +10 + breakout +10
- MA distance check: Must be >1 pip apart
- Confluence bonus: +15 when 2+ strategies agree
- Regime logging in signal output

### 10. Enhanced Position Sizing
Update CalculateStopLoss():
- Add MinSL_Pips and MaxSL_Pips bounds
- For scalping: MinSL = 5 pips, MaxSL = 25 pips (tighter than MultiStrategy)

Update CalculateTakeProfit():
- Add minimum TP validation (1.5x MinSL)

### 11. Configuration Files
Create:
- `ForexTrader_v4.0_Enhanced_Scalper.set` (Balanced scalping)
- `ForexTrader_v4.0_Scalper_Aggressive.set` (High-frequency)

## Scalping-Specific Optimizations

### Key Differences from MultiStrategy

| Parameter | MultiStrategy v4.0 | Scalper v4.0 |
|-----------|-------------------|--------------|
| RegimeTimeframe | H1 | M15 |
| Regime Update Interval | 300s (5 min) | 180s (3 min) |
| MinSignalScore | 25 | 20 |
| MA_SlopeMinimum | 3.0 pips | 1.5 pips |
| MA_DistanceMinimum | 2.0 pips | 1.0 pips |
| BreakoutThresholdPips | 5.0 | 3.0 |
| MomentumThreshold | 3.0 pips | 2.0 pips |
| MinSL_Pips | 15 | 5 |
| MaxSL_Pips | 100 | 25 |
| CooldownMinutes | 1 | 0 (no cooldown) |
| MaxDailyTrades | 100 | 200 |

## Testing Requirements

1. Compile in MetaEditor - verify 0 errors
2. Test on M1/M5 timeframes with high-liquidity pairs
3. Verify regime detection updates every 3 minutes
4. Confirm tighter SL/TP bounds (5-25 pips)
5. Validate higher signal frequency (scalping appropriate)
6. Check risk controls maintain tight drawdown

## Expected Performance

- Signals: 15-30/day per symbol (vs 8-15 for MultiStrategy)
- Win Rate: 50-60% (slightly lower due to scalping)
- Average trade duration: 5-30 minutes
- Daily trades: 50-100+ across all symbols
- Max SL: 25 pips (vs 100 for MultiStrategy)

## Next Steps

1. Complete implementation of remaining functions
2. Test compilation
3. Create configuration files
4. Backtest on M1/M5 data
5. Validate scalping performance metrics
