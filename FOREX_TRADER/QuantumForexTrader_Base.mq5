//+------------------------------------------------------------------+
//|                               QuantumForexTrader_Base.mq5         |
//|              Quantum-Enhanced Multi-Strategy Portfolio EA         |
//|          Based on IBM Quantum Phase Estimation Theory             |
//+------------------------------------------------------------------+
#property copyright "ForexTrader Quantum EA v1.0"
#property link      "https://github.com/simonokwundue-ops/Experienced-FX-Trader"
#property version   "1.00"
#property description "Quantum-enhanced EA with 60-70% target win rate"
#property description "Combines V3 multi-strategy with quantum market analysis"
#property description "Based on IBM Quantum article - MQL5.com/articles/17171"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include "Include/QuantumSignals.mqh"
#include "Include/QuantumAnalysis.mqh"
#include "Include/BinaryEncoder.mqh"
#include "Include/QuantumRiskManager.mqh"
#include "Include/PythonBridge.mqh"

//--- Global Objects
CTrade trade;
CPositionInfo positionInfo;
CAccountInfo accountInfo;

//--- Quantum Objects
CQuantumSignalGenerator *quantumSignalGen;
CQuantumPhaseEstimator *quantumPhaseEst;
CQuantumRiskManager *quantumRiskMgr;
CQuantumPatternDetector *quantumPatternDet;
CPythonBridge *pythonBridge;

//+------------------------------------------------------------------+
//| Input Parameters - Quantum Settings                              |
//+------------------------------------------------------------------+
input group "=== Quantum Analysis Settings ==="
input bool     UseQuantumAnalysis = true;     // Enable Quantum Analysis
input int      QuantumLookback = 256;          // Quantum Lookback Period (256 recommended)
input int      QuantumHorizon = 10;            // Quantum Prediction Horizon
input double   QuantumConfidenceThreshold = 60.0;  // Min Quantum Confidence (%)
input double   QuantumWeight = 0.6;            // Quantum Signal Weight (0-1)
input bool     UseQuantumRisk = true;          // Use Quantum Risk Management
input bool     UseQuantumFilters = true;       // Use Quantum Market Filters
input bool     UsePythonIntegration = false;   // Enable Python Integration (Optional)

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
input bool     UseQuantumMTF = true;          // Use Quantum Multi-Timeframe

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
input int      MagicNumber = 345678;          // Magic Number
input string   TradeComment = "QuantumFX_Base"; // Trade Comment
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

StrategyStats maStats, rsiStats, bbStats, macdStats, quantumStats;

// Position tracking for partial TP
struct PositionTracker
{
   ulong ticket;
   bool partialTPDone;
};

PositionTracker trackedPositions[100];
int trackedPositionCount = 0;

// Quantum statistics
struct QuantumPerformance
{
   int totalQuantumSignals;
   int quantumWins;
   double avgQuantumConfidence;
   double bestWinRate;
   datetime lastUpdate;
};

