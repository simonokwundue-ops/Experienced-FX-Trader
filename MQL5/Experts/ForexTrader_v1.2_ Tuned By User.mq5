//+------------------------------------------------------------------+
//|                                                      ForexTrader |
//|      Refactored for Smarter Entries and Safer Risk Management    |
//+------------------------------------------------------------------+
#property copyright "ForexTrader EA"
#property version   "2.1"

#include <Trade\Trade.mqh>
CTrade trade;

// === Input Parameters ===
input int      FastMA_Period = 10;
input int      SlowMA_Period = 50;
input ENUM_MA_METHOD MA_Method = MODE_EMA;
input ENUM_APPLIED_PRICE MA_Price = PRICE_CLOSE;

input double   RiskPercent = 2.0;
input double   StopLossPips = 40.0;
input double   TakeProfitPips = 80.0;
input bool     UseTrailingStop = true;
input double   TrailingStopPips = 30.0;
input double   TrailingStepPips = 10.0;
input double   TrailingActivationPips = 50.0;

input double   MaxLotSize = 10.0;
input double   MinLotSize = 0.01;
input bool     UseFixedLot = false;
input double   FixedLotSize = 0.1;

input bool     UseTradingHours = false;
input int      StartHour = 8;
input int      EndHour = 20;

input int      MagicNumber = 123456;
input string   TradeComment = "ForexTrader";
input int      Slippage = 10;
input int      CooldownMinutes = 15;
input bool     UseATRFilter = true;
input int      ATRPeriod = 14;
input double   ATRMinimumPips = 10.0;

// === Global Variables ===
double point, tickSize, tickValue, lotStep, minLot, maxLot;
double fastMA[], slowMA[], atrBuffer[];
int handleFastMA, handleSlowMA, handleATR;
datetime lastTradeTime = 0;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(Slippage);
   trade.SetTypeFilling(ORDER_FILLING_IOC);

   point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT, tickValue);
   if(tickValue == 0)
      tickValue = tickSize * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);

   lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   handleFastMA = iMA(_Symbol, PERIOD_CURRENT, FastMA_Period, 0, MA_Method, MA_Price);
   handleSlowMA = iMA(_Symbol, PERIOD_CURRENT, SlowMA_Period, 0, MA_Method, MA_Price);
   handleATR = iATR(_Symbol, PERIOD_CURRENT, ATRPeriod);

   if(handleFastMA == INVALID_HANDLE || handleSlowMA == INVALID_HANDLE || handleATR == INVALID_HANDLE)
      return INIT_FAILED;

   ArraySetAsSeries(fastMA, true);
   ArraySetAsSeries(slowMA, true);
   ArraySetAsSeries(atrBuffer, true);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Tick                                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   static datetime lastBar = 0;
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBar == lastBar) return;
   lastBar = currentBar;

   if(!UpdateIndicators()) return;
   if(UseTradingHours && !IsTradingTime()) return;

   ManagePositions();

   if(CountPositions() == 0 && IsCooldownElapsed())
      CheckEntrySignals();
}

//+------------------------------------------------------------------+
//| Update indicators                                                |
//+------------------------------------------------------------------+
bool UpdateIndicators()
{
   if(CopyBuffer(handleFastMA, 0, 0, 3, fastMA) < 3) return false;
   if(CopyBuffer(handleSlowMA, 0, 0, 3, slowMA) < 3) return false;
   if(CopyBuffer(handleATR, 0, 0, 1, atrBuffer) < 1) return false;
   return true;
}

//+------------------------------------------------------------------+
//| Trading Hours                                                    |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
   MqlDateTime tm; TimeToStruct(TimeCurrent(), tm);
   return (StartHour <= EndHour) ? (tm.hour >= StartHour && tm.hour < EndHour)
                                 : (tm.hour >= StartHour || tm.hour < EndHour);
}

//+------------------------------------------------------------------+
//| Entry Signal Logic                                               |
//+------------------------------------------------------------------+
void CheckEntrySignals()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double spread = ask - bid;
   double atr = atrBuffer[0];

   if(spread > (StopLossPips * point * 0.5)) return;
   if(UseATRFilter && atr < ATRMinimumPips * point) return;

   // Trend continuation logic
   if(fastMA[0] > slowMA[0] && fastMA[1] > slowMA[1] && fastMA[2] > slowMA[2])
      OpenBuyPosition(ask);

   if(fastMA[0] < slowMA[0] && fastMA[1] < slowMA[1] && fastMA[2] < slowMA[2])
      OpenSellPosition(bid);
}

