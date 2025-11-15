//+------------------------------------------------------------------+
//|                           QuantumForexTrader_Scalper.mq5          |
//|          Quantum-Enhanced Scalping EA - Fast Market Analysis     |
//|          Optimized for M1/M5 with Rapid Quantum Calculations     |
//+------------------------------------------------------------------+
#property copyright "ForexTrader Quantum EA v1.0 - Scalper"
#property link      "https://github.com/simonokwundue-ops/Experienced-FX-Trader"
#property version   "1.00"
#property description "Quantum scalping EA targeting quick profits"
#property description "Optimized for M1/M5 timeframes with fast quantum analysis"
#property description "Based on IBM Quantum theory adapted for scalping"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include "Include/QuantumSignals.mqh"
#include "Include/QuantumAnalysis.mqh"
#include "Include/BinaryEncoder.mqh"
#include "Include/QuantumRiskManager.mqh"

//--- Global Objects
CTrade trade;
CPositionInfo positionInfo;
CAccountInfo accountInfo;
CQuantumSignalGenerator *quantumSignalGen;
CQuantumPhaseEstimator *quantumPhaseEst;
CQuantumRiskManager *quantumRiskMgr;

//+------------------------------------------------------------------+
//| Input Parameters - Quantum Scalping Settings                     |
//+------------------------------------------------------------------+
input group "=== Quantum Scalping Settings ==="
input bool     UseQuantumAnalysis = true;     // Enable Quantum Analysis
input int      QuantumLookback = 100;          // Quantum Lookback (100 for scalping)
input int      QuantumHorizon = 5;             // Prediction Horizon (5 candles)
input double   QuantumConfidenceThreshold = 55.0;  // Min Confidence (%)
input double   QuantumWeight = 0.7;            // Quantum Weight (Higher for scalping)
input bool     UseQuantumRisk = true;          // Use Quantum Risk
input bool     FastQuantumMode = true;         // Fast Quantum Calculations

//+------------------------------------------------------------------+
//| Input Parameters - Scalping Strategy                             |
//+------------------------------------------------------------------+
input group "=== Scalping Strategy ==="
input bool     UseMAScalping = true;          // Use Fast MA Scalping
input bool     UseRSIScalping = true;         // Use RSI Scalping
input bool     UseBBScalping = true;          // Use BB Scalping
input int      MinSignalScore = 50;           // Min Signal Score (Lower for scalping)
input int      FastMA = 5;                    // Fast MA Period
input int      SlowMA = 20;                   // Slow MA Period
input int      RSI_Period = 9;                // RSI Period (Faster)
input int      BB_Period = 15;                // BB Period
input double   BB_Deviation = 2.0;            // BB Deviation

//+------------------------------------------------------------------+
//| Input Parameters - Scalping Position Management                  |
//+------------------------------------------------------------------+
input group "=== Scalping Position Management ==="
input double   ScalpTargetPips = 10.0;        // Scalp Target (Pips)
input double   ScalpStopLossPips = 15.0;      // Scalp Stop Loss (Pips)
input bool     UseQuickExit = true;           // Quick Exit on Signals
input bool     UseTimeBasedExit = true;       // Time-Based Exit
input int      MaxHoldMinutes = 30;           // Max Hold Time (Minutes)
input bool     UseTightBreakeven = true;      // Move to BE Quickly
input double   BreakevenTriggerPips = 5.0;    // Quick BE Trigger

//+------------------------------------------------------------------+
//| Input Parameters - Scalping Filters                              |
//+------------------------------------------------------------------+
input group "=== Scalping Filters ==="
input bool     UseSpreadFilter = true;        // Use Spread Filter
input double   MaxSpreadPips = 2.0;           // Max Spread (Tight for scalping)
input bool     UseVolatilityFilter = true;    // Use Volatility Filter
input int      ATR_Period = 10;               // ATR Period
input double   MinATRPips = 5.0;              // Min ATR
input double   MaxATRPips = 30.0;             // Max ATR (Lower for scalping)

