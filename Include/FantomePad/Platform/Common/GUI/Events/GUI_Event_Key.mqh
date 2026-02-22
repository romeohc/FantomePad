//+------------------------------------------------------------------+
//|                                               GUI_Event_Key.mqh  |
//+------------------------------------------------------------------+
#property strict

#include "KeyHelpers.mqh"

// --- Sequence Config ---
#define SEQ_COUNT 5        // 5 keys sequence for maximum security
#define SEQ_TIMEOUT_MS 200 // Total sequence must be sent under 200ms (Impossible for humans)

//+------------------------------------------------------------------+
//| EVENT: KEY DOWN                                                  |
//+------------------------------------------------------------------+
void OnEvent_Key(long lparam)
{
   static int seq[SEQ_COUNT] = {-1, -1, -1, -1, -1};
   static uint lastKeyTime = 0;
   
   // 1. Filter Numpad Digits Only (0-9)
   int digit = -1;
   if(lparam >= 96 && lparam <= 105) digit = (int)lparam - 96;
   // Fallback System codes (NumLock Off)
   else if(lparam == 45) digit = 0;
   else if(lparam == 35) digit = 1;
   else if(lparam == 40) digit = 2;
   else if(lparam == 34) digit = 3;
   else if(lparam == 37) digit = 4;
   else if(lparam == 12) digit = 5;
   else if(lparam == 39) digit = 6;
   else if(lparam == 36) digit = 7;
   else if(lparam == 38) digit = 8;
   else if(lparam == 33) digit = 9;
   
   if(digit == -1) return; // Not a numpad digit
   
   // 2. Manage Sequence Timing
   uint currentTime = GetTickCount();
   
   // If the gap between ANY two keys is too large (> 150ms per key) 
   // or if the whole sequence is too slow, we reset.
   if(currentTime - lastKeyTime > 150)
   {
      for(int i=0; i<SEQ_COUNT; i++) seq[i] = -1;
   }
   
   // 3. Update Sequence (Shift Left)
   for(int i=0; i<SEQ_COUNT-1; i++) seq[i] = seq[i+1];
   seq[SEQ_COUNT-1] = digit;
   lastKeyTime = currentTime;
   
   // 4. Match Sequence to Command
   if(seq[0] == -1) return;
   
   // Convert to long code: 91911
   long cmdCode = 0;
   long multiplier = 1;
   for(int i=SEQ_COUNT-1; i>=0; i--)
   {
      cmdCode += seq[i] * multiplier;
      multiplier *= 10;
   }
   
   bool changed = false;
   bool forceUIRefresh = false;
   bool executed = false;
   
   // --- LICENSE REVOKED GUARD FOR KEYS ---
   bool isTradeCmd = (cmdCode >= 91911 && cmdCode <= 91915); // BUY, SELL, LIMIT, STOP, RISK
   if(g_LicenseState == LICENSE_REVOKED && isTradeCmd)
   {
       Print("FantomePad: Key Command Blocked (License Revoked)");
       // Clear sequence to prevent partial matches
       for(int i=0; i<SEQ_COUNT; i++) seq[i] = -1;
       return;
   }

   // --- SECURITY COMMAND MAPPING (9191X & 8282X) ---
   
   if(cmdCode == 91911) // BUY
   {
      EnsureTradePanel();
      if(g_PanelMain.IsVisible) InvertTradeInputs(CurrentDirection, 0, CurrentTypeIndex, 0);
      CurrentTypeIndex = 0; CurrentDirection = 0;
      changed = true; executed = true;
   }
   else if(cmdCode == 91912) // SELL
   {
      EnsureTradePanel();
      if(g_PanelMain.IsVisible) InvertTradeInputs(CurrentDirection, 1, CurrentTypeIndex, 0);
      CurrentTypeIndex = 0; CurrentDirection = 1;
      changed = true; executed = true;
   }
   else if(cmdCode == 91913) // LIMIT
   {
      EnsureTradePanel();
      int newType = (CurrentDirection == 0) ? 1 : 2;
      if(g_PanelMain.IsVisible) InvertTradeInputs(CurrentDirection, CurrentDirection, CurrentTypeIndex, newType);
      if(CurrentDirection == 0) CurrentTypeIndex = 1; else CurrentTypeIndex = 2;
      changed = true; executed = true;
   }
   else if(cmdCode == 91914) // STOP
   {
      EnsureTradePanel();
      int newType = (CurrentDirection == 0) ? 3 : 4;
      if(g_PanelMain.IsVisible) InvertTradeInputs(CurrentDirection, CurrentDirection, CurrentTypeIndex, newType);
      if(CurrentDirection == 0) CurrentTypeIndex = 3; else CurrentTypeIndex = 4;
      changed = true; executed = true;
   }
   else if(cmdCode == 91915) // RISK BUTTON (Toggle Mode)
   {
      EnsureTradePanel();
      RiskMode++; if(RiskMode > 2) RiskMode = 0;
      
      // Reset risk value on switch to avoid carrying over large numbers (e.g. 500$ -> 500%)
      string resetVal = (RiskMode == 1) ? "0" : "0.0";
      FP_ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, resetVal);
      
      changed = true; executed = true;
   }
   else if(cmdCode == 91916) // BE
   {
      EnsurePositionPanel();
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_BE");
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 91917) // 25%
   {
      EnsurePositionPanel();
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_25");
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 91918) // 50%
   {
      EnsurePositionPanel();
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_50");
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 91919) // 100%
   {
      EnsurePositionPanel();
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_100");
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 82821) // NEXT
   {
      EnsurePositionPanel();
      SelectNextPosition();
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 82822) // VALIDATE
   {
      ExecuteGlobalValidate();
      executed = true;
   }
   else if(cmdCode == 82820) // CANCEL
   {
      ExecuteGlobalCancel();
      forceUIRefresh = true; executed = true;
   }
   
   // --- WHEEL COMMANDS ---
   else if(cmdCode == 77771) // WHEEL RIGHT (Increase Risk)
   {
      AdjustRisk(1.0);
      executed = true;
   }
   else if(cmdCode == 77772) // WHEEL LEFT (Decrease Risk)
   {
      AdjustRisk(-1.0);
      executed = true;
   }
   else if(cmdCode == 77770) // WHEEL CLICK (Reset Risk)
   {
      ResetRisk();
      executed = true;
   }
   
   // --- SECOND WHEEL COMMANDS (Symbols) ---
   else if(cmdCode == 66661) // WHEEL RIGHT (Next Symbol)
   {
      NavigateSymbols(1);
      executed = true;
   }
   else if(cmdCode == 66662) // WHEEL LEFT (Prev Symbol)
   {
      NavigateSymbols(-1);
      executed = true;
   }
   else if(cmdCode == 66660) // WHEEL CLICK (Select Symbol)
   {
      SelectSymbol();
      executed = true;
   }

   if(executed)
   {
      for(int i=0; i<SEQ_COUNT; i++) seq[i] = -1;
      
      if(changed) 
      {
         UpdateUIMode();
         UpdateCalculatedLot();
      }
      UpdateNavigationPanel();
      ChartRedraw();
   }
}
