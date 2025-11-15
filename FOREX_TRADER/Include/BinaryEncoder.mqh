//+------------------------------------------------------------------+
//|                                            BinaryEncoder.mqh     |
//|                      Price-to-Binary Encoding Functions          |
//|                For Quantum-Compatible Market Analysis            |
//+------------------------------------------------------------------+
#property copyright "ForexTrader Quantum EA"
#property link      "https://github.com/simonokwundue-ops/Experienced-FX-Trader"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Binary Price Encoder Class                                       |
//+------------------------------------------------------------------+
class CBinaryEncoder
{
public:
   //--- Encode price movements to binary string
   static string EncodePriceMovements(const double &prices[], int count)
   {
      if(count < 2) return "";
      
      string binary = "";
      
      for(int i = 1; i < count; i++)
      {
         // 1 if price increased, 0 if decreased or equal
         binary += (prices[i] > prices[i-1]) ? "1" : "0";
      }
      
      return binary;
   }
   
   //--- Encode MqlRates array to binary
   static string EncodeRates(const MqlRates &rates[], int count = -1)
   {
      int size = (count > 0) ? count : ArraySize(rates);
      if(size < 2) return "";
      
      string binary = "";
      
      // Process from oldest to newest
      for(int i = size - 2; i >= 0; i--)
      {
         binary += (rates[i].close > rates[i+1].close) ? "1" : "0";
      }
      
      return binary;
   }
   
   //--- Encode with volatility weighting
   static string EncodeWithVolatility(const MqlRates &rates[], int count = -1)
   {
      int size = (count > 0) ? count : ArraySize(rates);
      if(size < 2) return "";
      
      string binary = "";
      double avgRange = CalculateAverageRange(rates, size);
      
      for(int i = size - 2; i >= 0; i--)
      {
         double priceChange = rates[i].close - rates[i+1].close;
         double candleRange = rates[i].high - rates[i].low;
         
         // Weight by volatility significance
         if(MathAbs(priceChange) > avgRange * 0.3)
         {
            // Significant move
            binary += (priceChange > 0) ? "1" : "0";
         }
         else
         {
            // Small move - consider as continuation
            if(i < size - 2)
               binary += binary[StringLen(binary) - 1];  // Copy previous
            else
               binary += "0";
         }
      }
      
      return binary;
   }
   
   //--- Decode binary string to probability
   static double DecodeToProbability(const string binary)
   {
      int length = StringLen(binary);
      if(length == 0) return 0.5;
      
      int ones = 0;
      for(int i = 0; i < length; i++)
      {
         if(StringGetCharacter(binary, i) == '1')
            ones++;
      }
      
      return (double)ones / length;
   }
   
   //--- Calculate pattern frequency
   static double CalculatePatternFrequency(const string binary, const string pattern)
   {
      int binaryLen = StringLen(binary);
      int patternLen = StringLen(pattern);
      
      if(patternLen == 0 || patternLen > binaryLen)
         return 0;
      
      int matches = 0;
      int possibleMatches = binaryLen - patternLen + 1;
      
      for(int i = 0; i < possibleMatches; i++)
      {
         string segment = StringSubstr(binary, i, patternLen);
         if(segment == pattern)
            matches++;
      }
      
      return (double)matches / possibleMatches;
   }
   
   //--- Extract recent pattern
   static string ExtractRecentPattern(const string binary, int length)
   {
      int binaryLen = StringLen(binary);
      if(length > binaryLen) length = binaryLen;
      
      return StringSubstr(binary, 0, length);
   }
   
   //--- Calculate pattern entropy
   static double CalculatePatternEntropy(const string binary)
   {
      int length = StringLen(binary);
      if(length < 2) return 0;
      
      // Count consecutive patterns
      int changes = 0;
      for(int i = 1; i < length; i++)
      {
         if(StringGetCharacter(binary, i) != StringGetCharacter(binary, i-1))
            changes++;
      }
      
      // Entropy measure: more changes = higher entropy
      return (double)changes / (length - 1);
   }
   
   //--- Detect trend in binary sequence
   static int DetectTrend(const string binary, int lookback = 20)
   {
      int length = StringLen(binary);
      if(length == 0) return 0;
      
      if(lookback > length) lookback = length;
      
      string recent = StringSubstr(binary, 0, lookback);
      int ones = 0;
      
      for(int i = 0; i < lookback; i++)
      {
         if(StringGetCharacter(recent, i) == '1')
            ones++;
      }
      
      double ratio = (double)ones / lookback;
      
      if(ratio > 0.60) return 1;      // Uptrend
      else if(ratio < 0.40) return -1; // Downtrend
      else return 0;                   // No clear trend
   }
   