//+------------------------------------------------------------------+
//| Input Parameters - Scalping Risk Management                      |
//+------------------------------------------------------------------+
input group "=== Scalping Risk Management ==="
input double   ScalpRiskPercent = 0.5;        // Risk Per Scalp (%)
input int      MaxDailyScalps = 50;           // Max Scalps Per Day
input int      MaxConcurrentScalps = 3;       // Max Concurrent Scalps
input int      ScalpCooldownSeconds = 60;     // Cooldown (Seconds)
input double   MaxDailyDrawdownPercent = 5.0; // Max Daily Drawdown (%)

//+------------------------------------------------------------------+
//| Input Parameters - Advanced Scalping                             |
//+------------------------------------------------------------------+
input group "=== Advanced Scalping Settings ==="
input int      MagicNumber = 345679;          // Magic Number (Scalper)
input string   TradeComment = "QuantumScalp"; // Trade Comment
input int      Slippage = 20;                 // Max Slippage
input bool     TradeOnlyHighActivity = true;  // Trade Only High Activity Hours
input int      HighActivityStartHour = 7;     // Activity Start (GMT)
input int      HighActivityEndHour = 16;      // Activity End (GMT)

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
int handleFastMA, handleSlowMA, handleRSI, handleBB, handleATR;
double fastMA[], slowMA[], rsiBuffer[], bbUpper[], bbLower[], atrBuffer[];
double point, pipSize, tickSize, tickValue, lotStep, minLot, maxLot;
int symbolDigits;

datetime lastTradeTime = 0;
int dailyScalpCount = 0;
datetime lastScalpDate = 0;
double sessionStartBalance = 0;

struct ScalpStats
{
   int totalScalps;
   int winningScalps;
   double totalProfit;
   double winRate;
   double avgHoldTime;
   int quantumScalps;
};

ScalpStats stats;

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(Slippage);
   trade.SetTypeFilling(ORDER_FILLING_IOC);
   trade.SetAsyncMode(false);
   
   point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   symbolDigits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   pipSize = (symbolDigits == 3 || symbolDigits == 5) ? point * 10 : point;
   
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
   
   if(UseQuantumAnalysis)
   {
      quantumSignalGen = new CQuantumSignalGenerator(_Symbol, PERIOD_CURRENT, 
                                                     QuantumLookback, QuantumHorizon);
      quantumSignalGen.SetConfidenceThreshold(QuantumConfidenceThreshold);
      quantumPhaseEst = new CQuantumPhaseEstimator(_Symbol, PERIOD_CURRENT);
      
      if(UseQuantumRisk)
         quantumRiskMgr = new CQuantumRiskManager(_Symbol, PERIOD_CURRENT,
                                                  ScalpRiskPercent, 0.3, 1.0);
      
      Print("Quantum scalping mode initialized");
   }
   
   if(UseMAScalping)
   {
      handleFastMA = iMA(_Symbol, PERIOD_CURRENT, FastMA, 0, MODE_EMA, PRICE_CLOSE);
      handleSlowMA = iMA(_Symbol, PERIOD_CURRENT, SlowMA, 0, MODE_EMA, PRICE_CLOSE);
      if(handleFastMA == INVALID_HANDLE || handleSlowMA == INVALID_HANDLE)
         return INIT_FAILED;
   }
   
   if(UseRSIScalping)
   {
      handleRSI = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
      if(handleRSI == INVALID_HANDLE)
         return INIT_FAILED;
   }
   
   if(UseBBScalping)
   {
      handleBB = iBands(_Symbol, PERIOD_CURRENT, BB_Period, 0, BB_Deviation, PRICE_CLOSE);
      if(handleBB == INVALID_HANDLE)
         return INIT_FAILED;
   }
   
   if(UseVolatilityFilter)
   {
      handleATR = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
      if(handleATR == INVALID_HANDLE)
         return INIT_FAILED;
   }
   
   ArraySetAsSeries(fastMA, true);
   ArraySetAsSeries(slowMA, true);
   ArraySetAsSeries(rsiBuffer, true);
   ArraySetAsSeries(bbUpper, true);
   ArraySetAsSeries(bbLower, true);
   ArraySetAsSeries(atrBuffer, true);
   
   stats.totalScalps = 0;
   stats.winningScalps = 0;
   stats.totalProfit = 0;
   stats.quantumScalps = 0;
   
   sessionStartBalance = accountInfo.Balance();
   
   Print("========================================");
   Print("QuantumForexTrader Scalper - Initialized");
   Print("Symbol: ", _Symbol);
   Print("Timeframe: ", EnumToString(PERIOD_CURRENT));
   Print("Quantum Mode: ", UseQuantumAnalysis ? "Enabled" : "Disabled");
   Print("Fast Quantum: ", FastQuantumMode ? "Yes" : "No");
   Print("Target: ", ScalpTargetPips, " pips | SL: ", ScalpStopLossPips, " pips");
   Print("Max Daily Scalps: ", MaxDailyScalps);
   Print("========================================");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(CheckPointer(quantumSignalGen) == POINTER_DYNAMIC) delete quantumSignalGen;
   if(CheckPointer(quantumPhaseEst) == POINTER_DYNAMIC) delete quantumPhaseEst;
   if(CheckPointer(quantumRiskMgr) == POINTER_DYNAMIC) delete quantumRiskMgr;
   
   if(handleFastMA != INVALID_HANDLE) IndicatorRelease(handleFastMA);
   if(handleSlowMA != INVALID_HANDLE) IndicatorRelease(handleSlowMA);
   if(handleRSI != INVALID_HANDLE) IndicatorRelease(handleRSI);
   if(handleBB != INVALID_HANDLE) IndicatorRelease(handleBB);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
   
   PrintScalpingStats();
   Print("QuantumForexTrader Scalper - Deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   
   if(currentBar == lastBar) return;
   lastBar = currentBar;
   
   ResetDailyScalpCount();
   
   if(!UpdateIndicators()) return;
   if(!CheckDailyDrawdown()) return;
   
   ManageScalpPositions();
   
   if(!CanOpenNewScalp()) return;
   if(TradeOnlyHighActivity && !IsHighActivityTime()) return;
   
   CheckScalpSignals();
}

