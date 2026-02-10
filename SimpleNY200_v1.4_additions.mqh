
//+------------------------------------------------------------------+
//| SECTION 35: PRE-MARKET ZONE FUNCTIONS (v1.4)                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if current candle is specific NY time                      |
//+------------------------------------------------------------------+
bool IsSpecificNYTimeCandle(int targetHour, int targetMinute)
{
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);
    
    // Calculate NY time from broker time
    int estOffset = UseDST ? -4 : -5;
    int nyHourInGMT = targetHour - estOffset;
    int brokerHour = nyHourInGMT + BrokerGMTOffset;
    
    // Handle midnight crossover
    if(brokerHour >= 24) brokerHour -= 24;
    if(brokerHour < 0) brokerHour += 24;
    
    // Check if current candle matches target time
    return (dt.hour == brokerHour && dt.min == targetMinute);
}

//+------------------------------------------------------------------+
//| Calculate pre-market zone (8:15 AM - 8:30 AM)                   |
//+------------------------------------------------------------------+
void CalculatePreMarketZone()
{
    // Reset if new day
    datetime currentDate = iTime(_Symbol, PERIOD_D1, 0);
    static datetime lastCalculationDate = 0;
    
    if(currentDate != lastCalculationDate) {
        g_ZoneCalculated = false;
        g_Zone815High = 0.0;
        g_Zone830Low = 0.0;
        g_ClosesAboveZone = 0;
        g_ClosesBelowZone = 0;
        g_ZoneInverted = false;
        lastCalculationDate = currentDate;
        LogMessage("🔄 NUEVO DÍA - Reset zona pre-market", LOG_DEBUG);
    }
    
    if(g_ZoneCalculated) return;
    
    // Step 1: Capture 8:15 AM candle body HIGH
    if(g_Zone815High == 0.0 && IsSpecificNYTimeCandle(8, 15)) {
        double open815 = iOpen(_Symbol, PERIOD_M1, 0);
        double close815 = iClose(_Symbol, PERIOD_M1, 0);
        g_Zone815High = MathMax(open815, close815); // Body HIGH
        g_Zone815Time = TimeCurrent();
        LogMessage("📍 ZONA 8:15 AM - Body HIGH capturado: " + DoubleToString(g_Zone815High, _Digits), LOG_INFO);
    }
    
    // Step 2: Capture 8:30 AM candle body LOW
    if(g_Zone830Low == 0.0 && g_Zone815High > 0.0 && IsSpecificNYTimeCandle(8, 30)) {
        double open830 = iOpen(_Symbol, PERIOD_M1, 0);
        double close830 = iClose(_Symbol, PERIOD_M1, 0);
        g_Zone830Low = MathMin(open830, close830); // Body LOW
        g_Zone830Time = TimeCurrent();
        
        // Step 3: Define zone levels
        if(g_Zone830Low > g_Zone815High) {
            // GAP scenario - invert zone
            g_ZoneUpperLevel = g_Zone830Low;
            g_ZoneLowerLevel = g_Zone815High;
            g_ZoneInverted = true;
            LogMessage("⚠️ ZONA INVERTIDA (GAP detectado)", LOG_WARNING);
            LogMessage("   Upper: " + DoubleToString(g_ZoneUpperLevel, _Digits) + 
                      " | Lower: " + DoubleToString(g_ZoneLowerLevel, _Digits), LOG_WARNING);
        } else {
            // Normal scenario
            g_ZoneUpperLevel = g_Zone815High;
            g_ZoneLowerLevel = g_Zone830Low;
            g_ZoneInverted = false;
            LogMessage("✅ ZONA PRE-MARKET CALCULADA", LOG_INFO);
            LogMessage("   Upper (8:15): " + DoubleToString(g_ZoneUpperLevel, _Digits), LOG_INFO);
            LogMessage("   Lower (8:30): " + DoubleToString(g_ZoneLowerLevel, _Digits), LOG_INFO);
            LogMessage("   Tamaño: " + DoubleToString((g_ZoneUpperLevel - g_ZoneLowerLevel)/_Point, 1) + " pips", LOG_INFO);
        }
        
        g_ZoneCalculated = true;
        g_SignalPeriodActive = true;
    }
}

