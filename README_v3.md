# ForexTrader EA v3.0 - Production Grade

## Overview

This repository contains production-ready Expert Advisors (EAs) for MetaTrader 5 that implement professional forex trading strategies with comprehensive risk management.

## What's New in v3.0

### Major Improvements

All **18 critical flaws** identified in the previous versions have been fixed:

#### Critical Bug Fixes
1. ✅ **Fixed SL/TP Calculation** - Removed the 10x multiplier bug that was causing stops 10x too large
2. ✅ **Proper MA Crossover Detection** - Now correctly detects crossovers instead of sustained trends
3. ✅ **Fixed Tick Value Calculation** - Uses SYMBOL_TRADE_TICK_VALUE_PROFIT with proper fallback
4. ✅ **Broker Stops Level Validation** - All trades validated against broker requirements before execution
5. ✅ **Spread Sanity Checks** - Rejects trades when spread is too high (absolute and relative to SL)
6. ✅ **Cooldown Mechanism** - Prevents rapid re-entry after losses, with separate buy/sell cooldowns
7. ✅ **Trade Retry Logic** - Implements intelligent retry with transient error detection
8. ✅ **Proper Pip Size Calculation** - Correctly handles 3 and 5 digit brokers

#### Risk Management Enhancements
1. ✅ **ADX Trend Filter** - Only trades during strong trends
2. ✅ **ATR Volatility Filter** - Avoids both low volatility and spike conditions
3. ✅ **Max Drawdown Guard** - Automatically stops trading if drawdown exceeds threshold
4. ✅ **MA Slope and Distance Filters** - Eliminates weak crossover signals
5. ✅ **Daily Trade Limits** - Prevents overtrading
6. ✅ **Portfolio Risk Management** - Tracks total risk across all positions

#### Position Management
1. ✅ **Breakeven Move** - Automatically moves SL to breakeven when profitable
2. ✅ **Smart Trailing Stop** - Only activates after profit threshold reached
3. ✅ **Partial Take Profit** - Can close portion of position at first target

#### Professional Features
1. ✅ **OnTradeTransaction Handler** - Proper trade lifecycle management
2. ✅ **Comprehensive Error Handling** - Detailed error descriptions and smart retry logic
3. ✅ **Modular Code Structure** - Easy to test and maintain
4. ✅ **Input Validation** - Prevents incorrect parameter settings
5. ✅ **Enhanced Logging** - Detailed context for debugging

## Available EAs

### 1. ForexTrader_v3_Production.mq5 (Single-Pair EA)

**Best for:** Traders who want to focus on one currency pair with maximum stability and control.

**Key Features:**
- Adaptive MA crossover strategy with multiple confirmation filters
- ADX trend strength filter
- ATR volatility range filter
- Comprehensive risk management
- Breakeven and trailing stop management
- Separate buy/sell cooldown
- Daily trade limits

**Recommended Settings:**
- Risk: 1.5-2% per trade
- Timeframe: M15, M30, or H1
- Pairs: Major pairs (EURUSD, GBPUSD, USDJPY)

### 2. ForexTrader_v3_MultiStrategy_Production.mq5 (Multi-Strategy Portfolio EA)

**Best for:** Experienced traders who want to diversify across multiple strategies.

**Key Features:**
- **4 Trading Strategies:**
  - Moving Average Crossover
  - RSI Reversal
  - Bollinger Bands Bounce
  - MACD Crossover
- **Signal Scoring System** - Combines multiple strategies for high-probability trades
- **Multi-Timeframe Analysis** - Confirms trends across M15, M30, and H1
- **Portfolio Risk Management** - Manages total risk across all positions
- **Session-Based Filters** - Trade specific market sessions (London, NY, Asian)
- **Dynamic Risk Adjustment** - Adjusts risk based on win rate
- **Strategy Performance Tracking** - Monitors each strategy's effectiveness
- **Partial Take Profit** - Locks in profits while letting winners run

**Recommended Settings:**
- Risk: 1.5% per trade
- Min Signal Score: 60 (for quality entries)
- Max Concurrent Positions: 3-5
- Timeframe: M15 or M30

## Installation

1. Copy the desired EA file to: `MetaTrader 5/MQL5/Experts/`
2. Restart MetaTrader 5 or refresh the Navigator
3. Drag the EA onto your chart
4. Configure the input parameters
5. Enable AutoTrading

## Recommended Configuration

### Conservative (Low Risk)
```
Risk Per Trade: 1.0%
Max Drawdown: 20%
Use ADX Filter: Yes
ADX Minimum: 25
Use ATR Filter: Yes
Max Concurrent Positions: 1-2
```

### Moderate (Balanced)
```
Risk Per Trade: 1.5-2.0%
Max Drawdown: 25%
Use ADX Filter: Yes
ADX Minimum: 20
Use ATR Filter: Yes
Max Concurrent Positions: 3-4
```

### Aggressive (Higher Risk/Reward)
```
Risk Per Trade: 2.5-3.0%
Max Drawdown: 30%
Use ADX Filter: Optional
Min Signal Score: 50 (Multi-Strategy EA)
Max Concurrent Positions: 5
```

## Testing

### Backtesting
1. Open Strategy Tester (Ctrl+R)
2. Select the EA
3. Choose symbol and timeframe
4. Set date range (minimum 6 months recommended)
5. Use "Every tick" mode for accuracy
6. Optimize key parameters if needed

