//+------------------------------------------------------------------+
//|                                              QuantumSignals.mqh   |
//|                        Quantum Forex Trader Support Library      |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Quantum Forex Trader"
#property link      ""
#property version   "1.00"
#property strict

#include "QuantumAnalysis.mqh"

//+------------------------------------------------------------------+
//| Quantum Signal Structure                                         |
//+------------------------------------------------------------------+
struct QuantumSignal
{
    int type;              // 0=None, 1=Buy, -1=Sell
    double confidence;
    double momentum;
    string trend;
    datetime timestamp;
};

//+------------------------------------------------------------------+
//| Quantum Signal Generator Class                                   |
//| Generates trading signals based on quantum market analysis      |
//+------------------------------------------------------------------+
class CQuantumSignalGenerator
{
private:
    CQuantumPhaseEstimator m_qpe;
    int m_historyBars;
    double m_confidenceThreshold;
    double m_momentumThreshold;
    
public:
    CQuantumSignalGenerator() : 
        m_historyBars(256),
        m_confidenceThreshold(0.03),
        m_momentumThreshold(0.1)
    {
    }
    
    ~CQuantumSignalGenerator() {}
    
    //+------------------------------------------------------------------+
    //| Set parameters                                                   |
    //+------------------------------------------------------------------+
    void SetHistoryBars(int bars) { m_historyBars = bars; }
    void SetConfidenceThreshold(double threshold) { m_confidenceThreshold = threshold; }
    void SetMomentumThreshold(double threshold) { m_momentumThreshold = threshold; }
    
    //+------------------------------------------------------------------+
    //| Generate trading signal                                          |
    //+------------------------------------------------------------------+
    QuantumSignal GenerateSignal(const string symbol, const ENUM_TIMEFRAMES timeframe)
    {
        QuantumSignal signal;
        signal.type = 0;
        signal.confidence = 0.0;
        signal.momentum = 0.0;
        signal.trend = "NEUTRAL";
        signal.timestamp = TimeCurrent();
        
        // Get historical price data
        double prices[];
        ArraySetAsSeries(prices, true);
        
        int copied = CopyClose(symbol, timeframe, 0, m_historyBars, prices);
        
        if(copied < m_historyBars)
        {
            Print("Warning: Only copied ", copied, " bars, expected ", m_historyBars);
            if(copied < 50)
                return signal;
        }
        
        // Reverse array to have oldest first
        ArraySetAsSeries(prices, false);
        
        // Perform quantum analysis
        QuantumMarketState state = m_qpe.AnalyzeMarketState(prices, copied);
        
        signal.confidence = state.confidence;
        signal.momentum = state.momentum;
        signal.trend = state.trend;
        
        // Calculate additional momentum
        double recentMomentum = m_qpe.CalculateMomentum(prices, copied, 20);
        
        // Generate signal based on quantum state
        if(state.trend == "BULL" && 
           state.confidence >= m_confidenceThreshold && 
           state.momentum >= m_momentumThreshold)
        {
            signal.type = 1; // Buy signal
        }
        else if(state.trend == "BEAR" && 
                state.confidence >= m_confidenceThreshold && 
                state.momentum >= m_momentumThreshold)
        {
            signal.type = -1; // Sell signal
        }
        
        return signal;
    }
    
    //+------------------------------------------------------------------+
    //| Get detailed signal information                                  |
    //+------------------------------------------------------------------+
    string GetSignalInfo(const QuantumSignal &signal)
    {
        string info = "";
        info += "Signal Type: ";
        
        if(signal.type == 1)
            info += "BUY";
        else if(signal.type == -1)
            info += "SELL";
        else
            info += "NONE";
        
        info += "\n";
        info += StringFormat("Confidence: %.4f%%\n", signal.confidence * 100);
        info += StringFormat("Momentum: %.4f\n", signal.momentum);
        info += "Trend: " + signal.trend + "\n";
        info += "Time: " + TimeToString(signal.timestamp, TIME_DATE|TIME_MINUTES);
        
        return info;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate signal strength (0-100)                                |
    //+------------------------------------------------------------------+
    double CalculateSignalStrength(const QuantumSignal &signal)
    {
        double strength = 0.0;
        
        // Base strength from confidence
        strength += signal.confidence * 50.0;
        
        // Add momentum component
        strength += MathAbs(signal.momentum) * 50.0;
        
        // Cap at 100
        if(strength > 100.0)
            strength = 100.0;
        
        return strength;
    }
    
    //+------------------------------------------------------------------+
    //| Check if conditions allow trading                                |
    //+------------------------------------------------------------------+
    bool CheckTradingConditions(const string symbol)
    {
        // Check spread
        double spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * SymbolInfoDouble(symbol, SYMBOL_POINT);
        double maxSpread = SymbolInfoDouble(symbol, SYMBOL_POINT) * 30; // Max 30 pips
        
        if(spread > maxSpread)
        {
            Print("Spread too wide: ", spread);
            return false;
        }
        
        // Check if market is open
        if(!SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE))
        {
            Print("Market is closed");
            return false;
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Get quantum phase estimator for advanced analysis                |
    //+------------------------------------------------------------------+
    CQuantumPhaseEstimator* GetQPE() { return GetPointer(m_qpe); }
};
//+------------------------------------------------------------------+