//+------------------------------------------------------------------+
//| Buy/Sell Execution                                               |
//+------------------------------------------------------------------+
void OpenBuyPosition(double price)
{
   double sl = NormalizeDouble(price - StopLossPips * point, _Digits);
   double tp = NormalizeDouble(price + TakeProfitPips * point, _Digits);
   double lots = CalculateLotSize(price, sl);

   if(!ValidateTrade(sl, price)) return;

   for(int i = 0; i < 3; i++)
   {
      if(trade.Buy(lots, _Symbol, price, sl, tp, TradeComment))
      {
         lastTradeTime = TimeCurrent();
         Print("BUY placed. Lots: ", lots, " SL: ", sl, " TP: ", tp);
         return;
      }
      Sleep(1000);
   }
   Print("BUY failed. Error: ", GetLastError());
}

void OpenSellPosition(double price)
{
   double sl = NormalizeDouble(price + StopLossPips * point, _Digits);
   double tp = NormalizeDouble(price - TakeProfitPips * point, _Digits);
   double lots = CalculateLotSize(price, sl);

   if(!ValidateTrade(sl, price)) return;

   for(int i = 0; i < 3; i++)
   {
      if(trade.Sell(lots, _Symbol, price, sl, tp, TradeComment))
      {
         lastTradeTime = TimeCurrent();
         Print("SELL placed. Lots: ", lots, " SL: ", sl, " TP: ", tp);
         return;
      }
      Sleep(1000);
   }
   Print("SELL failed. Error: ", GetLastError());
}

//+------------------------------------------------------------------+
//| Trade Validity                                                   |
//+------------------------------------------------------------------+
bool ValidateTrade(double sl, double entry)
{
   double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
   if(MathAbs(sl - entry) < stopLevel)
   {
      Print("SL too close. Trade skipped.");
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Lot Size Calculation                                             |
//+------------------------------------------------------------------+
double CalculateLotSize(double entry, double stop)
{
   if(UseFixedLot) return FixedLotSize;

   double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100.0;
   double slDistance = MathAbs(entry - stop);
   if(slDistance == 0 || tickValue == 0) return MinLotSize;

   double ticks = slDistance / tickSize;
   double riskPerLot = ticks * tickValue;
   double lots = riskAmount / riskPerLot;

   if(lots < MinLotSize) lots = MinLotSize;
   if(lots > MaxLotSize) lots = MaxLotSize;

   return NormalizeLot(lots);
}

double NormalizeLot(double lots)
{
   lots = MathFloor(lots / lotStep) * lotStep;
   return NormalizeDouble(MathMax(minLot, MathMin(maxLot, lots)), 2);
}

//+------------------------------------------------------------------+
//| Count Positions                                                  |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Trailing Stop Logic                                              |
//+------------------------------------------------------------------+
void ManagePositions()
{
   if(!UseTrailingStop) return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double trailDistance = TrailingStopPips * point;
   double trailStep = TrailingStepPips * point;
   double activation = TrailingActivationPips * point;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;

      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber ||
         PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      double newSL = currentSL;

      if(type == POSITION_TYPE_BUY)
      {
         if(bid - openPrice < activation) continue;
         double trailPrice = bid - trailDistance;
         if(trailPrice > currentSL + trailStep && trailPrice > openPrice)
            newSL = NormalizeDouble(trailPrice, _Digits);
      }
      else if(type == POSITION_TYPE_SELL)
      {
         if(openPrice - ask < activation) continue;
         double trailPrice = ask + trailDistance;
         if(trailPrice < currentSL - trailStep && trailPrice < openPrice)
            newSL = NormalizeDouble(trailPrice, _Digits);
      }

      if(newSL != currentSL)
      {
         if(trade.PositionModify(ticket, newSL, currentTP))
            Print("Trailing SL updated. Ticket: ", ticket, " New SL: ", newSL);
         else
            Print("Trailing SL failed. Ticket: ", ticket, " Error: ", GetLastError());
      }
   }
}

//+------------------------------------------------------------------+
//| Cooldown                                                         |
//+------------------------------------------------------------------+
bool IsCooldownElapsed()
{
   return (TimeCurrent() - lastTradeTime >= CooldownMinutes * 60);
}
//+------------------------------------------------------------------+
