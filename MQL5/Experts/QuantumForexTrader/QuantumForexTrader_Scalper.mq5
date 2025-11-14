//+------------------------------------------------------------------+
//|                                  QuantumForexTrader_Scalper.mq5  |
//|                        Quantum-Inspired Forex Trading EA         |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Quantum Forex Trader"
#property link      ""
#property version   "1.00"
#property description "Quantum-inspired forex trading EA using phase estimation"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include "strategies\\QuantumSignals.mqh"
#include "strategies\\QuantumAnalysis.mqh"
#include "core\\QuantumRiskManager.mqh"

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+
input group "=== Quantum Analysis Parameters ==="
input int InpHistoryBars = 256;              // History bars for analysis (power of 2)
input double InpConfidenceThreshold = 0.03;  // Minimum confidence for signal (%)
input double InpMomentumThreshold = 0.1;     // Minimum momentum for signal

input group "=== Risk Management ==="
input double InpRiskPercent = 1.0;           // Risk per trade (%)
input double InpMaxDrawdown = 20.0;          // Maximum drawdown (%)
input int InpMaxPositions = 3;               // Maximum concurrent positions

input group "=== Trade Parameters ==="
input double InpStopLossPips = 50.0;         // Stop loss (pips)
input double InpTakeProfitPips = 100.0;      // Take profit (pips)
input int InpMagicNumber = 777777;           // Magic number

input group "=== Trading Schedule ==="
input bool InpUseTimeFilter = true;          // Use time filter
input int InpStartHour = 0;                  // Start trading hour
input int InpEndHour = 23;                   // End trading hour

input group "=== Signal Generation ==="
input int InpSignalInterval = 60;            // Signal check interval (seconds)

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
CQuantumSignalGenerator g_signalGen;
CQuantumRiskManager g_riskManager;
CAccountInfo g_account;

datetime g_lastSignalTime = 0;
string g_symbol;

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set symbol
    g_symbol = _Symbol;
    
    Print("=== Quantum Forex Trader Initializing ===");
    Print("Symbol: ", g_symbol);
    Print("Timeframe: ", EnumToString(_Period));
    
    // Configure signal generator
    g_signalGen.SetHistoryBars(InpHistoryBars);
    g_signalGen.SetConfidenceThreshold(InpConfidenceThreshold);
    g_signalGen.SetMomentumThreshold(InpMomentumThreshold);
    
    // Configure risk manager
    g_riskManager.SetRiskPercent(InpRiskPercent);
    g_riskManager.SetMaxDrawdown(InpMaxDrawdown);
    g_riskManager.SetMaxPositions(InpMaxPositions);
    
    // Set magic number
    g_riskManager.GetTrade().SetExpertMagicNumber(InpMagicNumber);
    
    // Display account info
    Print("Account Balance: ", g_account.Balance());
    Print("Account Equity: ", g_account.Equity());
    Print("Account Leverage: ", g_account.Leverage());
    
    // Display configuration
    Print("=== Configuration ===");
    Print("History Bars: ", InpHistoryBars);
    Print("Confidence Threshold: ", InpConfidenceThreshold * 100, "%");
    Print("Momentum Threshold: ", InpMomentumThreshold);
    Print("Risk Per Trade: ", InpRiskPercent, "%");
    Print("Max Drawdown: ", InpMaxDrawdown, "%");
    Print("Stop Loss: ", InpStopLossPips, " pips");
    Print("Take Profit: ", InpTakeProfitPips, " pips");
    
    Print("=== Quantum Forex Trader Initialized Successfully ===");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== Quantum Forex Trader Shutting Down ===");
    Print("Reason: ", reason);
    Print("Total Positions: ", PositionsTotal());
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if enough time has passed since last signal check
    datetime currentTime = TimeCurrent();
    if(currentTime - g_lastSignalTime < InpSignalInterval)
        return;
    
    g_lastSignalTime = currentTime;
    
    // Check time filter
    if(InpUseTimeFilter)
    {
        MqlDateTime time;
        TimeToStruct(currentTime, time);
        
        if(time.hour < InpStartHour || time.hour >= InpEndHour)
            return;
    }
    
    // Check trading conditions
    if(!g_signalGen.CheckTradingConditions(g_symbol))
        return;
    
    // Generate quantum signal
    QuantumSignal signal = g_signalGen.GenerateSignal(g_symbol, _Period);
    
    // Process signal
    if(signal.type == 1) // Buy signal
    {
        Print("=== BUY SIGNAL DETECTED ===");
        Print(g_signalGen.GetSignalInfo(signal));
        
        // Calculate position size
        double lotSize = g_riskManager.CalculatePositionSize(g_symbol, InpStopLossPips, signal.confidence);
        
        if(lotSize > 0)
        {
            Print("Opening BUY position with lot size: ", lotSize);
            g_riskManager.OpenBuyPosition(g_symbol, lotSize, InpStopLossPips, InpTakeProfitPips);
        }
    }
    else if(signal.type == -1) // Sell signal
    {
        Print("=== SELL SIGNAL DETECTED ===");
        Print(g_signalGen.GetSignalInfo(signal));
        
        // Calculate position size
        double lotSize = g_riskManager.CalculatePositionSize(g_symbol, InpStopLossPips, signal.confidence);
        
        if(lotSize > 0)
        {
            Print("Opening SELL position with lot size: ", lotSize);
            g_riskManager.OpenSellPosition(g_symbol, lotSize, InpStopLossPips, InpTakeProfitPips);
        }
    }
    
    // Display periodic status
    static int tickCount = 0;
    tickCount++;
    
    if(tickCount % 100 == 0) // Every 100 checks
    {
        Print("=== Status Update ===");
        Print("Time: ", TimeToString(currentTime, TIME_DATE|TIME_MINUTES));
        Print("Balance: ", g_account.Balance());
        Print("Equity: ", g_account.Equity());
        Print("Positions: ", PositionsTotal());
        Print("Last Signal: ", signal.trend, " (Confidence: ", 
              DoubleToString(signal.confidence * 100, 2), "%)");
    }
}

//+------------------------------------------------------------------+
//| Trade transaction handler                                         |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
    // Log trade events
    if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
    {
        Print("=== Trade Transaction ===");
        Print("Deal: ", trans.deal);
        Print("Order: ", trans.order);
        Print("Symbol: ", trans.symbol);
        Print("Type: ", EnumToString(trans.deal_type));
        Print("Volume: ", trans.volume);
        Print("Price: ", trans.price);
    }
}

//+------------------------------------------------------------------+
//| Tester function (for strategy tester)                            |
//+------------------------------------------------------------------+
double OnTester()
{
    double balance = g_account.Balance();
    double initialBalance = TesterStatistics(STAT_INITIAL_DEPOSIT);
    
    if(initialBalance > 0)
    {
        double profit = balance - initialBalance;
        double profitPercent = (profit / initialBalance) * 100.0;
        
        Print("=== Backtest Results ===");
        Print("Initial Balance: ", initialBalance);
        Print("Final Balance: ", balance);
        Print("Profit: ", profit, " (", profitPercent, "%)");
        
        return profitPercent;
    }
    
    return 0.0;
}
//+------------------------------------------------------------------+
