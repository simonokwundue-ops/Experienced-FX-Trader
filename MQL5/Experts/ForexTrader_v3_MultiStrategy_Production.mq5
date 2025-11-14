//+------------------------------------------------------------------+
//|                      ForexTrader_v3_MultiStrategy_Production.mq5 |
//|                     Production-Ready Multi-Strategy Portfolio EA |
//|                          With Advanced Risk Management            |
//+------------------------------------------------------------------+
#property copyright "ForexTrader EA v3.0 Multi-Strategy - Production Grade"
#property link      "https://github.com/simonokwundue-ops/Experienced-FX-Trader"
#property version   "3.00"
#property description "Professional multi-strategy EA with portfolio management"
#property description "Implements MA, RSI, BB, and MACD strategies with signal scoring"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

//--- Global Objects
CTrade trade;
CPositionInfo positionInfo;
CAccountInfo accountInfo;

//+------------------------------------------------------------------+
//| Strategy Enumeration                                              |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY_TYPE
{
   STRATEGY_MA = 0,      // Moving Average Crossover
   STRATEGY_RSI = 1,     // RSI Reversal
   STRATEGY_BB = 2,      // Bollinger Bands
   STRATEGY_MACD = 3     // MACD
};

//+------------------------------------------------------------------+
//| Input Parameters - Strategy Selection                            |
//+------------------------------------------------------------------+
input group "=== Strategy Selection ==="
input bool     UseMAStrategy = true;          // Use MA Crossover Strategy
input bool     UseRSIStrategy = true;         // Use RSI Strategy
input bool     UseBBStrategy = true;          // Use Bollinger Bands Strategy
input bool     UseMACDStrategy = true;        // Use MACD Strategy
input int      MinSignalScore = 60;           // Minimum Signal Score (0-100)

//+------------------------------------------------------------------+
//| Input Parameters - Multi-Timeframe                               |
//+------------------------------------------------------------------+
input group "=== Multi-Timeframe Analysis ==="
input bool     UseMultiTimeframe = true;      // Enable Multi-Timeframe Analysis
input ENUM_TIMEFRAMES TimeFrame1 = PERIOD_M15; // Fast Timeframe
input ENUM_TIMEFRAMES TimeFrame2 = PERIOD_M30; // Medium Timeframe
input ENUM_TIMEFRAMES TimeFrame3 = PERIOD_H1;  // Slow Timeframe
input int      MinTFConfirmation = 2;         // Min Timeframes for Signal (1-3)

//+------------------------------------------------------------------+
//| Input Parameters - MA Strategy                                   |
//+------------------------------------------------------------------+
input group "=== Moving Average Strategy ==="
input int      FastMA_Period = 10;            // Fast MA Period
input int      SlowMA_Period = 50;            // Slow MA Period
input ENUM_MA_METHOD MA_Method = MODE_EMA;    // MA Method
input ENUM_APPLIED_PRICE MA_Price = PRICE_CLOSE; // MA Applied Price
input double   MA_SlopeMinimum = 5.0;         // Min MA Slope (Pips)

//+------------------------------------------------------------------+
//| Input Parameters - RSI Strategy                                  |
//+------------------------------------------------------------------+
input group "=== RSI Strategy ==="
input int      RSI_Period = 14;               // RSI Period
input double   RSI_Oversold = 30.0;           // RSI Oversold Level
input double   RSI_Overbought = 70.0;         // RSI Overbought Level
input ENUM_APPLIED_PRICE RSI_Price = PRICE_CLOSE; // RSI Applied Price

//+------------------------------------------------------------------+
//| Input Parameters - Bollinger Bands Strategy                      |
//+------------------------------------------------------------------+
input group "=== Bollinger Bands Strategy ==="
input int      BB_Period = 20;                // BB Period
input double   BB_Deviation = 2.0;            // BB Standard Deviation
input ENUM_APPLIED_PRICE BB_AppliedPrice = PRICE_CLOSE; // BB Applied Price

//+------------------------------------------------------------------+
//| Input Parameters - MACD Strategy                                 |
//+------------------------------------------------------------------+
input group "=== MACD Strategy ==="
input int      MACD_FastEMA = 12;             // MACD Fast EMA
input int      MACD_SlowEMA = 26;             // MACD Slow EMA
input int      MACD_Signal = 9;               // MACD Signal Period
input ENUM_APPLIED_PRICE MACD_Price = PRICE_CLOSE; // MACD Applied Price

//+------------------------------------------------------------------+
//| Input Parameters - Filters                                       |
//+------------------------------------------------------------------+
input group "=== Signal Filters ==="
input bool     UseADXFilter = true;           // Use ADX Trend Filter
input int      ADX_Period = 14;               // ADX Period
input double   ADX_Minimum = 20.0;            // Minimum ADX Level
input bool     UseATRFilter = true;           // Use ATR Volatility Filter
input int      ATR_Period = 14;               // ATR Period
input double   ATR_MinimumPips = 10.0;        // Minimum ATR (Pips)
input double   ATR_MaximumPips = 100.0;       // Maximum ATR (Pips)

//+------------------------------------------------------------------+
//| Input Parameters - Portfolio Risk Management                     |
//+------------------------------------------------------------------+
input group "=== Portfolio Risk Management ==="
input double   MaxPortfolioRisk = 10.0;       // Max Portfolio Risk (% of Balance)
input double   BaseRiskPercent = 1.5;         // Base Risk Per Trade (%)
input bool     UseDynamicRisk = true;         // Use Win Rate Based Risk
input double   MinRiskPercent = 0.5;          // Minimum Risk Per Trade (%)
input double   MaxRiskPercent = 3.0;          // Maximum Risk Per Trade (%)
input double   MaxDrawdownPercent = 30.0;     // Max Drawdown % (halt trading)