//+------------------------------------------------------------------+
//| Update indicators                                                 |
//+------------------------------------------------------------------+
bool UpdateIndicators()
{
   if(UseMAScalping)
   {
      if(CopyBuffer(handleFastMA, 0, 0, 3, fastMA) < 3) return false;
      if(CopyBuffer(handleSlowMA, 0, 0, 3, slowMA) < 3) return false;
   }
   
   if(UseRSIScalping)
   {
      if(CopyBuffer(handleRSI, 0, 0, 3, rsiBuffer) < 3) return false;
   }
   
   if(UseBBScalping)
   {
      if(CopyBuffer(handleBB, 1, 0, 2, bbUpper) < 2) return false;
      if(CopyBuffer(handleBB, 2, 0, 2, bbLower) < 2) return false;
   }
   
   if(UseVolatilityFilter)
   {
      if(CopyBuffer(handleATR, 0, 0, 1, atrBuffer) < 1) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check scalp signals                                               |
//+------------------------------------------------------------------+
void CheckScalpSignals()
{
   if(UseSpreadFilter && !IsScalpSpreadOK()) return;
   if(UseVolatilityFilter && !IsScalpVolatilityOK()) return;
   
   QuantumSignal qSignal;
   double quantumScore = 0;
   bool hasQuantumSignal = false;
   
   if(UseQuantumAnalysis)
   {
      qSignal = quantumSignalGen.GenerateSignal();
      if(qSignal.isValid && qSignal.confidence >= QuantumConfidenceThreshold)
      {
         quantumScore = qSignal.confidence;
         hasQuantumSignal = true;
      }
   }
   
   int buyScore = 0;
   int sellScore = 0;
   
   if(UseMAScalping)
   {
      if(fastMA[0] > slowMA[0] && fastMA[1] <= slowMA[1])
         buyScore += 30;
      else if(fastMA[0] < slowMA[0] && fastMA[1] >= slowMA[1])
         sellScore += 30;
   }
   
   if(UseRSIScalping)
   {
      if(rsiBuffer[1] < 30 && rsiBuffer[0] > 30)
         buyScore += 25;
      else if(rsiBuffer[1] > 70 && rsiBuffer[0] < 70)
         sellScore += 25;
   }
   
   if(UseBBScalping)
   {
      double close = iClose(_Symbol, PERIOD_CURRENT, 0);
      double prevClose = iClose(_Symbol, PERIOD_CURRENT, 1);
      
      if(prevClose <= bbLower[1] && close > bbLower[0])
         buyScore += 25;
      else if(prevClose >= bbUpper[1] && close < bbUpper[0])
         sellScore += 25;
   }
   
   if(hasQuantumSignal)
   {
      if(qSignal.direction == 1)
         buyScore = (int)((buyScore * (1-QuantumWeight)) + (quantumScore * QuantumWeight));
      else if(qSignal.direction == -1)
         sellScore = (int)((sellScore * (1-QuantumWeight)) + (quantumScore * QuantumWeight));
   }
   
   if(buyScore >= MinSignalScore && IsScalpCooldownElapsed())
   {
      Print("SCALP BUY | Score: ", buyScore, " | Quantum: ", hasQuantumSignal ? "Yes" : "No");
      OpenScalp(ORDER_TYPE_BUY, hasQuantumSignal);
   }
   else if(sellScore >= MinSignalScore && IsScalpCooldownElapsed())
   {
      Print("SCALP SELL | Score: ", sellScore, " | Quantum: ", hasQuantumSignal ? "Yes" : "No");
      OpenScalp(ORDER_TYPE_SELL, hasQuantumSignal);
   }
}

//+------------------------------------------------------------------+
//| Open scalp position                                               |
//+------------------------------------------------------------------+
void OpenScalp(ENUM_ORDER_TYPE orderType, bool isQuantum)
{
   double price = (orderType == ORDER_TYPE_BUY) ? 
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double sl = (orderType == ORDER_TYPE_BUY) ? 
               price - ScalpStopLossPips * pipSize : 
               price + ScalpStopLossPips * pipSize;
   
   double tp = (orderType == ORDER_TYPE_BUY) ? 
               price + ScalpTargetPips * pipSize : 
               price - ScalpTargetPips * pipSize;
   
   sl = NormalizeDouble(sl, symbolDigits);
   tp = NormalizeDouble(tp, symbolDigits);
   
   double lotSize;
   if(UseQuantumRisk)
      lotSize = quantumRiskMgr.CalculateQuantumLotSize(ScalpStopLossPips, accountInfo.Balance());
   else
      lotSize = CalculateScalpLotSize();
   
   string comment = TradeComment + (isQuantum ? "_Q" : "");
   
   if(trade.PositionOpen(_Symbol, orderType, lotSize, price, sl, tp, comment))
   {
      Print("Scalp opened: ", orderType == ORDER_TYPE_BUY ? "BUY" : "SELL", 
            " | Lot: ", lotSize, " | TP: ", ScalpTargetPips, " pips");
      
      lastTradeTime = TimeCurrent();
      dailyScalpCount++;
      stats.totalScalps++;
      if(isQuantum) stats.quantumScalps++;
   }
}

double CalculateScalpLotSize()
{
   double balance = accountInfo.Balance();
   double riskAmount = balance * (ScalpRiskPercent / 100.0);
   double pipValue = (pipSize / tickSize) * tickValue;
   double lotSize = riskAmount / (ScalpStopLossPips * pipValue);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   if(lotSize < minLot) lotSize = minLot;
   if(lotSize > maxLot) lotSize = maxLot;
   
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Manage scalp positions                                            |
//+------------------------------------------------------------------+
void ManageScalpPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!positionInfo.SelectByIndex(i)) continue;
      if(positionInfo.Symbol() != _Symbol || positionInfo.Magic() != MagicNumber) continue;
      
      ulong ticket = positionInfo.Ticket();
      
      if(UseTightBreakeven)
         MoveScalpToBreakeven(ticket);
      
      if(UseTimeBasedExit)
         CheckTimeBasedExit(ticket);
      
      if(UseQuickExit)
         CheckQuickExit(ticket);
   }
}

