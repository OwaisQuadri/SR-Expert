//+------------------------------------------------------------------+
//|                                      SupportResistanceExpert.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
double rrr=3;
void trade(bool buy, int pipsToStopLoss, int howFar)
  {
   int pips=pipsToStopLoss;
   double risk=AccountBalance()*0.02/1.3;
   double shares = (int)(risk / pips * 100);


   if(AccountProfit()>=-200)
     {
      if(buy)
        {
         //max shares based on current margin
         double maxShares = (int)(AccountFreeMargin()/1.3 * 14.8 / (Ask+howFar*_Point));
         //if its forex divide by 100
         if((MarketInfo(_Symbol,MODE_TICKSIZE))<0.01)
           {
            maxShares/=100;
            shares/=100;
           }
         //cannot attempt a trade over the max lot size
         if(shares>(MarketInfo(_Symbol,MODE_MAXLOT)))
           {
            shares=MarketInfo(_Symbol,MODE_MAXLOT);
           }
         //if current amount of shares is more than the max lot size
         if(maxShares < shares)
           {
            shares = maxShares;
            //if the shares go up or down, pips must go up or down depending on risk
            pips=(int)(risk/shares*100);
           }
         //alert for informative purposes
         Alert("Buy ",shares," shares of ", _Symbol);
         //price to trade at
         double x=Ask+howFar*_Point;
         //volume of the trade and stoploss
         double y=shares;
         int stoploss=pips;
         int takeprofit=(int)(pips*rrr);
         //trade
         int order0=OrderSend(
                       _Symbol,//currencyPair
                       OP_BUYSTOP,//buy
                       y,//howmuch*SYMBOL_VOLUME_MIN
                       x,//price
                       3,//tolerance
                       x-stoploss*_Point, //stoploss
                       x+takeprofit*_Point,//takeprofit
                       NULL,//comment
                       0,//magic number
                       0,//expiration
                       CLR_NONE//color of arrow
                    );
        }
      else
         if(!buy)
           {
            //max shares based on current margin
            double maxShares = (int)(AccountFreeMargin()/1.3 * 14.8 / (Bid-howFar*_Point));
            //if its forex divide by 100
            if((MarketInfo(_Symbol,MODE_TICKSIZE))<0.01)
              {
               maxShares/=100;
               shares/=100;
              }
            //cannot attempt a trade over the max lot size
            if(shares>(MarketInfo(_Symbol,MODE_MAXLOT)))
              {
               shares=MarketInfo(_Symbol,MODE_MAXLOT);
              }
            //if current amount of shares is more than the max lot size
            if(maxShares < shares)
              {
               shares = maxShares;
               //if the shares go up or down, pips must go up or down depending on risk
               pips=(int)(risk/shares*100);
              }
            //alert for informative purposes
            Alert("Sell ",shares," shares of ", _Symbol);
            //price to trade at
            double x=Bid-howFar*_Point;
            //volume of the trade and stoploss
            double y=shares;
            int stoploss=pips;
            int takeprofit=(int)(pips*rrr);
            //trade
            int order0=OrderSend(
                          _Symbol,//currencyPair
                          OP_SELLSTOP,//buy
                          y,//howmuch*SYMBOL_VOLUME_MIN
                          x,//price
                          3,//tolerance
                          x+stoploss*_Point, //stoploss
                          x-takeprofit*_Point,//takeprofit
                          NULL,//comment
                          0,//magic number
                          0,//expiration
                          CLR_NONE//color of arrow
                       );
           }
     }
   else
     {
      Alert("NO MORE TRADES, this is awful");
     }


  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//did we pass a support

//did we pass a resistance

//how many times was it passed

//what direction is the immediate trend (1 or 2 cnadlesticks)

//how far should the stop loss be set

//make trade

  }
//+------------------------------------------------------------------+
