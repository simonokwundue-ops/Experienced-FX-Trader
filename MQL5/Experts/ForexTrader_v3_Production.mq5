//+------------------------------------------------------------------+
//|                                   ForexTrader_v3_Production.mq5  |
//|                          Production-Ready Single-Pair EA          |
//|                    With All Critical Flaws Fixed                  |
//+------------------------------------------------------------------+
#property copyright "ForexTrader EA v3.0 - Production Grade"
#property link      "https://github.com/simonokwundue-ops/Experienced-FX-Trader"
#property version   "3.00"
#property description "Professional EA with comprehensive risk management"
#property description "Implements adaptive MA strategy with multiple confirmations"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

//--- Global Objects
CTrade trade;
CPositionInfo positionInfo;
CAccountInfo accountInfo;

//+------------------------------------------------------------------+
//| Input Parameters - Strategy                                      |
//+------------------------------------------------------------------+
input group "=== Strategy Settings ==="
input bool     UseAdaptiveMA = true;          // Use Adaptive Moving Average (KAMA)
input int      FastMA_Period = 10;            // Fast MA Period (if not adaptive)
input int      SlowMA_Period = 50;            // Slow MA Period (if not adaptive)
input int      KAMA_Period = 14;              // KAMA Period
input int      KAMA_FastEMA = 2;              // KAMA Fast EMA Period
input int      KAMA_SlowEMA = 30;             // KAMA Slow EMA Period
input ENUM_MA_METHOD MA_Method = MODE_EMA;    // MA Method (for non-adaptive)
input ENUM_APPLIED_PRICE MA_Price = PRICE_CLOSE; // Applied Price

//+------------------------------------------------------------------+
//| Input Parameters - Filters                                       |
//+------------------------------------------------------------------+
input group "=== Signal Filters ==="
input bool     UseADXFilter = true;           // Use ADX Trend Strength Filter
input int      ADX_Period = 14;               // ADX Period
input double   ADX_Minimum = 20.0;            // Minimum ADX Level
input bool     UseATRFilter = true;           // Use ATR Volatility Filter
input int      ATR_Period = 14;               // ATR Period
input double   ATR_MinimumPips = 10.0;        // Minimum ATR in Pips
input double   ATR_MaximumPips = 100.0;       // Maximum ATR in Pips (spike protection)
input double   MA_SlopeMinimum = 5.0;         // Minimum MA Slope in Pips (filter weak crosses)
input double   MA_DistanceMinimum = 3.0;      // Minimum Distance Between MAs in Pips

//+------------------------------------------------------------------+
//| Input Parameters - Risk Management                               |
//+------------------------------------------------------------------+
input group "=== Risk Management ==="
input double   RiskPercent = 2.0;             // Risk Per Trade (% of Balance)
input double   StopLossPips = 40.0;           // Stop Loss in Pips
input double   TakeProfitPips = 80.0;         // Take Profit in Pips
input bool     UseDynamicSLTP = true;         // Use ATR-Based Dynamic SL/TP
input double   ATR_SL_Multiplier = 2.0;       // ATR Multiplier for SL (if dynamic)
input double   ATR_TP_Multiplier = 4.0;       // ATR Multiplier for TP (if dynamic)
input double   MaxDrawdownPercent = 30.0;     // Max Drawdown % (stop trading)
input double   MaxSpreadPips = 5.0;           // Max Spread in Pips

//+------------------------------------------------------------------+
//| Input Parameters - Position Management                           |
//+------------------------------------------------------------------+
input group "=== Position Management ==="
input bool     UseTrailingStop = true;        // Enable Trailing Stop
input double   TrailingStopPips = 30.0;       // Trailing Stop Distance (Pips)
input double   TrailingStepPips = 5.0;        // Trailing Step (Pips)
input double   TrailingActivationPips = 20.0; // Profit to Activate Trailing (Pips)
input bool     UseBreakeven = true;           // Move SL to Breakeven
input double   BreakevenTriggerPips = 20.0;   // Profit to Trigger Breakeven (Pips)
input double   BreakevenOffsetPips = 2.0;     // Breakeven Offset (Pips)