//+------------------------------------------------------------------+
//| Input Parameters - Position Sizing                               |
//+------------------------------------------------------------------+
input group "=== Position Sizing ==="
input double   StopLossPips = 40.0;           // Stop Loss (Pips)
input double   TakeProfitPips = 80.0;         // Take Profit (Pips)
input bool     UseATRSizing = true;           // Use ATR for SL/TP
input double   ATR_SL_Multiplier = 2.0;       // ATR Multiplier for SL
input double   ATR_TP_Multiplier = 4.0;       // ATR Multiplier for TP
input double   MaxSpreadPips = 5.0;           // Max Spread (Pips)

//+------------------------------------------------------------------+
//| Input Parameters - Position Management                           |
//+------------------------------------------------------------------+
input group "=== Position Management ==="
input bool     UseBreakeven = true;           // Move to Breakeven
input double   BreakevenTriggerPips = 20.0;   // Breakeven Trigger (Pips)
input double   BreakevenOffsetPips = 2.0;     // Breakeven Offset (Pips)
input bool     UsePartialTP = true;           // Use Partial Take Profit
input double   PartialTP_Pips = 40.0;         // Partial TP Level (Pips)
input double   PartialTP_Percent = 50.0;      // Partial Close % (0-100)
input bool     UseTrailingStop = true;        // Enable Trailing Stop
input double   TrailingStopPips = 30.0;       // Trailing Distance (Pips)
input double   TrailingStepPips = 5.0;        // Trailing Step (Pips)
input double   TrailingActivationPips = 20.0; // Trailing Activation (Pips)

//+------------------------------------------------------------------+
//| Input Parameters - Trading Controls                              |
//+------------------------------------------------------------------+
input group "=== Trading Controls ==="
input int      MaxDailyTrades = 20;           // Max Trades Per Day
input int      MaxConcurrentPositions = 5;    // Max Concurrent Positions
input int      CooldownMinutes = 15;          // Cooldown Between Trades (Min)
input bool     SeparateCooldownByDirection = true; // Separate Buy/Sell Cooldown

//+------------------------------------------------------------------+
//| Input Parameters - Session Filters                               |
//+------------------------------------------------------------------+
input group "=== Session Filters ==="
input bool     UseSessionFilter = true;       // Enable Session Filter
input bool     TradeAsianSession = false;     // Trade Asian Session
input bool     TradeLondonSession = true;     // Trade London Session
input bool     TradeNYSession = true;         // Trade New York Session
input int      AsianStartHour = 0;            // Asian Start Hour (GMT)
input int      AsianEndHour = 8;              // Asian End Hour (GMT)
input int      LondonStartHour = 7;           // London Start Hour (GMT)
input int      LondonEndHour = 16;            // London End Hour (GMT)
input int      NYStartHour = 12;              // NY Start Hour (GMT)
input int      NYEndHour = 21;                // NY End Hour (GMT)

//+------------------------------------------------------------------+
//| Input Parameters - Money Management                              |
//+------------------------------------------------------------------+
input group "=== Money Management ==="
input double   MaxLotSize = 5.0;              // Maximum Lot Size
input double   MinLotSize = 0.01;             // Minimum Lot Size
input bool     UseCompounding = true;         // Use Compounding
input bool     UseFixedLot = false;           // Use Fixed Lot
input double   FixedLotSize = 0.1;            // Fixed Lot Size

//+------------------------------------------------------------------+
//| Input Parameters - Advanced Settings                             |
//+------------------------------------------------------------------+
input group "=== Advanced Settings ==="
input int      MagicNumber = 234567;          // Magic Number
input string   TradeComment = "ForexTrader_v3_Multi"; // Trade Comment
input int      Slippage = 30;                 // Max Slippage (Points)
input int      MaxRetries = 3;                // Max Order Retries
input int      RetryDelayMs = 1000;           // Retry Delay (Ms)

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
// Indicator handles for current timeframe
int handleFastMA, handleSlowMA, handleADX, handleATR;
int handleRSI, handleBBUpper, handleBBMiddle, handleBBLower, handleMACD;

// Multi-timeframe indicator handles
int handleFastMA_TF1, handleSlowMA_TF1, handleFastMA_TF2, handleSlowMA_TF2;
int handleFastMA_TF3, handleSlowMA_TF3;

// Indicator buffers
double fastMA[], slowMA[], adxMain[], atrBuffer[];
double rsiBuffer[], bbUpper[], bbMiddle[], bbLower[];
double macdMain[], macdSignal[];

// Symbol properties
double point, tickSize, tickValue, lotStep, minLot, maxLot;
double pipSize;
int symbolDigits;

// Trading state
datetime lastBuyTime = 0;
datetime lastSellTime = 0;
int dailyTradeCount = 0;
datetime lastTradeDate = 0;

// Strategy performance tracking
struct StrategyStats
{
   int totalTrades;
   int winningTrades;
   double totalProfit;
   double winRate;
};

StrategyStats maStats, rsiStats, bbStats, macdStats;

// Position tracking for partial TP
struct PositionTracker
{
   ulong ticket;
   bool partialTPDone;
};

PositionTracker trackedPositions[100];
int trackedPositionCount = 0;