QuantumPerformance quantumPerf;

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
   
   //--- Initialize Quantum Components
   if(UseQuantumAnalysis)
   {
      quantumSignalGen = new CQuantumSignalGenerator(_Symbol, PERIOD_CURRENT, 
                                                     QuantumLookback, QuantumHorizon);
      quantumSignalGen.SetConfidenceThreshold(QuantumConfidenceThreshold);
      
      quantumPhaseEst = new CQuantumPhaseEstimator(_Symbol, PERIOD_CURRENT);
      
      if(UseQuantumRisk)
         quantumRiskMgr = new CQuantumRiskManager(_Symbol, PERIOD_CURRENT,
                                                  BaseRiskPercent, MinRiskPercent, MaxRiskPercent);
      
      quantumPatternDet = new CQuantumPatternDetector(_Symbol, PERIOD_CURRENT);
      
      Print("Quantum components initialized successfully");
   }
   
   //--- Initialize Python bridge (optional)
   if(UsePythonIntegration)
   {
      string pythonPath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Scripts\\Python\\";
      pythonBridge = new CPythonBridge(pythonPath, true);
      pythonBridge.LogStatus();
   }
   
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
   
   //--- Initialize quantum performance tracking
   quantumPerf.totalQuantumSignals = 0;
   quantumPerf.quantumWins = 0;
   quantumPerf.avgQuantumConfidence = 0;
   quantumPerf.bestWinRate = 0;
   quantumPerf.lastUpdate = TimeCurrent();
   
   //--- Print initialization
   Print("========================================");
   Print("QuantumForexTrader Base - Initialized");
   Print("Symbol: ", _Symbol);
   Print("Quantum Analysis: ", UseQuantumAnalysis ? "Enabled" : "Disabled");
   Print("Active Strategies: ", CountActiveStrategies());
   Print("Multi-Timeframe: ", UseMultiTimeframe ? "Yes" : "No");
   Print("Quantum MTF: ", UseQuantumMTF ? "Yes" : "No");
   Print("Min Signal Score: ", MinSignalScore);
   Print("Quantum Confidence: ", QuantumConfidenceThreshold, "%");
   Print("Target Win Rate: 60-70% (Quantum Enhanced)");
   Print("========================================");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert Deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release quantum components
   if(CheckPointer(quantumSignalGen) == POINTER_DYNAMIC)
      delete quantumSignalGen;
   if(CheckPointer(quantumPhaseEst) == POINTER_DYNAMIC)
      delete quantumPhaseEst;
   if(CheckPointer(quantumRiskMgr) == POINTER_DYNAMIC)
      delete quantumRiskMgr;
   if(CheckPointer(quantumPatternDet) == POINTER_DYNAMIC)
      delete quantumPatternDet;
   if(CheckPointer(pythonBridge) == POINTER_DYNAMIC)
      delete pythonBridge;
   
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
   PrintQuantumPerformance();
   
   Print("QuantumForexTrader Base - Deinitialized");
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
   
   //--- Quantum filter check
   if(UseQuantumAnalysis && UseQuantumFilters)
   {
      if(quantumRiskMgr.ShouldAvoidTrading())
      {
         Print("Quantum analysis suggests avoiding trading - high uncertainty");
         return;
      }
   }
   
   //--- Manage existing positions
   ManagePositions();
   
   //--- Check if can trade
   if(!CanOpenNewTrade())
      return;
   
   //--- Check for entry signals with quantum enhancement
   CheckQuantumEntrySignals();
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
               UpdateQuantumStats(dealProfit);
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
   
   if(UseQuantumAnalysis)
   {
      if(QuantumLookback < 50 || QuantumLookback > 500)
      {
         Print("Warning: QuantumLookback should be between 50-500, recommended 256");
      }
      
      if(QuantumConfidenceThreshold < 50 || QuantumConfidenceThreshold > 90)
      {
         Print("Warning: QuantumConfidenceThreshold should be between 50-90%");
      }
      
      if(QuantumWeight < 0 || QuantumWeight > 1)
      {
         Print("Error: QuantumWeight must be between 0 and 1");
         return false;
      }
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
//| Check Quantum Entry Signals                                       |
//+------------------------------------------------------------------+
void CheckQuantumEntrySignals()
{
   //--- Check basic filters
   if(!IsSpreadAcceptable()) return;
   if(UseATRFilter && !IsVolatilityAcceptable()) return;
   if(UseADXFilter && !IsTrendStrong()) return;
   
   //--- Get quantum signal first
   QuantumSignal qSignal;
   double quantumScore = 0;
   bool useQuantum = false;
   
   if(UseQuantumAnalysis)
   {
      qSignal = quantumSignalGen.GenerateSignal();
      
      if(qSignal.isValid)
      {
         quantumScore = qSignal.confidence;
         useQuantum = true;
         
         Print("Quantum Signal Generated:");
         Print("  Direction: ", qSignal.direction == 1 ? "BUY" : (qSignal.direction == -1 ? "SELL" : "NEUTRAL"));
         Print("  Confidence: ", qSignal.confidence, "%");
         Print("  Trend Strength: ", qSignal.trendStrength);
         Print("  Quantum Score: ", qSignal.quantumScore);
      }
   }
   
   //--- Generate signals from classical strategies
   int buySignalScore = 0;
   int sellSignalScore = 0;
   string buyReasons = "";
   string sellReasons = "";
   
   //--- MA Strategy
   if(UseMAStrategy)
   {
      int maScore = AnalyzeMAStrategy(buyReasons, sellReasons);
      if(maScore > 0) buySignalScore += maScore;
      else if(maScore < 0) sellSignalScore += MathAbs(maScore);
   }
   
   //--- RSI Strategy
   if(UseRSIStrategy)
   {
      int rsiScore = AnalyzeRSIStrategy(buyReasons, sellReasons);
      if(rsiScore > 0) buySignalScore += rsiScore;
      else if(rsiScore < 0) sellSignalScore += MathAbs(rsiScore);
   }
   
   //--- BB Strategy
   if(UseBBStrategy)
   {
      int bbScore = AnalyzeBBStrategy(buyReasons, sellReasons);
      if(bbScore > 0) buySignalScore += bbScore;
      else if(bbScore < 0) sellSignalScore += MathAbs(bbScore);
   }
   
   //--- MACD Strategy
   if(UseMACDStrategy)
   {
      int macdScore = AnalyzeMACDStrategy(buyReasons, sellReasons);
      if(macdScore > 0) buySignalScore += macdScore;
      else if(macdScore < 0) sellSignalScore += MathAbs(macdScore);
   }
   
   //--- Combine classical and quantum scores
   if(useQuantum)
   {
      // Weighted combination
      double classicalBuyScore = (double)buySignalScore;
      double classicalSellScore = (double)sellSignalScore;
      
      // Apply quantum weighting
      if(qSignal.direction == 1)  // Quantum says buy
      {
         buySignalScore = (int)((classicalBuyScore * (1-QuantumWeight)) + 
                                (quantumScore * QuantumWeight));
      }
      else if(qSignal.direction == -1)  // Quantum says sell
      {
         sellSignalScore = (int)((classicalSellScore * (1-QuantumWeight)) + 
                                 (quantumScore * QuantumWeight));
      }
   }
   
   //--- Check multi-timeframe confirmation
   bool mtfBuyConfirmed = true;
   bool mtfSellConfirmed = true;
   
   if(UseMultiTimeframe)
   {
      mtfBuyConfirmed = CheckMultiTimeframeConfirmation(true);
      mtfSellConfirmed = CheckMultiTimeframeConfirmation(false);
   }
   
   //--- Quantum multi-timeframe confirmation
   if(UseQuantumAnalysis && UseQuantumMTF)
   {
      bool quantumMTFConfirm = quantumPhaseEst.ConfirmTrendAcrossTimeframes(
         TimeFrame1, TimeFrame2, TimeFrame3);
      
      if(!quantumMTFConfirm)
      {
         Print("Quantum MTF analysis: No clear trend across timeframes");
         mtfBuyConfirmed = false;
         mtfSellConfirmed = false;
      }
   }
   
   //--- Execute trades based on signals
   if(buySignalScore >= MinSignalScore && mtfBuyConfirmed)
   {
      if(IsCooldownElapsed(true))
      {
         Print("=== BUY SIGNAL ===");
         Print("Combined Score: ", buySignalScore);
         Print("Quantum Enhanced: ", useQuantum ? "Yes" : "No");
         Print("Reasons: ", buyReasons);
         
         OpenTrade(ORDER_TYPE_BUY, buySignalScore, qSignal);
      }
   }
   else if(sellSignalScore >= MinSignalScore && mtfSellConfirmed)
   {
      if(IsCooldownElapsed(false))
      {
         Print("=== SELL SIGNAL ===");
         Print("Combined Score: ", sellSignalScore);
         Print("Quantum Enhanced: ", useQuantum ? "Yes" : "No");
         Print("Reasons: ", sellReasons);
         
         OpenTrade(ORDER_TYPE_SELL, sellSignalScore, qSignal);
      }
   }
}

//+------------------------------------------------------------------+
//| Strategy Analysis Functions (From V3 Base)                       |
//+------------------------------------------------------------------+
int AnalyzeMAStrategy(string &buyReasons, string &sellReasons)
{
   bool bullishCross = fastMA[1] > slowMA[1] && fastMA[2] <= slowMA[2];
   bool bearishCross = fastMA[1] < slowMA[1] && fastMA[2] >= slowMA[2];
   
   if(!bullishCross && !bearishCross) return 0;
   
   double maSlope = MathAbs(fastMA[1] - fastMA[2]) / pipSize;
   if(maSlope < MA_SlopeMinimum) return 0;
   
   int score = 30;
   
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

int AnalyzeRSIStrategy(string &buyReasons, string &sellReasons)
{
   double rsi = rsiBuffer[0];
   double rsiPrev = rsiBuffer[1];
   int score = 0;
   
   if(rsiPrev < RSI_Oversold && rsi > RSI_Oversold)
   {
      score = 25;
      buyReasons += "RSI Oversold Bounce | ";
   }
   
   if(rsiPrev > RSI_Overbought && rsi < RSI_Overbought)
   {
      score = -25;
      sellReasons += "RSI Overbought Fall | ";
   }
   
   return score;
}

int AnalyzeBBStrategy(string &buyReasons, string &sellReasons)
{
   double close = iClose(_Symbol, PERIOD_CURRENT, 0);
   double closePrev = iClose(_Symbol, PERIOD_CURRENT, 1);
   int score = 0;
   
   if(closePrev <= bbLower[1] && close > bbLower[0])
   {
      score = 25;
      buyReasons += "BB Lower Bounce | ";
   }
   
   if(closePrev >= bbUpper[1] && close < bbUpper[0])
   {
      score = -25;
      sellReasons += "BB Upper Fall | ";
   }
   
   return score;
}

int AnalyzeMACDStrategy(string &buyReasons, string &sellReasons)
{
   int score = 0;
   
   if(macdMain[1] > macdSignal[1] && macdMain[2] <= macdSignal[2])
   {
      score = 20;
      buyReasons += "MACD Bullish Cross | ";
   }
   
   if(macdMain[1] < macdSignal[1] && macdMain[2] >= macdSignal[2])
   {
      score = -20;
      sellReasons += "MACD Bearish Cross | ";
   }
   
   return score;
}

bool CheckMultiTimeframeConfirmation(bool isBuy)
{
   if(!UseMultiTimeframe || !UseMAStrategy) return true;
   
   double fastMA_TF1[], slowMA_TF1[], fastMA_TF2[], slowMA_TF2[], fastMA_TF3[], slowMA_TF3[];
   ArraySetAsSeries(fastMA_TF1, true); ArraySetAsSeries(slowMA_TF1, true);
   ArraySetAsSeries(fastMA_TF2, true); ArraySetAsSeries(slowMA_TF2, true);
   ArraySetAsSeries(fastMA_TF3, true); ArraySetAsSeries(slowMA_TF3, true);
   
   if(CopyBuffer(handleFastMA_TF1, 0, 0, 2, fastMA_TF1) < 2) return false;
   if(CopyBuffer(handleSlowMA_TF1, 0, 0, 2, slowMA_TF1) < 2) return false;
   if(CopyBuffer(handleFastMA_TF2, 0, 0, 2, fastMA_TF2) < 2) return false;
   if(CopyBuffer(handleSlowMA_TF2, 0, 0, 2, slowMA_TF2) < 2) return false;
   if(CopyBuffer(handleFastMA_TF3, 0, 0, 2, fastMA_TF3) < 2) return false;
   if(CopyBuffer(handleSlowMA_TF3, 0, 0, 2, slowMA_TF3) < 2) return false;
   
   int confirmations = 0;
   
   if(isBuy)
   {
      if(fastMA_TF1[0] > slowMA_TF1[0]) confirmations++;
      if(fastMA_TF2[0] > slowMA_TF2[0]) confirmations++;
      if(fastMA_TF3[0] > slowMA_TF3[0]) confirmations++;
   }
   else
   {
      if(fastMA_TF1[0] < slowMA_TF1[0]) confirmations++;
      if(fastMA_TF2[0] < slowMA_TF2[0]) confirmations++;
      if(fastMA_TF3[0] < slowMA_TF3[0]) confirmations++;
   }
   
   return (confirmations >= MinTFConfirmation);
}

//+------------------------------------------------------------------+
//| Open Trade with Quantum Enhancement                              |
//+------------------------------------------------------------------+
void OpenTrade(ENUM_ORDER_TYPE orderType, int signalScore, QuantumSignal &qSignal)
{
   double price = (orderType == ORDER_TYPE_BUY) ? 
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   //--- Calculate SL/TP
   double slPips = StopLossPips;
   double tpPips = TakeProfitPips;
   
   if(UseATRSizing && atrBuffer[0] > 0)
   {
      slPips = (atrBuffer[0] / pipSize) * ATR_SL_Multiplier;
      tpPips = (atrBuffer[0] / pipSize) * ATR_TP_Multiplier;
   }
   
   //--- Apply quantum adjustment to SL/TP
   if(UseQuantumAnalysis && UseQuantumRisk)
   {
      quantumRiskMgr.AdjustQuantumSLTP(slPips, tpPips);
   }
   
   double sl = (orderType == ORDER_TYPE_BUY) ? 
               price - slPips * pipSize : 
               price + slPips * pipSize;
   double tp = (orderType == ORDER_TYPE_BUY) ? 
               price + tpPips * pipSize : 
               price - tpPips * pipSize;
   
   sl = NormalizeDouble(sl, symbolDigits);
   tp = NormalizeDouble(tp, symbolDigits);
   
   //--- Calculate lot size
   double lotSize;
   
   if(UseFixedLot)
      lotSize = FixedLotSize;
   else if(UseQuantumAnalysis && UseQuantumRisk)
      lotSize = quantumRiskMgr.CalculateQuantumLotSize(slPips, accountInfo.Balance());
   else
      lotSize = CalculateLotSize(slPips);
   
   //--- Validate and place order
   if(!ValidateOrderParams(orderType, price, sl, tp))
      return;
   
   string comment = TradeComment + "_Q" + IntegerToString(quantumPerf.totalQuantumSignals);
   
   if(trade.PositionOpen(_Symbol, orderType, lotSize, price, sl, tp, comment))
   {
      Print("Trade opened successfully:");
      Print("  Type: ", orderType == ORDER_TYPE_BUY ? "BUY" : "SELL");
      Print("  Lot: ", lotSize);
      Print("  Price: ", price);
      Print("  SL: ", sl, " (", slPips, " pips)");
      Print("  TP: ", tp, " (", tpPips, " pips)");
      Print("  Signal Score: ", signalScore);
      if(UseQuantumAnalysis)
         Print("  Quantum Confidence: ", qSignal.confidence, "%");
      
      //--- Update state
      if(orderType == ORDER_TYPE_BUY)
         lastBuyTime = TimeCurrent();
      else
         lastSellTime = TimeCurrent();
      
      dailyTradeCount++;
      
      if(UseQuantumAnalysis)
         quantumPerf.totalQuantumSignals++;
   }
   else
   {
      Print("Trade failed: ", trade.ResultRetcodeDescription());
   }
}

double CalculateLotSize(double slPips)
{
   double balance = accountInfo.Balance();
   double riskAmount = balance * (BaseRiskPercent / 100.0);
   
   double pipValue = (pipSize / tickSize) * tickValue;
   double lotSize = riskAmount / (slPips * pipValue);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   if(lotSize < minLot) lotSize = minLot;
   if(lotSize > maxLot) lotSize = maxLot;
   if(lotSize > MaxLotSize) lotSize = MaxLotSize;
   
   return NormalizeDouble(lotSize, 2);
}

bool ValidateOrderParams(ENUM_ORDER_TYPE orderType, double price, double sl, double tp)
{
   double stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
   
   if(stopsLevel > 0)
   {
      double minDistance = stopsLevel * 1.5;
      
      if(orderType == ORDER_TYPE_BUY)
      {
         if(price - sl < minDistance || tp - price < minDistance)
         {
            Print("Order validation failed: stops too close");
            return false;
         }
      }
      else
      {
         if(sl - price < minDistance || price - tp < minDistance)
         {
            Print("Order validation failed: stops too close");
            return false;
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Filter and Management Functions                                   |
//+------------------------------------------------------------------+
bool IsSpreadAcceptable()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double spread = (ask - bid) / pipSize;
   
   return (spread <= MaxSpreadPips);
}

bool IsVolatilityAcceptable()
{
   if(!UseATRFilter) return true;
   
   double atr = atrBuffer[0];
   double atrPips = atr / pipSize;
   
   return (atrPips >= ATR_MinimumPips && atrPips <= ATR_MaximumPips);
}

bool IsTrendStrong()
{
   if(!UseADXFilter) return true;
   return (adxMain[0] >= ADX_Minimum);
}

bool CheckDrawdownLimit()
{
   double equity = accountInfo.Equity();
   double balance = accountInfo.Balance();
   
   if(balance <= 0) return false;
   
   double drawdownPercent = ((balance - equity) / balance) * 100.0;
   return (drawdownPercent <= MaxDrawdownPercent);
}

bool CanOpenNewTrade()
{
   if(dailyTradeCount >= MaxDailyTrades) return false;
   if(CountPositions() >= MaxConcurrentPositions) return false;
   if(!CheckPortfolioRisk()) return false;
   if(UseSessionFilter && !IsWithinTradingSession()) return false;
   
   return true;
}

int CountPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(positionInfo.SelectByIndex(i))
      {
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber)
            count++;
      }
   }
   return count;
}

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

double CalculatePositionRisk(ulong ticket)
{
   if(!positionInfo.SelectByTicket(ticket)) return 0;
   
   double openPrice = positionInfo.PriceOpen();
   double sl = positionInfo.StopLoss();
   double volume = positionInfo.Volume();
   
   if(sl == 0) return 0;
   
   double slDistance = MathAbs(openPrice - sl);
   double ticksDistance = slDistance / tickSize;
   
   return ticksDistance * tickValue * volume;
}

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

bool IsCooldownElapsed(bool isBuySignal)
{
   datetime relevantTime = SeparateCooldownByDirection ?
                          (isBuySignal ? lastBuyTime : lastSellTime) :
                          MathMax(lastBuyTime, lastSellTime);
   
   return (TimeCurrent() - relevantTime) >= (CooldownMinutes * 60);
}

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
//| Position Management                                               |
//+------------------------------------------------------------------+
void ManagePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!positionInfo.SelectByIndex(i)) continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber) continue;
      
      ulong ticket = positionInfo.Ticket();
      
      if(UseBreakeven)
         MoveToBreakeven(ticket);
      
      if(UsePartialTP)
         CheckPartialTP(ticket);
      
      if(UseTrailingStop)
         TrailStop(ticket);
   }
}