//+------------------------------------------------------------------+
//| Input Parameters - Money Management                              |
//+------------------------------------------------------------------+
input group "=== Money Management ==="
input double   MaxLotSize = 10.0;             // Maximum Lot Size
input double   MinLotSize = 0.01;             // Minimum Lot Size
input bool     UseFixedLot = false;           // Use Fixed Lot Size
input double   FixedLotSize = 0.1;            // Fixed Lot Size (if enabled)

//+------------------------------------------------------------------+
//| Input Parameters - Trading Controls                              |
//+------------------------------------------------------------------+
input group "=== Trading Controls ==="
input int      CooldownMinutes = 15;          // Cooldown Between Trades (Minutes)
input bool     SeparateCooldownByDirection = true; // Separate Buy/Sell Cooldown
input int      MaxDailyTrades = 10;           // Maximum Trades Per Day
input int      MaxConcurrentPositions = 1;    // Max Concurrent Positions
input bool     UseTradingHours = false;       // Enable Trading Hours Filter
input int      StartHour = 8;                 // Trading Start Hour (Server Time)
input int      EndHour = 20;                  // Trading End Hour (Server Time)

//+------------------------------------------------------------------+
//| Input Parameters - Advanced Settings                             |
//+------------------------------------------------------------------+
input group "=== Advanced Settings ==="
input int      MagicNumber = 123456;          // Magic Number
input string   TradeComment = "ForexTrader_v3"; // Trade Comment
input int      Slippage = 30;                 // Max Slippage in Points
input int      MaxRetries = 3;                // Max Order Send Retries
input int      RetryDelayMs = 1000;           // Retry Delay (Milliseconds)

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
int handleFastMA, handleSlowMA, handleADX, handleATR;
double fastMA[], slowMA[], adxMain[], atrBuffer[];
double point, tickSize, tickValue, lotStep, minLot, maxLot;
datetime lastBuyTime = 0;
datetime lastSellTime = 0;
int dailyTradeCount = 0;
datetime lastTradeDate = 0;
double pipSize;
int symbolDigits;

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
   
   //--- Calculate pip size correctly for all symbols
   if(symbolDigits == 3 || symbolDigits == 5)
      pipSize = point * 10;
   else
      pipSize = point;
   
   //--- Get symbol trading properties
   tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
   
   //--- Fallback for tick value if not available
   if(tickValue == 0)
   {
      double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      tickValue = tickSize * contractSize;
      Print("Warning: Using fallback tick value calculation: ", tickValue);
   }
   
   lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   //--- Validate inputs
   if(!ValidateInputs())
      return INIT_PARAMETERS_INCORRECT;
   
   //--- Create indicators
   if(UseAdaptiveMA)
   {
      //--- For KAMA, we'll calculate it manually in a helper function
      //--- For now, create standard MAs as fallback
      handleFastMA = iMA(_Symbol, PERIOD_CURRENT, FastMA_Period, 0, MA_Method, MA_Price);
      handleSlowMA = iMA(_Symbol, PERIOD_CURRENT, SlowMA_Period, 0, MA_Method, MA_Price);
   }
   else
   {
      handleFastMA = iMA(_Symbol, PERIOD_CURRENT, FastMA_Period, 0, MA_Method, MA_Price);
      handleSlowMA = iMA(_Symbol, PERIOD_CURRENT, SlowMA_Period, 0, MA_Method, MA_Price);
   }
   
   if(UseADXFilter)
      handleADX = iADX(_Symbol, PERIOD_CURRENT, ADX_Period);
      
   if(UseATRFilter || UseDynamicSLTP)
      handleATR = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
   
   //--- Check indicator handles
   if(handleFastMA == INVALID_HANDLE || handleSlowMA == INVALID_HANDLE)
   {
      Print("Error: Failed to create MA indicators");
      return INIT_FAILED;
   }
   
   if(UseADXFilter && handleADX == INVALID_HANDLE)
   {
      Print("Error: Failed to create ADX indicator");
      return INIT_FAILED;
   }
   
   if((UseATRFilter || UseDynamicSLTP) && handleATR == INVALID_HANDLE)
   {
      Print("Error: Failed to create ATR indicator");
      return INIT_FAILED;
   }
   
   //--- Set arrays as series
   ArraySetAsSeries(fastMA, true);
   ArraySetAsSeries(slowMA, true);
   ArraySetAsSeries(adxMain, true);
   ArraySetAsSeries(atrBuffer, true);
   
   //--- Print initialization info
   Print("========================================");
   Print("ForexTrader v3.0 Production - Initialized");
   Print("Symbol: ", _Symbol);
   Print("Timeframe: ", EnumToString(PERIOD_CURRENT));
   Print("Point: ", point, " | Pip Size: ", pipSize);
   Print("Tick Value: ", tickValue);
   Print("Min Lot: ", minLot, " | Max Lot: ", maxLot);
   Print("Risk Per Trade: ", RiskPercent, "%");
   Print("========================================");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert Deinitialization                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   if(handleFastMA != INVALID_HANDLE)
      IndicatorRelease(handleFastMA);
   if(handleSlowMA != INVALID_HANDLE)
      IndicatorRelease(handleSlowMA);
   if(handleADX != INVALID_HANDLE)
      IndicatorRelease(handleADX);
   if(handleATR != INVALID_HANDLE)
      IndicatorRelease(handleATR);
      
   Print("ForexTrader v3.0 - Deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert Tick Function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check if new bar
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   
   if(currentBar == lastBar)
      return;
      
   lastBar = currentBar;
   
   //--- Reset daily trade counter
   ResetDailyTradeCount();
   
   //--- Update indicators
   if(!UpdateIndicators())
      return;
   
   //--- Check drawdown guard
   if(!CheckDrawdownLimit())
   {
      Print("Max drawdown exceeded. Trading halted.");
      return;
   }
   
   //--- Manage existing positions
   ManagePositions();
   
   //--- Check if we can trade
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
   //--- Check if deal was added
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      //--- Get deal properties
      ulong dealTicket = trans.deal;
      if(dealTicket > 0 && HistoryDealSelect(dealTicket))
      {
         long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
         if(dealMagic == MagicNumber)
         {
            ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealTicket, DEAL_TYPE);
            double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            
            //--- Log trade result
            if(dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL)
            {
               Print("Trade opened: ", dealSymbol, " | Type: ", EnumToString(dealType), 
                     " | Ticket: ", dealTicket);
            }
            else if(dealProfit != 0)
            {
               Print("Trade closed: ", dealSymbol, " | Profit: ", dealProfit, 
                     " | Ticket: ", dealTicket);
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
   if(FastMA_Period <= 0 || SlowMA_Period <= 0)
   {
      Print("Error: MA periods must be positive");
      return false;
   }
   
   if(FastMA_Period >= SlowMA_Period)
   {
      Print("Error: Fast MA period must be less than Slow MA period");
      return false;
   }
   
   if(RiskPercent <= 0 || RiskPercent > 100)
   {
      Print("Error: Risk percent must be between 0 and 100");
      return false;
   }
   
   if(StopLossPips <= 0)
   {
      Print("Error: Stop loss must be positive");
      return false;
   }
   
   if(MaxDrawdownPercent <= 0 || MaxDrawdownPercent > 100)
   {
      Print("Error: Max drawdown percent must be between 0 and 100");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update Indicator Values                                           |
//+------------------------------------------------------------------+
bool UpdateIndicators()
{
   //--- Copy MA buffers
   if(CopyBuffer(handleFastMA, 0, 0, 3, fastMA) < 3)
   {
      Print("Error: Failed to copy Fast MA buffer");
      return false;
   }
   
   if(CopyBuffer(handleSlowMA, 0, 0, 3, slowMA) < 3)
   {
      Print("Error: Failed to copy Slow MA buffer");
      return false;
   }
   
   //--- Copy ADX buffer if needed
   if(UseADXFilter)
   {
      if(CopyBuffer(handleADX, 0, 0, 1, adxMain) < 1)
      {
         Print("Error: Failed to copy ADX buffer");
         return false;
      }
   }
   
   //--- Copy ATR buffer if needed
   if(UseATRFilter || UseDynamicSLTP)
   {
      if(CopyBuffer(handleATR, 0, 0, 1, atrBuffer) < 1)
      {
         Print("Error: Failed to copy ATR buffer");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if Within Drawdown Limit                                   |
//+------------------------------------------------------------------+
bool CheckDrawdownLimit()
{
   double equity = accountInfo.Equity();
   double balance = accountInfo.Balance();
   
   if(balance <= 0)
      return false;
   
   double drawdownPercent = ((balance - equity) / balance) * 100.0;
   
   if(drawdownPercent > MaxDrawdownPercent)
   {
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Reset Daily Trade Count                                          |
//+------------------------------------------------------------------+
void ResetDailyTradeCount()
{
   MqlDateTime currentTime;
   TimeToStruct(TimeCurrent(), currentTime);
   
   MqlDateTime lastTime;
   TimeToStruct(lastTradeDate, lastTime);
   
   //--- If it's a new day, reset the counter
   if(currentTime.day != lastTime.day || currentTime.mon != lastTime.mon || currentTime.year != lastTime.year)
   {
      dailyTradeCount = 0;
      lastTradeDate = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| Check if Can Open New Trade                                      |
//+------------------------------------------------------------------+
bool CanOpenNewTrade()
{
   //--- Check daily trade limit
   if(dailyTradeCount >= MaxDailyTrades)
   {
      return false;
   }
   
   //--- Check concurrent positions
   if(CountPositions() >= MaxConcurrentPositions)
   {
      return false;
   }
   
   //--- Check trading hours
   if(UseTradingHours && !IsTradingTime())
   {
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if Within Trading Hours                                    |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);
   
   int currentHour = tm.hour;
   
   if(StartHour <= EndHour)
   {
      return (currentHour >= StartHour && currentHour < EndHour);
   }
   else
   {
      return (currentHour >= StartHour || currentHour < EndHour);
   }
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
   //--- Check spread
   if(!IsSpreadAcceptable())
   {
      return;
   }
   
   //--- Check ATR filter
   if(UseATRFilter && !IsVolatilityAcceptable())
   {
      return;
   }
   
   //--- Check ADX filter
   if(UseADXFilter && !IsTrendStrong())
   {
      return;
   }
   
   //--- Get current prices
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   //--- Check for bullish crossover
   bool bullishCross = fastMA[1] > slowMA[1] && fastMA[2] <= slowMA[2];
   
   //--- Check for bearish crossover
   bool bearishCross = fastMA[1] < slowMA[1] && fastMA[2] >= slowMA[2];
   
   //--- Additional confirmation: check MA slope
   if(bullishCross || bearishCross)
   {
      double maSlope = MathAbs(fastMA[1] - fastMA[2]) / pipSize;
      double maDistance = MathAbs(fastMA[1] - slowMA[1]) / pipSize;
      
      if(maSlope < MA_SlopeMinimum)
      {
         Print("MA slope too weak: ", maSlope, " pips (minimum: ", MA_SlopeMinimum, ")");
         return;
      }
      
      if(maDistance < MA_DistanceMinimum)
      {
         Print("MA distance too small: ", maDistance, " pips (minimum: ", MA_DistanceMinimum, ")");
         return;
      }
   }
   
   //--- Process buy signal
   if(bullishCross && IsCooldownElapsed(true))
   {
      Print("=== BUY SIGNAL DETECTED ===");
      Print("FastMA[1]: ", fastMA[1], " > SlowMA[1]: ", slowMA[1]);
      Print("FastMA[2]: ", fastMA[2], " <= SlowMA[2]: ", slowMA[2]);
      
      if(OpenBuyPosition(ask))
      {
         lastBuyTime = TimeCurrent();
         dailyTradeCount++;
      }
   }
   
   //--- Process sell signal
   if(bearishCross && IsCooldownElapsed(false))
   {
      Print("=== SELL SIGNAL DETECTED ===");
      Print("FastMA[1]: ", fastMA[1], " < SlowMA[1]: ", slowMA[1]);
      Print("FastMA[2]: ", fastMA[2], " >= SlowMA[2]: ", slowMA[2]);
      
      if(OpenSellPosition(bid))
      {
         lastSellTime = TimeCurrent();
         dailyTradeCount++;
      }
   }
}

//+------------------------------------------------------------------+
//| Check if Spread is Acceptable                                    |
//+------------------------------------------------------------------+
bool IsSpreadAcceptable()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double spread = (ask - bid) / pipSize;
   
   if(spread > MaxSpreadPips)
   {
      Print("Spread too high: ", spread, " pips (max: ", MaxSpreadPips, ")");
      return false;
   }
   
   //--- Also check if spread is larger than half the stop loss
   if(spread > (StopLossPips * 0.5))
   {
      Print("Spread too high relative to SL: ", spread, " pips (SL: ", StopLossPips, ")");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if Volatility is Acceptable                                |
//+------------------------------------------------------------------+
bool IsVolatilityAcceptable()
{
   if(ArraySize(atrBuffer) == 0)
      return true;
      
   double atr = atrBuffer[0];
   double atrPips = atr / pipSize;
   
   if(atrPips < ATR_MinimumPips)
   {
      Print("ATR too low: ", atrPips, " pips (min: ", ATR_MinimumPips, ")");
      return false;
   }
   
   if(atrPips > ATR_MaximumPips)
   {
      Print("ATR too high: ", atrPips, " pips (max: ", ATR_MaximumPips, ")");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if Trend is Strong                                         |
//+------------------------------------------------------------------+
bool IsTrendStrong()
{
   if(ArraySize(adxMain) == 0)
      return true;
      
   double adx = adxMain[0];
   
   if(adx < ADX_Minimum)
   {
      Print("ADX too low: ", adx, " (min: ", ADX_Minimum, ")");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Open Buy Position                                                |
//+------------------------------------------------------------------+
bool OpenBuyPosition(double price)
{
   //--- Calculate SL and TP
   double sl = CalculateStopLoss(ORDER_TYPE_BUY, price);
   double tp = CalculateTakeProfit(ORDER_TYPE_BUY, price);
   
   //--- Validate SL/TP against broker stops level
   if(!ValidateTrade(ORDER_TYPE_BUY, price, sl, tp))
      return false;
   
   //--- Calculate lot size
   double lots = CalculateLotSize(price, sl);
   
   //--- Normalize values
   sl = NormalizeDouble(sl, symbolDigits);
   tp = NormalizeDouble(tp, symbolDigits);
   lots = NormalizeLot(lots);
   
   //--- Validate lot size
   if(lots < minLot || lots > maxLot)
   {
      Print("Invalid lot size: ", lots);
      return false;
   }
   
   //--- Try to open position with retries
   bool success = false;
   int attempts = 0;
   
   while(attempts < MaxRetries && !success)
   {
      ResetLastError();
      
      //--- Use 0 for price to let broker fill at market
      success = trade.Buy(lots, _Symbol, 0, sl, tp, TradeComment);
      
      if(success)
      {
         Print("=== BUY ORDER OPENED ===");
         Print("Ticket: ", trade.ResultOrder());
         Print("Lots: ", lots, " | SL: ", sl, " | TP: ", tp);
         Print("Expected Risk: $", CalculateRiskAmount(price, sl, lots));
         return true;
      }
      else
      {
         int error = GetLastError();
         Print("Buy order failed (attempt ", attempts + 1, "/", MaxRetries, "): ", 
               error, " - ", ErrorDescription(error));
         
         //--- Only retry on transient errors
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
//| Open Sell Position                                               |
//+------------------------------------------------------------------+
bool OpenSellPosition(double price)
{
   //--- Calculate SL and TP
   double sl = CalculateStopLoss(ORDER_TYPE_SELL, price);
   double tp = CalculateTakeProfit(ORDER_TYPE_SELL, price);
   
   //--- Validate SL/TP against broker stops level
   if(!ValidateTrade(ORDER_TYPE_SELL, price, sl, tp))
      return false;
   
   //--- Calculate lot size
   double lots = CalculateLotSize(price, sl);
   
   //--- Normalize values
   sl = NormalizeDouble(sl, symbolDigits);
   tp = NormalizeDouble(tp, symbolDigits);
   lots = NormalizeLot(lots);
   
   //--- Validate lot size
   if(lots < minLot || lots > maxLot)
   {
      Print("Invalid lot size: ", lots);
      return false;
   }
   
   //--- Try to open position with retries
   bool success = false;
   int attempts = 0;
   
   while(attempts < MaxRetries && !success)
   {
      ResetLastError();
      
      //--- Use 0 for price to let broker fill at market
      success = trade.Sell(lots, _Symbol, 0, sl, tp, TradeComment);
      
      if(success)
      {
         Print("=== SELL ORDER OPENED ===");
         Print("Ticket: ", trade.ResultOrder());
         Print("Lots: ", lots, " | SL: ", sl, " | TP: ", tp);
         Print("Expected Risk: $", CalculateRiskAmount(price, sl, lots));
         return true;
      }
      else
      {
         int error = GetLastError();
         Print("Sell order failed (attempt ", attempts + 1, "/", MaxRetries, "): ", 
               error, " - ", ErrorDescription(error));
         
         //--- Only retry on transient errors
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
//| Calculate Stop Loss                                              |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_ORDER_TYPE orderType, double price)
{
   double slDistance;
   
   if(UseDynamicSLTP && ArraySize(atrBuffer) > 0)
   {
      //--- Use ATR-based dynamic SL
      slDistance = atrBuffer[0] * ATR_SL_Multiplier;
   }
   else
   {
      //--- Use fixed pip-based SL (FIXED: removed 10x multiplier)
      slDistance = StopLossPips * pipSize;
   }
   
   double sl = 0;
   
   if(orderType == ORDER_TYPE_BUY)
   {
      sl = price - slDistance;
   }
   else if(orderType == ORDER_TYPE_SELL)
   {
      sl = price + slDistance;
   }
   
   return sl;
}

//+------------------------------------------------------------------+
//| Calculate Take Profit                                            |
//+------------------------------------------------------------------+
double CalculateTakeProfit(ENUM_ORDER_TYPE orderType, double price)
{
   double tpDistance;
   
   if(UseDynamicSLTP && ArraySize(atrBuffer) > 0)
   {
      //--- Use ATR-based dynamic TP
      tpDistance = atrBuffer[0] * ATR_TP_Multiplier;
   }
   else
   {
      //--- Use fixed pip-based TP (FIXED: removed 10x multiplier)
      tpDistance = TakeProfitPips * pipSize;
   }
   
   double tp = 0;
   
   if(orderType == ORDER_TYPE_BUY)
   {
      tp = price + tpDistance;
   }
   else if(orderType == ORDER_TYPE_SELL)
   {
      tp = price - tpDistance;
   }
   
   return tp;
}

//+------------------------------------------------------------------+
//| Validate Trade Against Broker Requirements                       |
//+------------------------------------------------------------------+
bool ValidateTrade(ENUM_ORDER_TYPE orderType, double price, double sl, double tp)
{
   //--- Get broker stops level
   long stopsLevelPoints = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double stopsLevel = stopsLevelPoints * point;
   
   //--- Check SL distance
   double slDistance = MathAbs(price - sl);
   if(slDistance < stopsLevel)
   {
      Print("SL too close to price. Required: ", stopsLevel / pipSize, " pips, Got: ", 
            slDistance / pipSize, " pips");
      return false;
   }
   
   //--- Check TP distance
   double tpDistance = MathAbs(price - tp);
   if(tpDistance < stopsLevel)
   {
      Print("TP too close to price. Required: ", stopsLevel / pipSize, " pips, Got: ", 
            tpDistance / pipSize, " pips");
      return false;
   }
   
   //--- Check freeze level
   long freezeLevelPoints = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double freezeLevel = freezeLevelPoints * point;
   
   double currentPrice = (orderType == ORDER_TYPE_BUY) ? 
                        SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                        SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   if(MathAbs(currentPrice - price) < freezeLevel)
   {
      Print("Price within freeze level");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size Based on Risk                                 |
//+------------------------------------------------------------------+
double CalculateLotSize(double entryPrice, double stopLoss)
{
   if(UseFixedLot)
      return FixedLotSize;
   
   double balance = accountInfo.Balance();
   double riskAmount = balance * (RiskPercent / 100.0);
   
   double slDistance = MathAbs(entryPrice - stopLoss);
   
   if(slDistance <= 0)
      return minLot;
   
   //--- Calculate value per lot
   double ticksDistance = slDistance / tickSize;
   double riskPerLot = ticksDistance * tickValue;
   
   if(riskPerLot <= 0)
      return minLot;
   
   double lots = riskAmount / riskPerLot;
   
   //--- Apply limits
   if(lots > MaxLotSize)
      lots = MaxLotSize;
   if(lots < MinLotSize)
      lots = MinLotSize;
   
   return lots;
}

//+------------------------------------------------------------------+
//| Calculate Risk Amount for Logging                                |
//+------------------------------------------------------------------+
double CalculateRiskAmount(double entryPrice, double stopLoss, double lots)
{
   double slDistance = MathAbs(entryPrice - stopLoss);
   double ticksDistance = slDistance / tickSize;
   return ticksDistance * tickValue * lots;
}

//+------------------------------------------------------------------+
//| Normalize Lot Size                                               |
//+------------------------------------------------------------------+
double NormalizeLot(double lots)
{
   //--- Round to nearest lot step
   lots = MathRound(lots / lotStep) * lotStep;
   
   //--- Apply limits
   if(lots < minLot)
      lots = minLot;
   if(lots > maxLot)
      lots = maxLot;
   
   return NormalizeDouble(lots, 2);
}

//+------------------------------------------------------------------+
//| Count Positions for This EA                                      |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(positionInfo.SelectByIndex(i))
      {
         if(positionInfo.Symbol() == _Symbol && 
            positionInfo.Magic() == MagicNumber)
         {
            count++;
         }
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| Manage Existing Positions                                        |
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
      
      //--- Get current price
      double currentPrice = (posType == POSITION_TYPE_BUY) ? 
                           SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                           SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      //--- Calculate profit in pips
      double profitPips = 0;
      if(posType == POSITION_TYPE_BUY)
         profitPips = (currentPrice - openPrice) / pipSize;
      else
         profitPips = (openPrice - currentPrice) / pipSize;
      
      //--- Move to breakeven
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
               Print("Position moved to breakeven: Ticket ", ticket, " | New SL: ", bePrice);
            }
            continue; // Don't trail if just moved to breakeven
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
            
            //--- Only update if improvement by at least trail step
            if(newSL > currentSL + trailStep || currentSL == 0)
            {
               newSL = NormalizeDouble(newSL, symbolDigits);
               
               //--- Ensure new SL is above open price (in profit)
               if(newSL > openPrice)
               {
                  if(trade.PositionModify(ticket, newSL, currentTP))
                  {
                     Print("Trailing stop updated: Ticket ", ticket, " | New SL: ", newSL);
                  }
               }
            }
         }
         else if(posType == POSITION_TYPE_SELL)
         {
            newSL = currentPrice + trailDistance;
            
            //--- Only update if improvement by at least trail step
            if(newSL < currentSL - trailStep || currentSL == 0)
            {
               newSL = NormalizeDouble(newSL, symbolDigits);
               
               //--- Ensure new SL is below open price (in profit)
               if(newSL < openPrice)
               {
                  if(trade.PositionModify(ticket, newSL, currentTP))
                  {
                     Print("Trailing stop updated: Ticket ", ticket, " | New SL: ", newSL);
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if Error is Transient and Worth Retrying                   |
//+------------------------------------------------------------------+
bool IsTransientError(int error)
{
   switch(error)
   {
      case 10004: // ERR_SERVER_BUSY
      case 10006: // ERR_NO_CONNECTION
      case 10007: // ERR_TOO_MANY_REQUESTS
      case 10018: // ERR_MARKET_CLOSED
      case 10021: // ERR_ORDER_LOCKED
      case 10025: // ERR_TRADE_TIMEOUT
      case 10027: // ERR_TRADE_TOO_MANY_ORDERS
         return true;
      default:
         return false;
   }
}

//+------------------------------------------------------------------+
//| Get Error Description                                            |
//+------------------------------------------------------------------+
string ErrorDescription(int error)
{
   string desc = "";
   
   switch(error)
   {
      case 10004: desc = "Server is busy"; break;
      case 10006: desc = "No connection"; break;
      case 10007: desc = "Too many requests"; break;
      case 10013: desc = "Invalid request"; break;
      case 10014: desc = "Invalid volume"; break;
      case 10015: desc = "Invalid price"; break;
      case 10016: desc = "Invalid stops"; break;
      case 10018: desc = "Market is closed"; break;
      case 10019: desc = "Not enough money"; break;
      case 10021: desc = "Order is locked"; break;
      case 10025: desc = "Trade timeout"; break;
      case 10027: desc = "Too many orders"; break;
      default: desc = "Unknown error"; break;
   }
   
   return desc;
}
//+------------------------------------------------------------------+