//+------------------------------------------------------------------+
//| Check if within signal search period (before 10:00 AM NY)       |
//+------------------------------------------------------------------+
bool IsWithinSignalSearchPeriod()
{
    if(!g_ZoneCalculated) return false;
    
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);
    
    // Calculate 10:00 AM NY in broker time
    int estOffset = UseDST ? -4 : -5;
    int nyHourInGMT = 10 - estOffset;
    int brokerHour = nyHourInGMT + BrokerGMTOffset;
    
    if(brokerHour >= 24) brokerHour -= 24;
    if(brokerHour < 0) brokerHour += 24;
    
    // Check if before 10:00 AM
    if(dt.hour < brokerHour || (dt.hour == brokerHour && dt.min < 0)) {
        return true;
    }
    
    if(g_SignalPeriodActive) {
        LogMessage("⏰ PERÍODO DE SEÑALES TERMINADO (10:00 AM alcanzado)", LOG_INFO);
        g_SignalPeriodActive = false;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check for 2-close confirmation signals                          |
//+------------------------------------------------------------------+
void CheckForTwoCloseSignals()
{
    if(!g_ZoneCalculated) return;
    if(!IsWithinSignalSearchPeriod()) return;
    if(g_TradedToday) return;
    
    // Check if new candle closed
    static datetime lastCheckedCandle = 0;
    datetime currentCandleTime = iTime(_Symbol, PERIOD_M1, 0);
    if(currentCandleTime == lastCheckedCandle) return; // Already checked this candle
    lastCheckedCandle = currentCandleTime;
    
    // Get current closed candle price
    double currentClose = iClose(_Symbol, PERIOD_M1, 0);
    
    // Count closes above zone
    if(currentClose > g_ZoneUpperLevel) {
        g_ClosesAboveZone++;
        LogMessage("📈 Cierre #" + IntegerToString(g_ClosesAboveZone) + " ENCIMA de zona: " + 
                  DoubleToString(currentClose, _Digits), LOG_INFO);
        
        if(g_ClosesAboveZone >= 2 && !g_TradedToday) {
            LogMessage("🚀 SEÑAL COMPRA CONFIRMADA: 2 cierres por encima", LOG_INFO);
            ExecuteBuySignal(currentClose);
        }
    }
    
    // Count closes below zone
    if(currentClose < g_ZoneLowerLevel) {
        g_ClosesBelowZone++;
        LogMessage("📉 Cierre #" + IntegerToString(g_ClosesBelowZone) + " DEBAJO de zona: " + 
                  DoubleToString(currentClose, _Digits), LOG_INFO);
        
        if(g_ClosesBelowZone >= 2 && !g_TradedToday) {
            LogMessage("🚀 SEÑAL VENTA CONFIRMADA: 2 cierres por debajo", LOG_INFO);
            ExecuteSellSignal(currentClose);
        }
    }
}

//+------------------------------------------------------------------+
//| Execute BUY signal with 1:2 Risk:Reward                         |
//+------------------------------------------------------------------+
void ExecuteBuySignal(double entryPrice)
{
    double zoneSize = g_ZoneUpperLevel - g_ZoneLowerLevel;
    
    // SL = Lower zone level
    double sl = g_ZoneLowerLevel;
    
    // TP = Entry + (2 * zone size) for 1:2 R:R
    double tp = entryPrice + (2.0 * zoneSize);
    
    // Normalize prices
    sl = NormalizeDouble(sl, _Digits);
    tp = NormalizeDouble(tp, _Digits);
    
    // Calculate lot size
    double lots = CalculatePositionSize();
    
    LogMessage("📊 PREPARANDO COMPRA:", LOG_INFO);
    LogMessage("   Entry: " + DoubleToString(entryPrice, _Digits), LOG_INFO);
    LogMessage("   SL: " + DoubleToString(sl, _Digits) + " (" + DoubleToString((entryPrice-sl)/_Point, 1) + " pips)", LOG_INFO);
    LogMessage("   TP: " + DoubleToString(tp, _Digits) + " (" + DoubleToString((tp-entryPrice)/_Point, 1) + " pips)", LOG_INFO);
    LogMessage("   Lots: " + DoubleToString(lots, 2), LOG_INFO);
    LogMessage("   R:R = 1:2 (fijo)", LOG_INFO);
    
    // Execute trade
    if(trade.Buy(lots, _Symbol, 0.0, sl, tp, "SimpleNY200_v1.4_BUY")) {
        g_TradedToday = true;
        g_TradesToday++;
        g_CurrentTicket = trade.ResultOrder();
        g_PositionOpen = true;
        LogMessage("✅ COMPRA EJECUTADA - Ticket #" + IntegerToString(g_CurrentTicket), LOG_INFO);
        LogToFile("BUY EXECUTED | Ticket: " + IntegerToString(g_CurrentTicket) + 
                 " | Lots: " + DoubleToString(lots, 2) + 
                 " | Entry: " + DoubleToString(entryPrice, _Digits) +
                 " | SL: " + DoubleToString(sl, _Digits) + 
                 " | TP: " + DoubleToString(tp, _Digits), LOG_INFO);
    } else {
        LogMessage("❌ ERROR ejecutando COMPRA: " + trade.ResultRetcodeDescription(), LOG_ERROR);
        LogToFile("BUY FAILED | Error: " + trade.ResultRetcodeDescription(), LOG_ERROR);
    }
}

//+------------------------------------------------------------------+
//| Execute SELL signal with 1:2 Risk:Reward                        |
//+------------------------------------------------------------------+
void ExecuteSellSignal(double entryPrice)
{
    double zoneSize = g_ZoneUpperLevel - g_ZoneLowerLevel;
    
    // SL = Upper zone level
    double sl = g_ZoneUpperLevel;
    
    // TP = Entry - (2 * zone size) for 1:2 R:R
    double tp = entryPrice - (2.0 * zoneSize);
    
    // Normalize prices
    sl = NormalizeDouble(sl, _Digits);
    tp = NormalizeDouble(tp, _Digits);
    
    // Calculate lot size
    double lots = CalculatePositionSize();
    
    LogMessage("📊 PREPARANDO VENTA:", LOG_INFO);
    LogMessage("   Entry: " + DoubleToString(entryPrice, _Digits), LOG_INFO);
    LogMessage("   SL: " + DoubleToString(sl, _Digits) + " (" + DoubleToString((sl-entryPrice)/_Point, 1) + " pips)", LOG_INFO);
    LogMessage("   TP: " + DoubleToString(tp, _Digits) + " (" + DoubleToString((entryPrice-tp)/_Point, 1) + " pips)", LOG_INFO);
    LogMessage("   Lots: " + DoubleToString(lots, 2), LOG_INFO);
    LogMessage("   R:R = 1:2 (fijo)", LOG_INFO);
    
    // Execute trade
    if(trade.Sell(lots, _Symbol, 0.0, sl, tp, "SimpleNY200_v1.4_SELL")) {
        g_TradedToday = true;
        g_TradesToday++;
        g_CurrentTicket = trade.ResultOrder();
        g_PositionOpen = true;
        LogMessage("✅ VENTA EJECUTADA - Ticket #" + IntegerToString(g_CurrentTicket), LOG_INFO);
        LogToFile("SELL EXECUTED | Ticket: " + IntegerToString(g_CurrentTicket) + 
                 " | Lots: " + DoubleToString(lots, 2) + 
                 " | Entry: " + DoubleToString(entryPrice, _Digits) +
                 " | SL: " + DoubleToString(sl, _Digits) + 
                 " | TP: " + DoubleToString(tp, _Digits), LOG_INFO);
    } else {
        LogMessage("❌ ERROR ejecutando VENTA: " + trade.ResultRetcodeDescription(), LOG_ERROR);
        LogToFile("SELL FAILED | Error: " + trade.ResultRetcodeDescription(), LOG_ERROR);
    }
}

