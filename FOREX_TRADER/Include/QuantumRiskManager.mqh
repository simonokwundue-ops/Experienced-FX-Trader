//+------------------------------------------------------------------+
//|                                        QuantumRiskManager.mqh    |
//|                    Quantum-Enhanced Risk Management              |
//|              Adaptive Risk Based on Quantum Confidence           |
//+------------------------------------------------------------------+
#property copyright "ForexTrader Quantum EA"
#property link      "https://github.com/simonokwundue-ops/Experienced-FX-Trader"
#property version   "1.00"
#property strict

#include "QuantumAnalysis.mqh"

//+------------------------------------------------------------------+
//| Quantum Risk Manager Class                                       |
//+------------------------------------------------------------------+
class CQuantumRiskManager
{
private:
   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   
   double m_baseRiskPercent;
   double m_minRiskPercent;
   double m_maxRiskPercent;
   double m_quantumRiskMultiplier;
   
   CQuantumPhaseEstimator *m_qpe;
   
public:
   //--- Constructor
   CQuantumRiskManager(string symbol, ENUM_TIMEFRAMES timeframe,
                      double baseRisk = 1.5, double minRisk = 0.5, 
                      double maxRisk = 3.0)
   {
      m_symbol = symbol;
      m_timeframe = timeframe;
      m_baseRiskPercent = baseRisk;
      m_minRiskPercent = minRisk;
      m_maxRiskPercent = maxRisk;
      m_quantumRiskMultiplier = 1.0;
      
      m_qpe = new CQuantumPhaseEstimator(symbol, timeframe);
   }
   
   //--- Destructor
   ~CQuantumRiskManager()
   {
      if(CheckPointer(m_qpe) == POINTER_DYNAMIC)
         delete m_qpe;
   }
   
   //--- Calculate quantum-adjusted risk percentage
   double CalculateQuantumRisk()
   {
      // Get quantum market state
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      // Base risk adjustment on quantum confidence and entropy
      double confidenceFactor = state.trendConfidence / 100.0;
      double entropyFactor = 1.0 - state.quantumEntropy;  // Lower entropy = higher confidence
      
      // Combine factors
      double quantumFactor = (confidenceFactor * 0.7 + entropyFactor * 0.3);
      
      // Apply to base risk
      double adjustedRisk = m_baseRiskPercent * quantumFactor * m_quantumRiskMultiplier;
      
      // Clamp to min/max bounds
      if(adjustedRisk < m_minRiskPercent)
         adjustedRisk = m_minRiskPercent;
      if(adjustedRisk > m_maxRiskPercent)
         adjustedRisk = m_maxRiskPercent;
      
      return adjustedRisk;
   }
   
   //--- Calculate position size based on quantum risk
   double CalculateQuantumLotSize(double stopLossPips, double accountBalance)
   {
      double riskPercent = CalculateQuantumRisk();
      double riskAmount = accountBalance * (riskPercent / 100.0);
      
      // Get symbol properties
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      
      double pipSize = (digits == 3 || digits == 5) ? point * 10 : point;
      
      double tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
      
      if(tickValue == 0)
      {
         double contractSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
         tickValue = tickSize * contractSize;
      }
      
      // Calculate lot size
      double pipValue = (pipSize / tickSize) * tickValue;
      double lotSize = riskAmount / (stopLossPips * pipValue);
      
      // Normalize lot size
      double minLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
      double lotStep = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
      
      lotSize = MathFloor(lotSize / lotStep) * lotStep;
      
      if(lotSize < minLot) lotSize = minLot;
      if(lotSize > maxLot) lotSize = maxLot;
      
      return NormalizeDouble(lotSize, 2);
   }
   
   //--- Adjust SL/TP based on quantum volatility prediction
   void AdjustQuantumSLTP(double &stopLossPips, double &takeProfitPips)
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      // If high entropy (uncertainty), widen stops
      if(state.quantumEntropy > 0.7)
      {
         stopLossPips *= 1.3;
         takeProfitPips *= 1.3;
      }
      // If low entropy (high certainty), can use tighter stops
      else if(state.quantumEntropy < 0.3 && state.isStrongTrend)
      {
         stopLossPips *= 0.9;
         takeProfitPips *= 1.2;  // Keep TP relatively larger
      }
      
