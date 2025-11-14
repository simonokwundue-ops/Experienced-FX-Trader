//+------------------------------------------------------------------+
//|                                          QuantumRiskManager.mqh   |
//|                        Quantum Forex Trader Support Library      |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Quantum Forex Trader"
#property link      ""
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Quantum Risk Manager Class                                       |
//| Manages position sizing and risk based on quantum signals       |
//+------------------------------------------------------------------+
class CQuantumRiskManager
{
private:
    CTrade m_trade;
    CPositionInfo m_position;
    CAccountInfo m_account;
    
    double m_riskPercent;
    double m_maxDrawdownPercent;
    int m_maxPositions;
    double m_minLotSize;
    double m_maxLotSize;
    
public:
    CQuantumRiskManager() :
        m_riskPercent(1.0),
        m_maxDrawdownPercent(20.0),
        m_maxPositions(3),
        m_minLotSize(0.01),
        m_maxLotSize(10.0)
    {
    }
    
    ~CQuantumRiskManager() {}
    
    //+------------------------------------------------------------------+
    //| Set risk parameters                                              |
    //+------------------------------------------------------------------+
    void SetRiskPercent(double percent) { m_riskPercent = percent; }
    void SetMaxDrawdown(double percent) { m_maxDrawdownPercent = percent; }
    void SetMaxPositions(int max) { m_maxPositions = max; }
    
    //+------------------------------------------------------------------+
    //| Calculate position size based on risk                            |
    //+------------------------------------------------------------------+
    double CalculatePositionSize(const string symbol, double stopLossPips, double confidence = 1.0)
    {
        // Get account info
        double balance = m_account.Balance();
        double equity = m_account.Equity();
        
        // Check drawdown
        double currentDrawdown = ((balance - equity) / balance) * 100.0;
        if(currentDrawdown >= m_maxDrawdownPercent)
        {
            Print("Max drawdown reached: ", currentDrawdown, "%");
            return 0.0;
        }
        
        // Get symbol info
        double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
        double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
        double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
        double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
        double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
        double pointValue = SymbolInfoDouble(symbol, SYMBOL_POINT);
        
        // Calculate pip value
        int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        double pipSize = (digits == 3 || digits == 5) ? pointValue * 10 : pointValue;
        double pipValue = tickValue * (pipSize / tickSize);
        
        // Calculate risk amount
        double riskAmount = balance * (m_riskPercent / 100.0);
        
        // Adjust risk based on confidence
        riskAmount = riskAmount * confidence;
        
        // Calculate lot size
        double lotSize = 0.0;
        if(stopLossPips > 0)
        {
            lotSize = riskAmount / (stopLossPips * pipValue);
        }
        else
        {
            // Default to minimum lot if no stop loss
            lotSize = minLot;
        }
        
        // Normalize lot size
        lotSize = MathFloor(lotSize / lotStep) * lotStep;
        
        // Apply limits
        if(lotSize < minLot) lotSize = minLot;
        if(lotSize > maxLot) lotSize = maxLot;
        if(lotSize > m_maxLotSize) lotSize = m_maxLotSize;
        
        return lotSize;
    }
    
    //+------------------------------------------------------------------+
    //| Check if can open new position                                   |
    //+------------------------------------------------------------------+
    bool CanOpenPosition(const string symbol)
    {
        // Check max positions
        int totalPositions = PositionsTotal();
        if(totalPositions >= m_maxPositions)
        {
            Print("Max positions reached: ", totalPositions);
            return false;
        }
        
        // Check if already have position on this symbol
        for(int i = 0; i < totalPositions; i++)
        {
            if(m_position.SelectByIndex(i))
            {
                if(m_position.Symbol() == symbol)
                {
                    Print("Already have position on ", symbol);
                    return false;
                }
            }
        }
        
        // Check account equity
        if(m_account.Equity() <= 0)
        {
            Print("Insufficient equity");
            return false;
        }
        
        // Check drawdown
        double balance = m_account.Balance();
        double equity = m_account.Equity();
        double currentDrawdown = ((balance - equity) / balance) * 100.0;
        
        if(currentDrawdown >= m_maxDrawdownPercent)
        {
            Print("Max drawdown reached: ", currentDrawdown, "%");
            return false;
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Open buy position                                                |
    //+------------------------------------------------------------------+
    bool OpenBuyPosition(const string symbol, double lotSize, double stopLossPips, double takeProfitPips)
    {
        if(!CanOpenPosition(symbol))
            return false;
        
        double price = SymbolInfoDouble(symbol, SYMBOL_ASK);
        int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
        double pipSize = (digits == 3 || digits == 5) ? point * 10 : point;
        
        double sl = (stopLossPips > 0) ? price - stopLossPips * pipSize : 0;
        double tp = (takeProfitPips > 0) ? price + takeProfitPips * pipSize : 0;
        
        bool result = m_trade.Buy(lotSize, symbol, price, sl, tp, "Quantum Buy");
        
        if(result)
            Print("Buy position opened: ", symbol, " Lot: ", lotSize, " SL: ", sl, " TP: ", tp);
        else
            Print("Failed to open buy position: ", m_trade.ResultRetcodeDescription());
        
        return result;
    }
    
    //+------------------------------------------------------------------+
    //| Open sell position                                               |
    //+------------------------------------------------------------------+
    bool OpenSellPosition(const string symbol, double lotSize, double stopLossPips, double takeProfitPips)
    {
        if(!CanOpenPosition(symbol))
            return false;
        
        double price = SymbolInfoDouble(symbol, SYMBOL_BID);
        int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
        double pipSize = (digits == 3 || digits == 5) ? point * 10 : point;
        
        double sl = (stopLossPips > 0) ? price + stopLossPips * pipSize : 0;
        double tp = (takeProfitPips > 0) ? price - takeProfitPips * pipSize : 0;
        
        bool result = m_trade.Sell(lotSize, symbol, price, sl, tp, "Quantum Sell");
        
        if(result)
            Print("Sell position opened: ", symbol, " Lot: ", lotSize, " SL: ", sl, " TP: ", tp);
        else
            Print("Failed to open sell position: ", m_trade.ResultRetcodeDescription());
        
        return result;
    }
    
    //+------------------------------------------------------------------+
    //| Get trade object reference                                       |
    //+------------------------------------------------------------------+
    CTrade* GetTrade() { return GetPointer(m_trade); }
};
//+------------------------------------------------------------------+