### Forward Testing
1. Test on demo account first (minimum 1 month)
2. Monitor performance metrics:
   - Win rate
   - Profit factor
   - Maximum drawdown
   - Average trade duration
3. Adjust parameters based on results
4. Only move to live when consistently profitable

## Parameter Guide

### Risk Management Parameters

| Parameter | Description | Default | Range |
|-----------|-------------|---------|-------|
| RiskPercent | Risk per trade as % of balance | 2.0 | 0.5-5.0 |
| StopLossPips | Fixed stop loss in pips | 40 | 20-100 |
| TakeProfitPips | Fixed take profit in pips | 80 | 40-200 |
| MaxDrawdownPercent | Max drawdown before halting | 30.0 | 10-50 |
| MaxSpreadPips | Maximum acceptable spread | 5.0 | 1-10 |

### Filter Parameters

| Parameter | Description | Default | Range |
|-----------|-------------|---------|-------|
| UseADXFilter | Enable trend strength filter | Yes | - |
| ADX_Minimum | Minimum ADX value for trading | 20.0 | 15-30 |
| UseATRFilter | Enable volatility filter | Yes | - |
| ATR_MinimumPips | Minimum volatility to trade | 10.0 | 5-20 |
| ATR_MaximumPips | Maximum volatility (spike protection) | 100.0 | 50-200 |

### Position Management Parameters

| Parameter | Description | Default | Range |
|-----------|-------------|---------|-------|
| UseBreakeven | Auto move to breakeven | Yes | - |
| BreakevenTriggerPips | Profit to trigger breakeven | 20.0 | 10-50 |
| UseTrailingStop | Enable trailing stop | Yes | - |
| TrailingStopPips | Trailing distance | 30.0 | 15-50 |
| TrailingActivationPips | Profit to activate trailing | 20.0 | 10-40 |

## Performance Monitoring

### Key Metrics to Watch

1. **Win Rate**: Should be 50-70%
2. **Profit Factor**: Should be > 1.5
3. **Maximum Drawdown**: Should stay under your threshold
4. **Average Trade Duration**: Should align with your timeframe
5. **Risk/Reward Ratio**: Should be at least 1:1.5

### Warning Signs

- **Excessive losses**: Check if market conditions changed
- **High drawdown**: Reduce risk or pause trading
- **Low win rate (<40%)**: Review filter settings
- **Frequent order rejections**: Check spread and broker conditions

## Advanced Features

### Dynamic Risk Management (Multi-Strategy EA)
The multi-strategy EA can adjust risk based on recent performance:
- Win rate > 60%: Increases risk by 20%
- Win rate < 40%: Decreases risk by 20%
- Stays within MinRiskPercent and MaxRiskPercent bounds

### Multi-Timeframe Analysis
When enabled, the EA requires confirmation from multiple timeframes:
- Fast TF (M15): Quick trend detection
- Medium TF (M30): Confirms trend strength
- Slow TF (H1): Validates major trend direction

### Session Filters
Trade specific market sessions for optimal conditions:
- **Asian Session**: Lower volatility, range-bound
- **London Session**: High volatility, strong trends
- **New York Session**: Highest liquidity, best for breakouts

## Troubleshooting

### EA Not Trading

1. Check AutoTrading is enabled (F7 key)
2. Verify trading hours (if UseTradingHours enabled)
3. Check if daily trade limit reached
4. Verify spread is within MaxSpreadPips
5. Check if ADX/ATR filters are too restrictive
6. Review cooldown settings

### Order Rejected

1. Check broker connection
2. Verify account has sufficient margin
3. Check if stop levels are valid
4. Review spread at time of rejection
5. Check broker's minimum lot size

### Poor Performance

1. Optimize parameters for your broker and pair
2. Check if market regime changed (trending vs ranging)
3. Verify spread costs aren't too high
4. Review filter settings (may be too restrictive or too loose)
5. Consider different timeframe

## Safety Features

All v3.0 EAs include multiple safety layers:

1. **Pre-trade Validation**: Checks spread, stops levels, freeze levels
2. **Drawdown Protection**: Stops trading if max drawdown reached
3. **Portfolio Risk Limits**: Prevents over-exposure
4. **Error Handling**: Graceful handling of all order errors
5. **Position Monitoring**: Continuous management of open trades

## Support and Updates

For issues, suggestions, or questions:
- GitHub Issues: [Report here](https://github.com/simonokwundue-ops/Experienced-FX-Trader/issues)
- Review previous logs in `/Previous Logs/` for development history

## Credits

- Original concept and analysis: SimonFX
- Development: GitHub Copilot Agent
- Based on professional forex trading principles from included course materials

## Disclaimer

**IMPORTANT**: Trading forex carries substantial risk. These EAs are provided for educational purposes. Always:
- Test thoroughly on demo accounts
- Never risk more than you can afford to lose
- Understand all parameters before using
- Monitor performance regularly
- Keep stop losses in place

Past performance does not guarantee future results. Use at your own risk.

## Version History

### v3.0 (Current)
- Complete refactoring with all critical flaws fixed
- Production-ready single-pair and multi-strategy versions
- Comprehensive risk management system
- Professional error handling and logging

### v2.0
- Multi-strategy implementation (with flaws)
- Portfolio management features

### v1.2
- User tuned version (with improvements but still flawed)

### v1.0 (Base)
- Initial implementation (had 18+ critical flaws)

## License

MIT License - See repository for details.