      // Minimum SL protection
      if(stopLossPips < 20) stopLossPips = 20;
   }
   
   //--- Check if quantum conditions support trading
   bool QuantumConditionsValid()
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      // Don't trade in high uncertainty conditions
      if(state.quantumEntropy > 0.8)
      {
         Print("QuantumRisk: High entropy detected, skipping trade");
         return false;
      }
      
      // Require minimum confidence
      if(state.trendConfidence < 55.0)
      {
         Print("QuantumRisk: Insufficient quantum confidence");
         return false;
      }
      
      return true;
   }
   
   //--- Set quantum risk multiplier (for dynamic adjustment)
   void SetQuantumRiskMultiplier(double multiplier)
   {
      m_quantumRiskMultiplier = MathMax(0.5, MathMin(2.0, multiplier));
   }
   
   //--- Get current quantum state description
   string GetQuantumStateDescription()
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      return state.stateDescription;
   }
   
   //--- Calculate quantum-based profit target
   double CalculateQuantumProfitTarget(double entryPrice, int direction,
                                      double baseTPPips)
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      // Adjust TP based on quantum trend strength
      double tpMultiplier = 1.0;
      
      if(state.isStrongTrend)
      {
         tpMultiplier = 1.0 + (state.trendConfidence - 60) / 100.0;
         tpMultiplier = MathMin(tpMultiplier, 1.5);  // Cap at 1.5x
      }
      
      double adjustedTPPips = baseTPPips * tpMultiplier;
      
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      double pipSize = (digits == 3 || digits == 5) ? point * 10 : point;
      
      double tpPrice;
      if(direction > 0)  // Buy
         tpPrice = entryPrice + adjustedTPPips * pipSize;
      else  // Sell
         tpPrice = entryPrice - adjustedTPPips * pipSize;
      
      return NormalizeDouble(tpPrice, digits);
   }
   
   //--- Should use partial take profit based on quantum analysis
   bool ShouldUsePartialTP()
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      // Use partial TP in uncertain but trending conditions
      return (state.quantumEntropy > 0.4 && state.quantumEntropy < 0.7 && 
              state.trendConfidence > 55);
   }
   
   //--- Calculate quantum-based trailing stop distance
   double CalculateQuantumTrailingStop(double baseTrailingPips)
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      // Tighter trailing in strong trends
      if(state.isStrongTrend && state.quantumEntropy < 0.4)
         return baseTrailingPips * 0.8;
      
      // Wider trailing in uncertain conditions
      if(state.quantumEntropy > 0.6)
         return baseTrailingPips * 1.3;
      
      return baseTrailingPips;
   }
   
   //--- Evaluate trade quality score (0-100)
   double EvaluateTradeQuality(int direction)
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      double qualityScore = 0;
      
      // Direction alignment
      if((direction > 0 && state.dominantTrend == 1) ||
         (direction < 0 && state.dominantTrend == -1))
      {
         qualityScore += 40;  // Base score for aligned direction
      }
      else
      {
         return 0;  // Wrong direction = zero quality
      }
      
      // Confidence component (max 40 points)
      qualityScore += (state.trendConfidence / 100.0) * 40;
      
      // Entropy component (max 20 points, lower entropy = better)
      qualityScore += (1.0 - state.quantumEntropy) * 20;
      
      return MathMin(qualityScore, 100.0);
   }
   
   //--- Get recommended position hold time based on quantum analysis
   int GetRecommendedHoldTime()
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      // Strong trends suggest longer holds
      if(state.isStrongTrend && state.quantumEntropy < 0.4)
         return 240;  // 4 hours (in minutes)
      
      // Moderate conditions
      if(state.trendConfidence > 60)
         return 120;  // 2 hours
      
      // Uncertain conditions - shorter holds
      return 60;  // 1 hour
   }
   
   //--- Check if should avoid trading (extreme conditions)
   bool ShouldAvoidTrading()
   {
      QuantumMarketState state = m_qpe.AnalyzeMarketState();
      
      // Avoid in very high entropy (chaos)
      if(state.quantumEntropy > 0.85)
         return true;
      
      // Avoid when no clear trend and low confidence
      if(state.dominantTrend == 0 && state.trendConfidence < 50)
         return true;
      
      return false;
   }
};

//+------------------------------------------------------------------+