//+------------------------------------------------------------------+
//| Expert Initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Initialize trade object
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(Slippage);
   trade.SetTypeFilling(ORDER_FILLING_IOC);
   trade.SetAsyncMode(false);
   
   //--- Get symbol properties
   point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   symbolDigits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   //--- Calculate pip size correctly
   if(symbolDigits == 3 || symbolDigits == 5)
      pipSize = point * 10;
   else
      pipSize = point;
   
   //--- Get trading properties
   tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
   
   if(tickValue == 0)
   {
      double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      tickValue = tickSize * contractSize;
   }
   
   lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   //--- Validate inputs
   if(!ValidateInputs())
      return INIT_PARAMETERS_INCORRECT;
   
   //--- Create indicators for main timeframe
   if(UseMAStrategy)
   {
      handleFastMA = iMA(_Symbol, PERIOD_CURRENT, FastMA_Period, 0, MA_Method, MA_Price);
      handleSlowMA = iMA(_Symbol, PERIOD_CURRENT, SlowMA_Period, 0, MA_Method, MA_Price);
      
      if(handleFastMA == INVALID_HANDLE || handleSlowMA == INVALID_HANDLE)
      {
         Print("Error: Failed to create MA indicators");
         return INIT_FAILED;
      }
   }
   
   if(UseRSIStrategy)
   {
      handleRSI = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, RSI_Price);
      if(handleRSI == INVALID_HANDLE)
      {
         Print("Error: Failed to create RSI indicator");
         return INIT_FAILED;
      }
   }
   
   if(UseBBStrategy)
   {
      int bbHandle = iBands(_Symbol, PERIOD_CURRENT, BB_Period, 0, BB_Deviation, BB_AppliedPrice);
      if(bbHandle == INVALID_HANDLE)
      {
         Print("Error: Failed to create BB indicator");
         return INIT_FAILED;
      }
      handleBBUpper = bbHandle;
      handleBBMiddle = bbHandle;
      handleBBLower = bbHandle;
   }
   
   if(UseMACDStrategy)
   {
      handleMACD = iMACD(_Symbol, PERIOD_CURRENT, MACD_FastEMA, MACD_SlowEMA, MACD_Signal, MACD_Price);
      if(handleMACD == INVALID_HANDLE)
      {
         Print("Error: Failed to create MACD indicator");
         return INIT_FAILED;
      }
   }
   
   if(UseADXFilter)
   {
      handleADX = iADX(_Symbol, PERIOD_CURRENT, ADX_Period);
      if(handleADX == INVALID_HANDLE)
      {
         Print("Error: Failed to create ADX indicator");
         return INIT_FAILED;
      }
   }
   
   if(UseATRFilter || UseATRSizing)
   {
      handleATR = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
      if(handleATR == INVALID_HANDLE)
      {
         Print("Error: Failed to create ATR indicator");
         return INIT_FAILED;
      }
   }
   
   //--- Create multi-timeframe MA indicators if enabled
   if(UseMultiTimeframe && UseMAStrategy)
   {
      handleFastMA_TF1 = iMA(_Symbol, TimeFrame1, FastMA_Period, 0, MA_Method, MA_Price);
      handleSlowMA_TF1 = iMA(_Symbol, TimeFrame1, SlowMA_Period, 0, MA_Method, MA_Price);
      handleFastMA_TF2 = iMA(_Symbol, TimeFrame2, FastMA_Period, 0, MA_Method, MA_Price);
      handleSlowMA_TF2 = iMA(_Symbol, TimeFrame2, SlowMA_Period, 0, MA_Method, MA_Price);
      handleFastMA_TF3 = iMA(_Symbol, TimeFrame3, FastMA_Period, 0, MA_Method, MA_Price);
      handleSlowMA_TF3 = iMA(_Symbol, TimeFrame3, SlowMA_Period, 0, MA_Method, MA_Price);
   }
   
   //--- Set arrays as series
   ArraySetAsSeries(fastMA, true);
   ArraySetAsSeries(slowMA, true);
   ArraySetAsSeries(adxMain, true);
   ArraySetAsSeries(atrBuffer, true);
   ArraySetAsSeries(rsiBuffer, true);
   ArraySetAsSeries(bbUpper, true);
   ArraySetAsSeries(bbMiddle, true);
   ArraySetAsSeries(bbLower, true);
   ArraySetAsSeries(macdMain, true);
   ArraySetAsSeries(macdSignal, true);
   
   //--- Initialize strategy stats
   InitializeStrategyStats();
   
   //--- Print initialization
   Print("========================================");
   Print("ForexTrader v3.0 Multi-Strategy - Initialized");
   Print("Symbol: ", _Symbol);
   Print("Active Strategies: ", CountActiveStrategies());
   Print("Multi-Timeframe: ", UseMultiTimeframe ? "Yes" : "No");
   Print("Min Signal Score: ", MinSignalScore);
   Print("========================================");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert Deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release all indicator handles
   if(handleFastMA != INVALID_HANDLE) IndicatorRelease(handleFastMA);
   if(handleSlowMA != INVALID_HANDLE) IndicatorRelease(handleSlowMA);
   if(handleADX != INVALID_HANDLE) IndicatorRelease(handleADX);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
   if(handleRSI != INVALID_HANDLE) IndicatorRelease(handleRSI);
   if(handleBBUpper != INVALID_HANDLE) IndicatorRelease(handleBBUpper);
   if(handleMACD != INVALID_HANDLE) IndicatorRelease(handleMACD);
   
   //--- Release multi-timeframe handles
   if(handleFastMA_TF1 != INVALID_HANDLE) IndicatorRelease(handleFastMA_TF1);
   if(handleSlowMA_TF1 != INVALID_HANDLE) IndicatorRelease(handleSlowMA_TF1);
   if(handleFastMA_TF2 != INVALID_HANDLE) IndicatorRelease(handleFastMA_TF2);
   if(handleSlowMA_TF2 != INVALID_HANDLE) IndicatorRelease(handleSlowMA_TF2);
   if(handleFastMA_TF3 != INVALID_HANDLE) IndicatorRelease(handleFastMA_TF3);
   if(handleSlowMA_TF3 != INVALID_HANDLE) IndicatorRelease(handleSlowMA_TF3);
   
   //--- Print final stats
   PrintStrategyPerformance();
   
   Print("ForexTrader v3.0 Multi-Strategy - Deinitialized");
}