   //--- Calculate momentum score
   static double CalculateMomentumScore(const string binary, int period = 10)
   {
      int length = StringLen(binary);
      if(length < period) period = length;
      if(period == 0) return 0;
      
      string recent = StringSubstr(binary, 0, period);
      int ones = 0;
      
      for(int i = 0; i < period; i++)
      {
         if(StringGetCharacter(recent, i) == '1')
            ones++;
      }
      
      // Score from -1 (strong down) to +1 (strong up)
      return (2.0 * ones / period) - 1.0;
   }
   
   //--- Find similar patterns in history
   static double FindHistoricalSimilarity(const string currentPattern, 
                                          const string historical,
                                          int patternLength)
   {
      if(patternLength > StringLen(currentPattern))
         patternLength = StringLen(currentPattern);
      
      string pattern = StringSubstr(currentPattern, 0, patternLength);
      int histLength = StringLen(historical);
      
      if(patternLength > histLength)
         return 0;
      
      double maxSimilarity = 0;
      
      // Scan historical data for similar patterns
      for(int i = 0; i <= histLength - patternLength; i++)
      {
         string segment = StringSubstr(historical, i, patternLength);
         double similarity = CalculateSimilarity(pattern, segment);
         
         if(similarity > maxSimilarity)
            maxSimilarity = similarity;
      }
      
      return maxSimilarity;
   }
   
   //--- Calculate similarity between two binary strings
   static double CalculateSimilarity(const string binary1, const string binary2)
   {
      int len1 = StringLen(binary1);
      int len2 = StringLen(binary2);
      
      if(len1 != len2) return 0;
      if(len1 == 0) return 0;
      
      int matches = 0;
      
      for(int i = 0; i < len1; i++)
      {
         if(StringGetCharacter(binary1, i) == StringGetCharacter(binary2, i))
            matches++;
      }
      
      return (double)matches / len1;
   }
   
   //--- Pad binary string to specified length
   static string PadBinary(const string binary, int targetLength, bool padLeft = true)
   {
      int currentLength = StringLen(binary);
      
      if(currentLength >= targetLength)
         return binary;
      
      string padding = "";
      for(int i = 0; i < targetLength - currentLength; i++)
      {
         padding += "0";
      }
      
      return padLeft ? (padding + binary) : (binary + padding);
   }
   
   //--- Convert binary string to integer
   static long BinaryToInteger(const string binary)
   {
      int length = StringLen(binary);
      if(length == 0 || length > 63) return 0;  // Prevent overflow
      
      long result = 0;
      long power = 1;
      
      for(int i = length - 1; i >= 0; i--)
      {
         if(StringGetCharacter(binary, i) == '1')
            result += power;
         power *= 2;
      }
      
      return result;
   }
   
   //--- Convert integer to binary string
   static string IntegerToBinary(long value, int minLength = 8)
   {
      if(value < 0) value = 0;
      
      string binary = "";
      
      if(value == 0)
      {
         binary = "0";
      }
      else
      {
         while(value > 0)
         {
            binary = ((value % 2 == 1) ? "1" : "0") + binary;
            value /= 2;
         }
      }
      
      // Pad to minimum length
      return PadBinary(binary, minLength, true);
   }
   
   //--- Helper: Calculate average range
   static double CalculateAverageRange(const MqlRates &rates[], int count)
   {
      if(count < 1) return 0;
      
      double totalRange = 0;
      
      for(int i = 0; i < count; i++)
      {
         totalRange += (rates[i].high - rates[i].low);
      }
      
      return totalRange / count;
   }
   
   //--- Compress binary using run-length encoding (for storage/comparison)
   static string CompressBinary(const string binary)
   {
      int length = StringLen(binary);
      if(length == 0) return "";
      
      string compressed = "";
      ushort currentChar = StringGetCharacter(binary, 0);
      int count = 1;
      
      for(int i = 1; i < length; i++)
      {
         ushort nextChar = StringGetCharacter(binary, i);
         
         if(nextChar == currentChar)
         {
            count++;
         }
         else
         {
            compressed += IntegerToString(count) + ShortToString(currentChar);
            currentChar = nextChar;
            count = 1;
         }
      }
      
      // Add final run
      compressed += IntegerToString(count) + ShortToString(currentChar);
      
      return compressed;
   }
};

//+------------------------------------------------------------------+