void MoveScalpToBreakeven(ulong ticket)
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
      double newSL = openPrice;
      
      if(positionInfo.PositionType() == POSITION_TYPE_BUY)
      {
         if(sl >= newSL || sl == 0) return;
      }
      else
      {
         if(sl <= newSL && sl > 0) return;
      }
      
      newSL = NormalizeDouble(newSL, symbolDigits);
      trade.PositionModify(ticket, newSL, positionInfo.TakeProfit());
   }
}

void CheckTimeBasedExit(ulong ticket)
{
   if(!positionInfo.SelectByTicket(ticket)) return;
   
   datetime openTime = positionInfo.Time();
   int minutesOpen = (int)((TimeCurrent() - openTime) / 60);
   
   if(minutesOpen >= MaxHoldMinutes)
   {
      Print("Time-based exit: Position held for ", minutesOpen, " minutes");
      trade.PositionClose(ticket);
   }
}

void CheckQuickExit(ulong ticket)
{
   if(!positionInfo.SelectByTicket(ticket)) return;
   
   bool exitSignal = false;
   
   if(positionInfo.PositionType() == POSITION_TYPE_BUY)
   {
      if(UseMAScalping && fastMA[0] < slowMA[0])
         exitSignal = true;
      if(UseRSIScalping && rsiBuffer[0] > 70)
         exitSignal = true;
   }
   else
   {
      if(UseMAScalping && fastMA[0] > slowMA[0])
         exitSignal = true;
      if(UseRSIScalping && rsiBuffer[0] < 30)
         exitSignal = true;
   }
   
   if(exitSignal)
   {
      double openPrice = positionInfo.PriceOpen();
      double currentPrice = (positionInfo.PositionType() == POSITION_TYPE_BUY) ?
                           SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                           SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      if((currentPrice - openPrice) * (positionInfo.PositionType() == POSITION_TYPE_BUY ? 1 : -1) > 0)
      {
         Print("Quick exit: Opposite signal detected with profit");
         trade.PositionClose(ticket);
      }
   }
}

