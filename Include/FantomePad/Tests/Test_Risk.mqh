//+------------------------------------------------------------------+
//|                                                Test_Risk.mqh     |
//+------------------------------------------------------------------+
#property strict

// On suppose que Trade.mqh est inclus par le Runner
// On suppose que Test_Framework.mqh est inclus

void Setup_RiskTest()
{
   // Création des objets graphiques nécessaires (Mocking)
   // Ils doivent exister pour que ObjectGetString fonctionne
   
   string editPrice = PREFIX + "Edit_Price";
   string editSL    = PREFIX + "Edit_SL";
   string editRisk  = PREFIX + "Edit_Risk";
   string btnSymbol = PREFIX + "Btn_SymbolSelect";
   
   if(ObjectFind(0, editPrice) < 0) ObjectCreate(0, editPrice, OBJ_EDIT, 0, 0, 0);
   if(ObjectFind(0, editSL) < 0)    ObjectCreate(0, editSL, OBJ_EDIT, 0, 0, 0);
   if(ObjectFind(0, editRisk) < 0)  ObjectCreate(0, editRisk, OBJ_EDIT, 0, 0, 0);
   if(ObjectFind(0, btnSymbol) < 0) ObjectCreate(0, btnSymbol, OBJ_BUTTON, 0, 0, 0);
   
   // Reset symbol to Current
   ObjectSetString(0, btnSymbol, OBJPROP_TEXT, Symbol());
}

void Cleanup_RiskTest()
{
   // Nettoyage
   ObjectDelete(0, PREFIX + "Edit_Price");
   ObjectDelete(0, PREFIX + "Edit_SL");
   ObjectDelete(0, PREFIX + "Edit_Risk");
   ObjectDelete(0, PREFIX + "Btn_SymbolSelect");
}

void Test_CalculateLotSize_RiskPercent()
{
   Print("Running Test_CalculateLotSize_RiskPercent...");
   
   // 1. SETUP GLOBAL STATE
   RiskMode = 0; // % Risk
   
   // 2. SETUP MOCKS
   // Correction: Since we can't change AccountBalance(), we must calculate expected result dynamically.
   double balance = AccountEquity(); // Code uses Equity for %
   double riskPerc = 1.0; 
   double riskMoney = balance * 0.01;
   
   // Safer: Choose a symbol and rely on market info.
   double entry = MarketInfo(Symbol(), MODE_ASK);
   double point = MarketInfo(Symbol(), MODE_POINT);
   
   // Avoid 0 point
   if(point == 0) point = 0.00001;
   
   double sl = entry - 100 * point; // 100 points distance
   
   // Set Text
   ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, DoubleToString(entry, 5));
   ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, DoubleToString(sl, 5));
   ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, DoubleToString(riskPerc, 1));
   
   // 3. EXECUTE
   double calculatedLots = CalculateLotSize(entry, sl, riskPerc);
   
   // 4. VERIFY
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
   
   if(tickSize == 0 || tickVal == 0) {
      Print("Skipping lot calc test due to invalid symbol info");
      return;
   }

   double dist = MathAbs(entry - sl);
   double steps = dist / tickSize;
   double expectedRaw = riskMoney / (steps * tickVal);
   
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   if(lotStep == 0) lotStep = 0.01;
   
   double expected = MathFloor(expectedRaw / lotStep) * lotStep;
   if(expected < minLot) expected = minLot;
   if(expected > maxLot) expected = maxLot;
   
   AssertEquals(expected, calculatedLots, "Lot Calculation Risk %");
}

void Test_CalculateLotSize_RiskMoney()
{
   Print("Running Test_CalculateLotSize_RiskMoney...");
   
   RiskMode = 1; // Money
   double riskCash = 50.0;
   
   // Use checks relative to current symbol to avoid Point/TickSize issues on Indices/Crypto
   double point = MarketInfo(Symbol(), MODE_POINT);
   if(point == 0) point = 0.00001;
   
   double entry = MarketInfo(Symbol(), MODE_ASK); 
   if(entry == 0) entry = 1.0; // Fallback for offline/init
   
   double sl = entry - 500 * point; // 500 points distance (approx 50 pips)
   
   ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, DoubleToString(entry, 5));
   ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, DoubleToString(sl, 5));
   ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, DoubleToString(riskCash, 2));
   
   double lots = CalculateLotSize(entry, sl, riskCash);
   
   // Verify > 0
   AssertTrue(lots > 0, "Lot Size Money > 0");
}
