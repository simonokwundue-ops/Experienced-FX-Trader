//+------------------------------------------------------------------+
//|                                               BinaryEncoder.mqh   |
//|                        Quantum Forex Trader Support Library      |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Quantum Forex Trader"
#property link      ""
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Binary Encoder Class                                             |
//| Converts price data into binary sequences for quantum analysis   |
//+------------------------------------------------------------------+
class CBinaryEncoder
{
private:
    string m_binarySequence;
    
public:
    CBinaryEncoder() : m_binarySequence("") {}
    ~CBinaryEncoder() {}
    
    //+------------------------------------------------------------------+
    //| Convert price array to binary sequence                          |
    //+------------------------------------------------------------------+
    string PricesToBinary(const double &prices[], int count)
    {
        if(count < 2) return "";
        
        m_binarySequence = "";
        for(int i = 1; i < count; i++)
        {
            if(prices[i] > prices[i-1])
                m_binarySequence += "1";
            else
                m_binarySequence += "0";
        }
        
        return m_binarySequence;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate ratio of 1s and 0s in binary sequence                 |
    //+------------------------------------------------------------------+
    void CalculateTrendRatio(const string &binary, double &onesRatio, double &zerosRatio)
    {
        int length = StringLen(binary);
        if(length == 0)
        {
            onesRatio = 0.0;
            zerosRatio = 0.0;
            return;
        }
        
        int ones = 0;
        int zeros = 0;
        
        for(int i = 0; i < length; i++)
        {
            ushort ch = StringGetCharacter(binary, i);
            if(ch == '1')
                ones++;
            else if(ch == '0')
                zeros++;
        }
        
        onesRatio = (double)ones / (double)length;
        zerosRatio = (double)zeros / (double)length;
    }
    
    //+------------------------------------------------------------------+
    //| Predict trend based on binary sequence                          |
    //+------------------------------------------------------------------+
    string PredictTrend(const string &binary)
    {
        double onesRatio, zerosRatio;
        CalculateTrendRatio(binary, onesRatio, zerosRatio);
        
        if(onesRatio > 0.5)
            return "BULL";
        else if(onesRatio < 0.5)
            return "BEAR";
        else
            return "NEUTRAL";
    }
    
    //+------------------------------------------------------------------+
    //| Get last binary sequence                                         |
    //+------------------------------------------------------------------+
    string GetBinarySequence() const { return m_binarySequence; }
};
//+------------------------------------------------------------------+