//+------------------------------------------------------------------+
//| Filter functions                                                  |
//+------------------------------------------------------------------+
bool IsScalpSpreadOK()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double spread = (ask - bid) / pipSize;
   return (spread <= MaxSpreadPips);
}

bool IsScalpVolatilityOK()
{
   double atr = atrBuffer[0];
   double atrPips = atr / pipSize;
   return (atrPips >= MinATRPips && atrPips <= MaxATRPips);
}

bool CanOpenNewScalp()
{
   if(dailyScalpCount >= MaxDailyScalps) return false;
   
   int openScalps = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(positionInfo.SelectByIndex(i))
      {
         if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber)
            openScalps++;
      }
   }
   
   return (openScalps < MaxConcurrentScalps);
}

bool IsScalpCooldownElapsed()
{
   return (TimeCurrent() - lastTradeTime) >= ScalpCooldownSeconds;
}

bool CheckDailyDrawdown()
{
   double currentEquity = accountInfo.Equity();
   double drawdown = ((sessionStartBalance - currentEquity) / sessionStartBalance) * 100.0;
   
   return (drawdown <= MaxDailyDrawdownPercent);
}

bool IsHighActivityTime()
{
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);
   int hour = tm.hour;
   
   return (hour >= HighActivityStartHour && hour < HighActivityEndHour);
}

void ResetDailyScalpCount()
{
   MqlDateTime currentTime, lastTime;
   TimeToStruct(TimeCurrent(), currentTime);
   TimeToStruct(lastScalpDate, lastTime);
   
   if(currentTime.day != lastTime.day || currentTime.mon != lastTime.mon || 
      currentTime.year != lastTime.year)
   {
      dailyScalpCount = 0;
      lastScalpDate = TimeCurrent();
      sessionStartBalance = accountInfo.Balance();
      
      if(stats.totalScalps > 0)
      {
         stats.winRate = (double)stats.winningScalps / stats.totalScalps * 100.0;
         PrintScalpingStats();
      }
   }
}

void PrintScalpingStats()
{
   Print("=== Scalping Performance ===");
   Print("Total Scalps: ", stats.totalScalps);
   Print("Winning Scalps: ", stats.winningScalps);
   Print("Win Rate: ", NormalizeDouble(stats.winRate, 2), "%");
   Print("Total Profit: $", NormalizeDouble(stats.totalProfit, 2));
   Print("Quantum Scalps: ", stats.quantumScalps);
   Print("Target Win Rate: 60-70%");
}

//+------------------------------------------------------------------+
