//+------------------------------------------------------------------+
//|                                      SupportResistanceExpert.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//HEIGHT OF GRAPH
int height =50;
//risk reward ratio
double rrr=2;
//delete all trades every __ trades
int delAt=77;
//weekly highs and lows and intervals
double highest=Ask;
double lowest=Bid;
double interval=40;
int intervalPips=(int)(interval/_Point);
//big arrays
int high[50];
int low[50];
int tradeCount=0;
int spread =(int)((Ask-Bid)/_Point)+1;
int OnInit()
  {
   ArrayInitialize(high,0);
   ArrayInitialize(low,0);
   for(int i=1;i<5;i++)
     {
      if(highest<iHigh(_Symbol,PERIOD_D1,i))
        {
         highest=iHigh(_Symbol,PERIOD_D1,i);
        }
        if(lowest>iLow(_Symbol,PERIOD_D1,i))
        {
         lowest=iLow(_Symbol,PERIOD_D1,i);
        }
     }
   interval=MathRound(((highest-lowest)/height)*100)/100;
//how far should the stop loss be set
   intervalPips=(int)((interval/_Point)+1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trade(bool buy, double fromWhere)
  {
   double from=fromWhere;//instead of Ask+howFar*_Point or Bid-howFar*Point
   int pips=intervalPips;
   double risk=AccountBalance()*0.02/1.3;
   double shares = (int)(risk / pips * 100);
   if(AccountBalance()>=1800)
     {
      if(buy)
        {
         //max shares based on current margin
         double maxShares = (int)(AccountFreeMargin()/1.3 * 14.8 / (from));
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
         Alert("Buy ",shares," shares of ", _Symbol," at ", from);
         //price to trade at
         double x=from;
         //volume of the trade and stoploss
         double y=shares;
         int stoploss=pips+1;
         int takeprofit=(int)(pips*rrr)+1;
         //trade
         tradeCount++;
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
            double maxShares = (int)(AccountFreeMargin()/1.3 * 14.8 / (from));
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
            Alert("Sell ",shares," shares of ", _Symbol," at ", from);
            //price to trade at
            double x=from;
            //volume of the trade and stoploss
            double y=shares;
            int stoploss=pips+1;
            int takeprofit=(int)(pips*rrr)+1;
            //trade
            tradeCount++;
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
//|                                                                  |
//+------------------------------------------------------------------+
int getHiLoIndex(double x)
  {
   for(int i=0; i<height; i++)
     {
      if((x>=(lowest+(i*interval)))&&(x<lowest+((1+i)*interval)))
        {
         return i;
        }
     }
   if(x<lowest)
     {
      return 0;
     }
   return (height-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int addHigh(int i)
  {
   int x=getHiLoIndex(High[i]);
   high[x]++;
   Alert("Local Resistance in sector ",x);
   return x;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int addLow(int i)
  {
   int x=getHiLoIndex(Low[i]);
   high[x]++;
   Alert("Local Support in sector ",x);
   return x;
  }
//+------------------------------------------------------------------+
//|Delete Pending Trades                                             |
//+------------------------------------------------------------------+
void deletePending()
  {
   for(int i=(OrdersTotal()-1); i>=0; i--)
     {

      //select an order
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         //make sure its the right currency pair
         if(OrderSymbol()==_Symbol)
           {
            //check if buy or sell
            if(OrderType()==OP_BUYSTOP)
              {
                 {
                  int closebuy=OrderDelete(OrderTicket());
                 }
              }
            else
               if(OrderType()==OP_SELLSTOP)
                 {
                  int closesell=OrderDelete(OrderTicket());
                 }
           }
        }
     }
  }
//big 2d array for every 3 candles max and mins
double candle1=0;
double candle2=0;
double candle3=0;
int candleCount=0;
int deleteCounter=0;
void OnTick()
  {

//every 3 candles if there is a high or low it will be reported in the counter arrays above
//move to next entry when a new trio comes
   if((candle1!=(Close[3]-Open[3]))&&(candle2!=(Close[2]-Open[2]))&&(candle3!=(Close[1]-Open[1])))
     {
      candleCount++;
      candle1=Close[3]-Open[3];
      candle2=Close[2]-Open[2];
      candle3=Close[1]-Open[1];
      //delete the previous trades that were left unopened for 6 candles
         deleteCounter++;
         if(deleteCounter>delAt)
           {
            deletePending();
            deleteCounter=0;
           }
      if(candleCount==4)
        {
         
         
         //did we pass a resistance
         bool H=false;
         bool L=false;
         //index
         int index=25;//can be any number
         if((candle1>0)&&(candle3<0)&&(Close[3]<=Open[2])&&(Close[2]>=Close[1])&&(High[2]>=High[1])&&(High[2]>=High[3]))
           {
            //yes :local high
            index=addHigh(2);
            H=true;
           }
         //did we pass a support
         if((candle1<0)&&(candle3>0)&&(Close[3]>=Open[2])&&(Close[2]<=Close[1])&&(Low[2]>=Low[1])&&(Low[2]>=Low[3]))
           {
            //yes :local low
            index=addLow(2);
            L=true;
           }
         //if not at the monthly low/high
         if((index!=0)&&(index!=(height-1))&&(index!=height))
           {
            //cant trade if it gets filled automatically 
            if(intervalPips>=spread)
              {
               if(L && !H)
                 {
                  //how many times was it exclusively passed
                  //if more than 1, then make a stop order at the next reversal
                  if(low[index]>1)
                    {
                     //make trade
                     if(Ask>(lowest+(index+1)*interval))
                       {
                        trade(true,lowest+(index+2)*interval);
                       }else
                          {
                           trade(true,lowest+(index+1)*interval);
                          }
                     
                    }
                 }
               else
                  if(!L && H)
                    {
                     //how many times was it exclusively passed
                     //if more than 1, then make a stop order at the next reversal
                     if(high[index]>1)
                       {
                        //make trade
                        if(Bid<(lowest+(index)*interval))
                          {
                           trade(false,lowest+(index-1)*interval);
                          }else
                             {
                        trade(false,lowest+(index)*interval);
                             }
                       }
                    }
              }
           }
         //reset candlecount
         candleCount=1;
        }
     }
   Comment(
      "balance :  ",AccountBalance(),"\n",
      "Candle: ",candleCount,"/3","\n",
      "Delete at ",delAt,":",deleteCounter,"\n",
      "Trades: ",tradeCount,"\n",
      "Highest: ",highest,"\n",
      "Lowest: ",lowest,"\n",
      "intervaL: ",interval,"\n",
      "intervalPips: ",intervalPips,"\n",
      "Spread: ",spread
   );


  }//end of OnTick
//+------------------------------------------------------------------+