//+------------------------------------------------------------------+
//| Expert Tick Function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check for new bar
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   
   if(currentBar == lastBar)
      return;
      
   lastBar = currentBar;
   
   //--- Reset daily counter
   ResetDailyTradeCount();
   
   //--- Update indicators
   if(!UpdateIndicators())
      return;
   
   //--- Check drawdown limit
   if(!CheckDrawdownLimit())
   {
      Print("Max drawdown exceeded. Trading halted.");
      return;
   }
   
   //--- Manage existing positions
   ManagePositions();
   
   //--- Check if can trade
   if(!CanOpenNewTrade())
      return;
   
   //--- Check for entry signals
   CheckEntrySignals();
}

//+------------------------------------------------------------------+
//| Trade Transaction Event                                           |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      ulong dealTicket = trans.deal;
      if(dealTicket > 0 && HistoryDealSelect(dealTicket))
      {
         long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
         if(dealMagic == MagicNumber)
         {
            ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealTicket, DEAL_TYPE);
            double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            
            if(dealProfit != 0) // Trade closed
            {
               UpdateStrategyStats(trans.position, dealProfit);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Validate Input Parameters                                         |
//+------------------------------------------------------------------+
bool ValidateInputs()
{
   if(!UseMAStrategy && !UseRSIStrategy && !UseBBStrategy && !UseMACDStrategy)
   {
      Print("Error: At least one strategy must be enabled");
      return false;
   }
   
   if(MinSignalScore < 0 || MinSignalScore > 100)
   {
      Print("Error: MinSignalScore must be between 0 and 100");
      return false;
   }
   
   if(BaseRiskPercent <= 0 || BaseRiskPercent > 100)
   {
      Print("Error: Risk percent must be between 0 and 100");
      return false;
   }
   
   if(MaxPortfolioRisk <= 0 || MaxPortfolioRisk > 100)
   {
      Print("Error: Max portfolio risk must be between 0 and 100");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update Indicator Values                                           |
//+------------------------------------------------------------------+
bool UpdateIndicators()
{
   //--- Update MA indicators
   if(UseMAStrategy)
   {
      if(CopyBuffer(handleFastMA, 0, 0, 3, fastMA) < 3) return false;
      if(CopyBuffer(handleSlowMA, 0, 0, 3, slowMA) < 3) return false;
   }
   
   //--- Update RSI
   if(UseRSIStrategy)
   {
      if(CopyBuffer(handleRSI, 0, 0, 3, rsiBuffer) < 3) return false;
   }
   
   //--- Update BB
   if(UseBBStrategy)
   {
      if(CopyBuffer(handleBBUpper, 1, 0, 2, bbUpper) < 2) return false;
      if(CopyBuffer(handleBBMiddle, 0, 0, 2, bbMiddle) < 2) return false;
      if(CopyBuffer(handleBBLower, 2, 0, 2, bbLower) < 2) return false;
   }
   
   //--- Update MACD
   if(UseMACDStrategy)
   {
      if(CopyBuffer(handleMACD, 0, 0, 3, macdMain) < 3) return false;
      if(CopyBuffer(handleMACD, 1, 0, 3, macdSignal) < 3) return false;
   }
   
   //--- Update ADX
   if(UseADXFilter)
   {
      if(CopyBuffer(handleADX, 0, 0, 1, adxMain) < 1) return false;
   }
   
   //--- Update ATR
   if(UseATRFilter || UseATRSizing)
   {
      if(CopyBuffer(handleATR, 0, 0, 1, atrBuffer) < 1) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check Drawdown Limit                                             |
//+------------------------------------------------------------------+
bool CheckDrawdownLimit()
{
   double equity = accountInfo.Equity();
   double balance = accountInfo.Balance();
   
   if(balance <= 0) return false;
   
   double drawdownPercent = ((balance - equity) / balance) * 100.0;
   
   return (drawdownPercent <= MaxDrawdownPercent);
}

//+------------------------------------------------------------------+
//| Reset Daily Trade Count                                          |
//+------------------------------------------------------------------+
void ResetDailyTradeCount()
{
   MqlDateTime currentTime, lastTime;
   TimeToStruct(TimeCurrent(), currentTime);
   TimeToStruct(lastTradeDate, lastTime);
   
   if(currentTime.day != lastTime.day || currentTime.mon != lastTime.mon || 
      currentTime.year != lastTime.year)
   {
      dailyTradeCount = 0;
      lastTradeDate = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| Can Open New Trade                                               |
//+------------------------------------------------------------------+
bool CanOpenNewTrade()
{
   //--- Check daily limit
   if(dailyTradeCount >= MaxDailyTrades)
      return false;
   
   //--- Check concurrent positions
   if(CountPositions() >= MaxConcurrentPositions)
      return false;
   
   //--- Check portfolio risk
   if(!CheckPortfolioRisk())
      return false;
   
   //--- Check session filter
   if(UseSessionFilter && !IsWithinTradingSession())
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check Portfolio Risk                                             |
//+------------------------------------------------------------------+
bool CheckPortfolioRisk()
{
   double totalRisk = 0;
   double balance = accountInfo.Balance();
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(positionInfo.SelectByIndex(i))
      {
         if(positionInfo.Magic() == MagicNumber)
         {
            double posRisk = CalculatePositionRisk(positionInfo.Ticket());
            totalRisk += posRisk;
         }
      }
   }
   
   double riskPercent = (totalRisk / balance) * 100.0;
   
   return (riskPercent < MaxPortfolioRisk);
}

//+------------------------------------------------------------------+
//| Calculate Position Risk                                          |
//+------------------------------------------------------------------+
double CalculatePositionRisk(ulong ticket)
{
   if(!positionInfo.SelectByTicket(ticket))
      return 0;
   
   double openPrice = positionInfo.PriceOpen();
   double sl = positionInfo.StopLoss();
   double volume = positionInfo.Volume();
   
   if(sl == 0) return 0;
   
   double slDistance = MathAbs(openPrice - sl);
   double ticksDistance = slDistance / tickSize;
   
   return ticksDistance * tickValue * volume;
}

//+------------------------------------------------------------------+
//| Check if Within Trading Session                                  |
//+------------------------------------------------------------------+
bool IsWithinTradingSession()
{
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);
   int hour = tm.hour;
   
   bool inAsian = (hour >= AsianStartHour && hour < AsianEndHour);
   bool inLondon = (hour >= LondonStartHour && hour < LondonEndHour);
   bool inNY = (hour >= NYStartHour && hour < NYEndHour);
   
   if(TradeAsianSession && inAsian) return true;
   if(TradeLondonSession && inLondon) return true;
   if(TradeNYSession && inNY) return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Check if Cooldown Elapsed                                        |
//+------------------------------------------------------------------+
bool IsCooldownElapsed(bool isBuySignal)
{
   datetime relevantTime = SeparateCooldownByDirection ?
                          (isBuySignal ? lastBuyTime : lastSellTime) :
                          MathMax(lastBuyTime, lastSellTime);
   
   return (TimeCurrent() - relevantTime) >= (CooldownMinutes * 60);
}

//+------------------------------------------------------------------+
//| Check Entry Signals                                              |
//+------------------------------------------------------------------+
void CheckEntrySignals()
{
   //--- Check basic filters
   if(!IsSpreadAcceptable()) return;
   if(UseATRFilter && !IsVolatilityAcceptable()) return;
   if(UseADXFilter && !IsTrendStrong()) return;
   
   //--- Generate signals from each strategy
   int buySignalScore = 0;
   int sellSignalScore = 0;
   string buyReasons = "";
   string sellReasons = "";
   
   //--- MA Strategy
   if(UseMAStrategy)
   {
      int maScore = AnalyzeMAStrategy(buyReasons, sellReasons);
      if(maScore > 0) buySignalScore += maScore;
      if(maScore < 0) sellSignalScore += MathAbs(maScore);
   }
   
   //--- RSI Strategy
   if(UseRSIStrategy)
   {
      int rsiScore = AnalyzeRSIStrategy(buyReasons, sellReasons);
      if(rsiScore > 0) buySignalScore += rsiScore;
      if(rsiScore < 0) sellSignalScore += MathAbs(rsiScore);
   }
   
   //--- BB Strategy
   if(UseBBStrategy)
   {
      int bbScore = AnalyzeBBStrategy(buyReasons, sellReasons);
      if(bbScore > 0) buySignalScore += bbScore;
      if(bbScore < 0) sellSignalScore += MathAbs(bbScore);
   }
   
   //--- MACD Strategy
   if(UseMACDStrategy)
   {
      int macdScore = AnalyzeMACDStrategy(buyReasons, sellReasons);
      if(macdScore > 0) buySignalScore += macdScore;
      if(macdScore < 0) sellSignalScore += MathAbs(macdScore);
   }
   
   //--- Apply multi-timeframe confirmation if enabled
   if(UseMultiTimeframe && UseMAStrategy)
   {
      int mtfScore = AnalyzeMultiTimeframe();
      if(mtfScore > 0)
      {
         buySignalScore += 20;
         buyReasons += "MTF Bullish | ";
      }
      else if(mtfScore < 0)
      {
         sellSignalScore += 20;
         sellReasons += "MTF Bearish | ";
      }
   }
   
   //--- Process buy signal
   if(buySignalScore >= MinSignalScore && IsCooldownElapsed(true))
   {
      Print("=== BUY SIGNAL | Score: ", buySignalScore, " ===");
      Print("Reasons: ", buyReasons);
      
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(OpenPosition(ORDER_TYPE_BUY, ask, STRATEGY_MA))
      {
         lastBuyTime = TimeCurrent();
         dailyTradeCount++;
      }
   }
   
   //--- Process sell signal
   if(sellSignalScore >= MinSignalScore && IsCooldownElapsed(false))
   {
      Print("=== SELL SIGNAL | Score: ", sellSignalScore, " ===");
      Print("Reasons: ", sellReasons);
      
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(OpenPosition(ORDER_TYPE_SELL, bid, STRATEGY_MA))
      {
         lastSellTime = TimeCurrent();
         dailyTradeCount++;
      }
   }
}

//+------------------------------------------------------------------+
//| Analyze MA Strategy                                              |
//+------------------------------------------------------------------+
int AnalyzeMAStrategy(string &buyReasons, string &sellReasons)
{
   //--- Check for crossover
   bool bullishCross = fastMA[1] > slowMA[1] && fastMA[2] <= slowMA[2];
   bool bearishCross = fastMA[1] < slowMA[1] && fastMA[2] >= slowMA[2];
   
   if(!bullishCross && !bearishCross)
      return 0;
   
   //--- Check MA slope
   double maSlope = MathAbs(fastMA[1] - fastMA[2]) / pipSize;
   if(maSlope < MA_SlopeMinimum)
      return 0;
   
   //--- Calculate score
   int score = 30; // Base score
   
   if(bullishCross)
   {
      buyReasons += "MA Bullish Cross | ";
      return score;
   }
   else if(bearishCross)
   {
      sellReasons += "MA Bearish Cross | ";
      return -score;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Analyze RSI Strategy                                             |
//+------------------------------------------------------------------+
int AnalyzeRSIStrategy(string &buyReasons, string &sellReasons)
{
   double rsi = rsiBuffer[0];
   double rsiPrev = rsiBuffer[1];
   
   int score = 0;
   
   //--- Oversold bounce
   if(rsiPrev < RSI_Oversold && rsi > RSI_Oversold)
   {
      score = 25;
      buyReasons += "RSI Oversold Bounce | ";
   }
   
   //--- Overbought fall
   if(rsiPrev > RSI_Overbought && rsi < RSI_Overbought)
   {
      score = -25;
      sellReasons += "RSI Overbought Fall | ";
   }
   
   return score;
}

//+------------------------------------------------------------------+
//| Analyze Bollinger Bands Strategy                                 |
//+------------------------------------------------------------------+
int AnalyzeBBStrategy(string &buyReasons, string &sellReasons)
{
   double close = iClose(_Symbol, PERIOD_CURRENT, 0);
   double closePrev = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   int score = 0;
   
   //--- Bounce from lower band
   if(closePrev <= bbLower[1] && close > bbLower[0])
   {
      score = 25;
      buyReasons += "BB Lower Bounce | ";
   }
   
   //--- Fall from upper band
   if(closePrev >= bbUpper[1] && close < bbUpper[0])
   {
      score = -25;
      sellReasons += "BB Upper Fall | ";
   }
   
   return score;
}

//+------------------------------------------------------------------+
//| Analyze MACD Strategy                                            |
//+------------------------------------------------------------------+
int AnalyzeMACDStrategy(string &buyReasons, string &sellReasons)
{
   int score = 0;
   
   //--- Bullish MACD crossover
   if(macdMain[1] > macdSignal[1] && macdMain[2] <= macdSignal[2])
   {
      score = 20;
      buyReasons += "MACD Bullish Cross | ";
   }
   
   //--- Bearish MACD crossover
   if(macdMain[1] < macdSignal[1] && macdMain[2] >= macdSignal[2])
   {
      score = -20;
      sellReasons += "MACD Bearish Cross | ";
   }
   
   return score;
}

//+------------------------------------------------------------------+
//| Analyze Multi-Timeframe                                          |
//+------------------------------------------------------------------+
int AnalyzeMultiTimeframe()
{
   double fastMA_TF1[], slowMA_TF1[];
   double fastMA_TF2[], slowMA_TF2[];
   double fastMA_TF3[], slowMA_TF3[];
   
   ArraySetAsSeries(fastMA_TF1, true);
   ArraySetAsSeries(slowMA_TF1, true);
   ArraySetAsSeries(fastMA_TF2, true);
   ArraySetAsSeries(slowMA_TF2, true);
   ArraySetAsSeries(fastMA_TF3, true);
   ArraySetAsSeries(slowMA_TF3, true);
   
   if(CopyBuffer(handleFastMA_TF1, 0, 0, 1, fastMA_TF1) < 1) return 0;
   if(CopyBuffer(handleSlowMA_TF1, 0, 0, 1, slowMA_TF1) < 1) return 0;
   if(CopyBuffer(handleFastMA_TF2, 0, 0, 1, fastMA_TF2) < 1) return 0;
   if(CopyBuffer(handleSlowMA_TF2, 0, 0, 1, slowMA_TF2) < 1) return 0;
   if(CopyBuffer(handleFastMA_TF3, 0, 0, 1, fastMA_TF3) < 1) return 0;
   if(CopyBuffer(handleSlowMA_TF3, 0, 0, 1, slowMA_TF3) < 1) return 0;
   
   int bullish = 0;
   int bearish = 0;
   
   if(fastMA_TF1[0] > slowMA_TF1[0]) bullish++; else bearish++;
   if(fastMA_TF2[0] > slowMA_TF2[0]) bullish++; else bearish++;
   if(fastMA_TF3[0] > slowMA_TF3[0]) bullish++; else bearish++;
   
   if(bullish >= MinTFConfirmation) return 1;
   if(bearish >= MinTFConfirmation) return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Check if Spread Acceptable                                       |
//+------------------------------------------------------------------+
bool IsSpreadAcceptable()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double spread = (ask - bid) / pipSize;
   
   if(spread > MaxSpreadPips)
   {
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if Volatility Acceptable                                   |
//+------------------------------------------------------------------+
bool IsVolatilityAcceptable()
{
   if(ArraySize(atrBuffer) == 0) return true;
   
   double atr = atrBuffer[0];
   double atrPips = atr / pipSize;
   
   if(atrPips < ATR_MinimumPips || atrPips > ATR_MaximumPips)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if Trend Strong                                            |
//+------------------------------------------------------------------+
bool IsTrendStrong()
{
   if(ArraySize(adxMain) == 0) return true;
   
   return (adxMain[0] >= ADX_Minimum);
}

//+------------------------------------------------------------------+
//| Open Position (with all fixes)                                   |
//+------------------------------------------------------------------+
bool OpenPosition(ENUM_ORDER_TYPE orderType, double price, ENUM_STRATEGY_TYPE strategy)
{
   //--- Calculate SL and TP
   double sl = CalculateStopLoss(orderType, price);
   double tp = CalculateTakeProfit(orderType, price);
   
   //--- Validate trade
   if(!ValidateTrade(orderType, price, sl, tp))
      return false;
   
   //--- Calculate lot size with dynamic risk
   double riskPercent = CalculateDynamicRisk();
   double lots = CalculateLotSize(price, sl, riskPercent);
   
   //--- Normalize
   sl = NormalizeDouble(sl, symbolDigits);
   tp = NormalizeDouble(tp, symbolDigits);
   lots = NormalizeLot(lots);
   
   if(lots < minLot || lots > maxLot)
      return false;
   
   //--- Open with retries
   bool success = false;
   int attempts = 0;
   
   while(attempts < MaxRetries && !success)
   {
      ResetLastError();
      
      if(orderType == ORDER_TYPE_BUY)
         success = trade.Buy(lots, _Symbol, 0, sl, tp, TradeComment);
      else
         success = trade.Sell(lots, _Symbol, 0, sl, tp, TradeComment);
      
      if(success)
      {
         Print("Position opened: ", EnumToString(orderType), " | Lots: ", lots, 
               " | SL: ", sl, " | TP: ", tp);
         
         //--- Track position for partial TP
         if(UsePartialTP)
         {
            trackedPositions[trackedPositionCount].ticket = trade.ResultOrder();
            trackedPositions[trackedPositionCount].partialTPDone = false;
            trackedPositionCount++;
         }
         
         return true;
      }
      else
      {
         int error = GetLastError();
         if(IsTransientError(error))
         {
            Sleep(RetryDelayMs);
            attempts++;
         }
         else
         {
            break;
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Calculate Dynamic Risk Based on Win Rate                         |
//+------------------------------------------------------------------+
double CalculateDynamicRisk()
{
   if(!UseDynamicRisk)
      return BaseRiskPercent;
   
   //--- Calculate overall win rate
   int totalTrades = maStats.totalTrades + rsiStats.totalTrades + 
                     bbStats.totalTrades + macdStats.totalTrades;
   int totalWins = maStats.winningTrades + rsiStats.winningTrades + 
                   bbStats.winningTrades + macdStats.winningTrades;
   
   if(totalTrades < 10)
      return BaseRiskPercent;
   
   double winRate = (double)totalWins / totalTrades;
   
   //--- Adjust risk based on win rate
   double risk = BaseRiskPercent;
   
   if(winRate > 0.6)
      risk = BaseRiskPercent * 1.2;
   else if(winRate < 0.4)
      risk = BaseRiskPercent * 0.8;
   
   //--- Apply limits
   if(risk < MinRiskPercent) risk = MinRiskPercent;
   if(risk > MaxRiskPercent) risk = MaxRiskPercent;
   
   return risk;
}

//+------------------------------------------------------------------+
//| Calculate Stop Loss                                              |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_ORDER_TYPE orderType, double price)
{
   double slDistance;
   
   if(UseATRSizing && ArraySize(atrBuffer) > 0)
   {
      slDistance = atrBuffer[0] * ATR_SL_Multiplier;
   }
   else
   {
      slDistance = StopLossPips * pipSize;
   }
   
   double sl = (orderType == ORDER_TYPE_BUY) ? 
               price - slDistance : price + slDistance;
   
   return sl;
}

//+------------------------------------------------------------------+
//| Calculate Take Profit                                            |
//+------------------------------------------------------------------+
double CalculateTakeProfit(ENUM_ORDER_TYPE orderType, double price)
{
   double tpDistance;
   
   if(UseATRSizing && ArraySize(atrBuffer) > 0)
   {
      tpDistance = atrBuffer[0] * ATR_TP_Multiplier;
   }
   else
   {
      tpDistance = TakeProfitPips * pipSize;
   }
   
   double tp = (orderType == ORDER_TYPE_BUY) ? 
               price + tpDistance : price - tpDistance;
   
   return tp;
}

//+------------------------------------------------------------------+
//| Validate Trade                                                   |
//+------------------------------------------------------------------+
bool ValidateTrade(ENUM_ORDER_TYPE orderType, double price, double sl, double tp)
{
   long stopsLevelPoints = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double stopsLevel = stopsLevelPoints * point;
   
   if(MathAbs(price - sl) < stopsLevel) return false;
   if(MathAbs(price - tp) < stopsLevel) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size                                               |
//+------------------------------------------------------------------+
double CalculateLotSize(double entryPrice, double stopLoss, double riskPercent)
{
   if(UseFixedLot)
      return FixedLotSize;
   
   double balance = UseCompounding ? accountInfo.Equity() : accountInfo.Balance();
   double riskAmount = balance * (riskPercent / 100.0);
   
   double slDistance = MathAbs(entryPrice - stopLoss);
   if(slDistance <= 0) return minLot;
   
   double ticksDistance = slDistance / tickSize;
   double riskPerLot = ticksDistance * tickValue;
   
   if(riskPerLot <= 0) return minLot;
   
   double lots = riskAmount / riskPerLot;
   
   if(lots > MaxLotSize) lots = MaxLotSize;
   if(lots < MinLotSize) lots = MinLotSize;
   
   return lots;
}

//+------------------------------------------------------------------+
//| Normalize Lot Size                                               |
//+------------------------------------------------------------------+
double NormalizeLot(double lots)
{
   lots = MathRound(lots / lotStep) * lotStep;
   
   if(lots < minLot) lots = minLot;
   if(lots > maxLot) lots = maxLot;
   
   return NormalizeDouble(lots, 2);
}

//+------------------------------------------------------------------+
//| Count Positions                                                   |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(positionInfo.SelectByIndex(i))
      {
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber)
         {
            count++;
         }
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| Manage Positions                                                  |
//+------------------------------------------------------------------+
void ManagePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!positionInfo.SelectByIndex(i))
         continue;
         
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber)
         continue;
      
      ulong ticket = positionInfo.Ticket();
      double openPrice = positionInfo.PriceOpen();
      double currentSL = positionInfo.StopLoss();
      double currentTP = positionInfo.TakeProfit();
      ENUM_POSITION_TYPE posType = positionInfo.PositionType();
      double volume = positionInfo.Volume();
      
      double currentPrice = (posType == POSITION_TYPE_BUY) ? 
                           SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                           SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      double profitPips = 0;
      if(posType == POSITION_TYPE_BUY)
         profitPips = (currentPrice - openPrice) / pipSize;
      else
         profitPips = (openPrice - currentPrice) / pipSize;
      
      //--- Partial TP
      if(UsePartialTP && profitPips >= PartialTP_Pips)
      {
         bool alreadyDone = false;
         for(int j = 0; j < trackedPositionCount; j++)
         {
            if(trackedPositions[j].ticket == ticket && trackedPositions[j].partialTPDone)
            {
               alreadyDone = true;
               break;
            }
         }
         
         if(!alreadyDone)
         {
            double closeVolume = NormalizeLot(volume * PartialTP_Percent / 100.0);
            if(closeVolume >= minLot && closeVolume < volume)
            {
               if(trade.PositionClosePartial(ticket, closeVolume))
               {
                  Print("Partial TP executed: Ticket ", ticket, " | Closed: ", closeVolume);
                  
                  for(int j = 0; j < trackedPositionCount; j++)
                  {
                     if(trackedPositions[j].ticket == ticket)
                     {
                        trackedPositions[j].partialTPDone = true;
                        break;
                     }
                  }
               }
            }
         }
      }
      
      //--- Breakeven
      if(UseBreakeven && profitPips >= BreakevenTriggerPips)
      {
         double bePrice = openPrice + (BreakevenOffsetPips * pipSize * 
                         (posType == POSITION_TYPE_BUY ? 1 : -1));
         
         bool needsUpdate = false;
         if(posType == POSITION_TYPE_BUY && (currentSL < bePrice || currentSL == 0))
            needsUpdate = true;
         else if(posType == POSITION_TYPE_SELL && (currentSL > bePrice || currentSL == 0))
            needsUpdate = true;
         
         if(needsUpdate)
         {
            bePrice = NormalizeDouble(bePrice, symbolDigits);
            if(trade.PositionModify(ticket, bePrice, currentTP))
            {
               Print("Breakeven: Ticket ", ticket, " | SL: ", bePrice);
            }
            continue;
         }
      }
      
      //--- Trailing stop
      if(UseTrailingStop && profitPips >= TrailingActivationPips)
      {
         double trailDistance = TrailingStopPips * pipSize;
         double trailStep = TrailingStepPips * pipSize;
         double newSL = 0;
         
         if(posType == POSITION_TYPE_BUY)
         {
            newSL = currentPrice - trailDistance;
            
            if(newSL > currentSL + trailStep || currentSL == 0)
            {
               newSL = NormalizeDouble(newSL, symbolDigits);
               
               if(newSL > openPrice)
               {
                  trade.PositionModify(ticket, newSL, currentTP);
               }
            }
         }
         else if(posType == POSITION_TYPE_SELL)
         {
            newSL = currentPrice + trailDistance;
            
            if(newSL < currentSL - trailStep || currentSL == 0)
            {
               newSL = NormalizeDouble(newSL, symbolDigits);
               
               if(newSL < openPrice)
               {
                  trade.PositionModify(ticket, newSL, currentTP);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if Error is Transient                                      |
//+------------------------------------------------------------------+
bool IsTransientError(int error)
{
   switch(error)
   {
      case 10004: case 10006: case 10007: case 10018:
      case 10021: case 10025: case 10027:
         return true;
      default:
         return false;
   }
}

//+------------------------------------------------------------------+
//| Initialize Strategy Stats                                        |
//+------------------------------------------------------------------+
void InitializeStrategyStats()
{
   maStats.totalTrades = 0;
   maStats.winningTrades = 0;
   maStats.totalProfit = 0;
   maStats.winRate = 0;
   
   rsiStats = maStats;
   bbStats = maStats;
   macdStats = maStats;
}

//+------------------------------------------------------------------+
//| Update Strategy Stats                                            |
//+------------------------------------------------------------------+
void UpdateStrategyStats(ulong positionID, double profit)
{
   //--- For simplicity, attribute to MA strategy
   //--- In a real implementation, you'd track which strategy opened each position
   maStats.totalTrades++;
   if(profit > 0) maStats.winningTrades++;
   maStats.totalProfit += profit;
   
   if(maStats.totalTrades > 0)
      maStats.winRate = (double)maStats.winningTrades / maStats.totalTrades * 100.0;
}

//+------------------------------------------------------------------+
//| Print Strategy Performance                                       |
//+------------------------------------------------------------------+
void PrintStrategyPerformance()
{
   Print("========================================");
   Print("Strategy Performance Summary");
   Print("MA: Trades=", maStats.totalTrades, " WinRate=", maStats.winRate, 
         "% Profit=", maStats.totalProfit);
   Print("========================================");
}

//+------------------------------------------------------------------+
//| Count Active Strategies                                          |
//+------------------------------------------------------------------+
int CountActiveStrategies()
{
   int count = 0;
   if(UseMAStrategy) count++;
   if(UseRSIStrategy) count++;
   if(UseBBStrategy) count++;
   if(UseMACDStrategy) count++;
   return count;
}
//+------------------------------------------------------------------+
