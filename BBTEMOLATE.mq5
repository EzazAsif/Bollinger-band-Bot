#include <Trade\Trade.mqh>

CTrade trade;

void trade()
{
    string entry = "";
    
    double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    
    MqlRates PriceInfo[];
    ArraySetAsSeries(PriceInfo, true);
    
    int PriceData = CopyRates(_Symbol, _Period, 0, 3, PriceInfo);
    
    double UpperBandArray[];
    double MiddleBandArray[];
    double LowerBandArray[];
    ArraySetAsSeries(UpperBandArray, true);
    ArraySetAsSeries(MiddleBandArray, true);
    ArraySetAsSeries(LowerBandArray, true);
    
    int BollingerBandDefination = iBands(_Symbol, _Period, 20, 0, 2, PRICE_CLOSE);
    
    // Copy band values
    int copiedBars = CopyBuffer(BollingerBandDefination, 0, 0, 3, UpperBandArray);
    if (copiedBars == -1)
    {
        Print("Error copying band values. Bars copied: ", copiedBars);
        return;
    }
    CopyBuffer(BollingerBandDefination, 1, 0, 3, UpperBandArray);
    CopyBuffer(BollingerBandDefination, 0, 0, 3, MiddleBandArray);
    CopyBuffer(BollingerBandDefination, 2, 0, 3, LowerBandArray);
    
    double myUpperBandValue = UpperBandArray[0];
    double myMiddleBandValue = MiddleBandArray[0];
    double myLowerBandValue = LowerBandArray[0];
    
    double myLastUpperBandValue = UpperBandArray[1];
    double myLastMiddleBandValue = MiddleBandArray[1];
    double myLastLowerBandValue = LowerBandArray[1];
    
    
   if (PriceInfo[0].close > myLowerBandValue && PriceInfo[1].close < myLastLowerBandValue&&PriceInfo[0].close < myMiddleBandValue&&PriceInfo[0].close < myLastUpperBandValue&&PriceInfo[0].open<myLowerBandValue&&PriceInfo[0].close-PriceInfo[0].open>0)
    {
        entry = "buy";
    }
    
    if (PriceInfo[0].close < myUpperBandValue && PriceInfo[1].close > myLastUpperBandValue&&PriceInfo[0].close > myMiddleBandValue&&PriceInfo[0].close > myLastLowerBandValue&&PriceInfo[0].open>myUpperBandValue&&PriceInfo[0].open-PriceInfo[0].close>0)
    {
        entry = "sell";
    }
    
    if (entry == "sell" && PositionsTotal() < 1&&OrdersTotal()<6)
    {
        double takeProfit = Bid - 50 * _Point;
        double stopLoss = recentHigh(PriceInfo);
        trade.Sell(0.10, NULL, Bid, stopLoss, takeProfit, NULL);
        
        Alert("Sold", 0.10, "lots at", Bid, "$");
    }
    
    if (entry == "buy" && PositionsTotal() < 1)
    {
        double takeProfit = Ask + 50 * _Point;
        double stopLoss = recentLow(PriceInfo);
        trade.Buy(0.10, NULL, Ask, stopLoss, takeProfit, NULL);
        
        Alert("Bought", 0.10, "lots at", Ask, "$");
        
        
        
    }
   
}

void OnTick()
{
    trade();
}

double recentHigh(MqlRates& PriceInfo[])
{
   double recentHigh=0;
   for(int i=1;i<=30&&i<ArraySize(PriceInfo);i++){
       if(PriceInfo[i].close-PriceInfo[i].open>0&&PriceInfo[i].close>recentHigh){
       recentHigh=PriceInfo[i].close;
       }
   }
   return recentHigh;
}
double recentLow(MqlRates& PriceInfo[])
{
   double recentLow=0;
   for(int i=1;i<=30&&i<ArraySize(PriceInfo);i++){
       if(PriceInfo[i].close-PriceInfo[i].open<0&&PriceInfo[i].close<recentLow){
       recentLow=PriceInfo[i].close;
       }
   }
   return recentLow;
}