//+---------------------------------------------------------------------------+
//|                                                          MAS_Elder_v1.mq4 |
//|                                          Copyright 2017, Terentew Aleksey |
//|                                 https://www.mql5.com/ru/users/terentjew23 |
//+---------------------------------------------------------------------------+
#property copyright     "Copyright 2017, Terentew Aleksey"
#property link          "https://www.mql5.com/ru/users/terentjew23"
#property description   "Elder strategy."
#property description   "Send signals to buy and sell. 2 tf..."
#property description   "The idea of Alexander Elder."
#property version       "1.0"
#property strict

#include                "MAS_Include.mqh"

//---------------------Indicators---------------------------------------------+
#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 1
#property indicator_buffers 2
#property indicator_plots   2
//--- plot
#property indicator_label1  "Buy"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
#property indicator_label2  "Sell"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- indicator buffers
double      GreenBuffer[];
double      RedBuffer[];

//-----------------Global variables-------------------------------------------+
input int   EMA_TF0 = 26;
input int   EMA0_TF1 = 13;
input int   EMA1_TF1 = 22;
input int   MACD_FAST = 12;
input int   MACD_SLOW = 26;
input int   MACD_SIGNAL = 9;

//+---------------------------------------------------------------------------+
int OnInit()
{
    SetIndexBuffer( 0,GreenBuffer );
    SetIndexBuffer( 1,RedBuffer );
    IndicatorShortName( "Elder strategy v1.0 ("+IntegerToString(EMA_TF0)+","+IntegerToString(MACD_FAST)+","+
                        IntegerToString(MACD_SLOW)+","+IntegerToString(MACD_SIGNAL)+")" );
    if( EMA_TF0 <= 1 || EMA0_TF1 <= 1 || EMA1_TF1 <= 1 ||
            MACD_FAST <= 1 || MACD_SLOW <= 1 || MACD_SIGNAL <= 1 || MACD_FAST >= MACD_SLOW ) {
        Print( "Wrong input parameters" );
        return( INIT_FAILED );
    }
    return( INIT_SUCCEEDED );
}

//+---------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    if( rates_total <= MACD_SIGNAL ) {
        return(0);
    }
    int limit = rates_total - prev_calculated;
    if( prev_calculated > 0 ) {
        limit++;
    }
    for( int i = 0; i < limit; i++ ) {
        Print( IntegerToString( GetMorePeriod(PERIOD_CURRENT) ) );
        Print( IntegerToString( GetLessPeriod(PERIOD_CURRENT) ) );
        GreenBuffer[i] = 0.0;
        RedBuffer[i] = 0.0;
        double tmp = Elder_v1( i, PERIOD_CURRENT, EMA_TF0, EMA0_TF1, EMA1_TF1,
                                MACD_FAST, MACD_SLOW, MACD_SIGNAL );
        if( tmp > 0 )
            GreenBuffer[i] = tmp;
        if( tmp < 0 )
            RedBuffer[i] = tmp;
    }
    return( rates_total );
}
//+---------------------------------------------------------------------------+
//| Functions                                                                 |
//+---------------------------------------------------------------------------+

double Elder_v1(const int bar, const int period = PERIOD_CURRENT, const string symbol = NULL,
                const int pEMA_TF0 = 26, const int pEMA0_TF1 = 13, const int pEMA1_TF1 = 22,
                const int pMACD_F = 12, const int pMACD_S = 26, const int pMACD_Sig = 9)
{
    // Parent graph
    int periodTF1 = GetMorePeriod( (ENUM_TIMEFRAMES)period );
    int barTF1 = Bars( symbol, periodTF1, iTime(symbol, period, 0), iTime(symbol, period, bar) );
    double macd0_TF1 = iMACD( symbol, periodTF1, pMACD_F, pMACD_S, pMACD_Sig, PRICE_CLOSE, MODE_MAIN, barTF1 );
    double macd1_TF1 = iMACD( symbol, periodTF1, pMACD_F, pMACD_S, pMACD_Sig, PRICE_CLOSE, MODE_MAIN, barTF1+1 );
    double ema0_TF1 = iMA( symbol, periodTF1, pEMA1_TF1, 0, MODE_EMA, PRICE_CLOSE, barTF1 );
    double ema1_TF1 = iMA( symbol, periodTF1, pEMA1_TF1, 0, MODE_EMA, PRICE_CLOSE, barTF1+1 );
    double impulseTF1 = Impulse( barTF1, periodTF1, 13, pMACD_F, pMACD_S, pMACD_Sig );  // зависимость импульса от EMA0_TF1 ?
    bool resultBuyTF1 = (macd0_TF1 > macd1_TF1) && (ema0_TF1 >= ema1_TF1) && (impulseTF1 >= 0.0); // разворот ЕМА это >= или > ?
    bool resultSellTF1 = (macd0_TF1 < macd1_TF1) && (ema0_TF1 <= ema1_TF1) && (impulseTF1 <= 0.0);
    // Main graph
    double impulseTF0 = Impulse( bar, period, 13, pMACD_F, pMACD_S, pMACD_Sig );
    if( resultBuyTF1 ) {
        
        return 1.0;
    }
    if( resultSellTF1 ) {
        
        return -1.0;
    }
    return 0.0;
};