void MoveToBreakeven(ulong ticket)
{
   if(!positionInfo.SelectByTicket(ticket)) return;
   
   double openPrice = positionInfo.PriceOpen();
   double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY) ?
                        SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                        SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = positionInfo.StopLoss();
   
   double profitPips = MathAbs(currentPrice - openPrice) / pipSize;
   
   if(profitPips >= BreakevenTriggerPips)
   {
      double newSL;
      
      if(positionInfo.PositionType() == POSITION_TYPE_BUY)
      {
         newSL = openPrice + BreakevenOffsetPips * pipSize;
         if(sl >= newSL || sl == 0) return;
      }
      else
      {
         newSL = openPrice - BreakevenOffsetPips * pipSize;
         if(sl <= newSL && sl > 0) return;
      }
      
      newSL = NormalizeDouble(newSL, symbolDigits);
      trade.PositionModify(ticket, newSL, positionInfo.TakeProfit());
   }
}

void CheckPartialTP(ulong ticket)
{
   for(int i = 0; i < trackedPositionCount; i++)
   {
      if(trackedPositions[i].ticket == ticket && trackedPositions[i].partialTPDone)
         return;
   }
   
   if(!positionInfo.SelectByTicket(ticket)) return;
   
   double openPrice = positionInfo.PriceOpen();
   double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY) ?
                        SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                        SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   double profitPips = MathAbs(currentPrice - openPrice) / pipSize;
   
   if(profitPips >= PartialTP_Pips)
   {
      double currentVolume = positionInfo.Volume();
      double closeVolume = NormalizeDouble(currentVolume * (PartialTP_Percent / 100.0), 2);
      
      if(closeVolume >= minLot)
      {
         if(trade.PositionClosePartial(ticket, closeVolume))
         {
            Print("Partial TP executed: ", closeVolume, " lots closed");
            
            if(trackedPositionCount < 100)
            {
               trackedPositions[trackedPositionCount].ticket = ticket;
               trackedPositions[trackedPositionCount].partialTPDone = true;
               trackedPositionCount++;
            }
         }
      }
   }
}

void TrailStop(ulong ticket)
{
   if(!positionInfo.SelectByTicket(ticket)) return;
   
   double openPrice = positionInfo.PriceOpen();
   double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY) ?
                        SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                        SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = positionInfo.StopLoss();
   
   double profitPips = MathAbs(currentPrice - openPrice) / pipSize;
   
   if(profitPips < TrailingActivationPips) return;
   
   double trailingPips = TrailingStopPips;
   if(UseQuantumAnalysis && UseQuantumRisk)
      trailingPips = quantumRiskMgr.CalculateQuantumTrailingStop(trailingPips);
   
   double newSL;
   
   if(positionInfo.PositionType() == POSITION_TYPE_BUY)
   {
      newSL = currentPrice - trailingPips * pipSize;
      if(newSL > sl || sl == 0)
      {
         if(newSL - sl >= TrailingStepPips * pipSize || sl == 0)
         {
            newSL = NormalizeDouble(newSL, symbolDigits);
            trade.PositionModify(ticket, newSL, positionInfo.TakeProfit());
         }
      }
   }
   else
   {
      newSL = currentPrice + trailingPips * pipSize;
      if(newSL < sl || sl == 0)
      {
         if(sl - newSL >= TrailingStepPips * pipSize || sl == 0)
         {
            newSL = NormalizeDouble(newSL, symbolDigits);
            trade.PositionModify(ticket, newSL, positionInfo.TakeProfit());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Statistics and Helper Functions                                   |
//+------------------------------------------------------------------+
void InitializeStrategyStats()
{
   maStats.totalTrades = 0; maStats.winningTrades = 0; maStats.totalProfit = 0;
   rsiStats.totalTrades = 0; rsiStats.winningTrades = 0; rsiStats.totalProfit = 0;
   bbStats.totalTrades = 0; bbStats.winningTrades = 0; bbStats.totalProfit = 0;
   macdStats.totalTrades = 0; macdStats.winningTrades = 0; macdStats.totalProfit = 0;
   quantumStats.totalTrades = 0; quantumStats.winningTrades = 0; quantumStats.totalProfit = 0;
}

void UpdateStrategyStats(ulong positionId, double profit)
{
   quantumStats.totalTrades++;
   quantumStats.totalProfit += profit;
   if(profit > 0) quantumStats.winningTrades++;
   
   quantumStats.winRate = quantumStats.totalTrades > 0 ?
      (double)quantumStats.winningTrades / quantumStats.totalTrades * 100.0 : 0;
}

void UpdateQuantumStats(double profit)
{
   if(profit > 0)
      quantumPerf.quantumWins++;
   
   if(quantumPerf.totalQuantumSignals > 0)
   {
      double currentWinRate = (double)quantumPerf.quantumWins / quantumPerf.totalQuantumSignals * 100.0;
      if(currentWinRate > quantumPerf.bestWinRate)
         quantumPerf.bestWinRate = currentWinRate;
   }
   
   quantumPerf.lastUpdate = TimeCurrent();
}

void PrintStrategyPerformance()
{
   Print("=== Strategy Performance ===");
   Print("Total Trades: ", quantumStats.totalTrades);
   Print("Win Rate: ", NormalizeDouble(quantumStats.winRate, 2), "%");
   Print("Total Profit: $", NormalizeDouble(quantumStats.totalProfit, 2));
}

void PrintQuantumPerformance()
{
   if(!UseQuantumAnalysis) return;
   
   Print("=== Quantum Analysis Performance ===");
   Print("Total Quantum Signals: ", quantumPerf.totalQuantumSignals);
   Print("Quantum Wins: ", quantumPerf.quantumWins);
   
   if(quantumPerf.totalQuantumSignals > 0)
   {
      double winRate = (double)quantumPerf.quantumWins / quantumPerf.totalQuantumSignals * 100.0;
      Print("Quantum Win Rate: ", NormalizeDouble(winRate, 2), "%");
      Print("Best Win Rate: ", NormalizeDouble(quantumPerf.bestWinRate, 2), "%");
      Print("Target: 60-70% (IBM Quantum Enhanced)");
   }
}

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
