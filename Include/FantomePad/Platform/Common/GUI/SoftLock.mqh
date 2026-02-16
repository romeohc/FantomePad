//+------------------------------------------------------------------+
//|                                                     SoftLock.mqh |
//|                                              FantomePad Project  |
//|                                        Security & Soft Lock Logic |
//+------------------------------------------------------------------+
#ifndef _SOFT_LOCK_MQH_
#define _SOFT_LOCK_MQH_

#include "../Core/Defines.mqh"

//+------------------------------------------------------------------+
//| HELPER: APPLY SOFT LOCK MODE (Security UI)                             |
//+------------------------------------------------------------------+
void ApplySoftLockMode()
{
    // 1. Force hide all non-essential panels and update their State flags
    if(g_PanelMain.IsVisible) { g_PanelMain.IsVisible = false; ToggleMainPanel(false); }
    if(g_PanelAccount.IsVisible) { g_PanelAccount.IsVisible = false; ToggleAccountPanel(false); }
    if(g_PanelHistory.IsVisible) { g_PanelHistory.IsVisible = false; ToggleHistoryPanel(false); }
    
    // Explicit Settings Cleanup (Correcting Prefix from Settings_ to Set_)
    if(g_PanelSettings.IsVisible) 
    {
        ObjectsDeleteAll(0, PREFIX + "Set_"); 
        g_PanelSettings.IsVisible = false;
    }
    
    // 2. Ensure Positions Panel is visible and state is correct
    if(!g_PanelPositions.IsVisible) 
    {
        g_PanelPositions.IsVisible = true;
        TogglePositionsPanel(true);
    }
    
    // 3. Show Alert Banner (Red)
    string alertName = PREFIX + "LicenseAlert";
    if(ObjectFind(0, alertName) < 0)
    {
        ObjectCreate(0, alertName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, alertName, OBJPROP_XDISTANCE, 0);
        ObjectSetInteger(0, alertName, OBJPROP_YDISTANCE, 0);
        ObjectSetInteger(0, alertName, OBJPROP_XSIZE, (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
        ObjectSetInteger(0, alertName, OBJPROP_YSIZE, 30);
        ObjectSetInteger(0, alertName, OBJPROP_BGCOLOR, g_ColorRed);
        ObjectSetInteger(0, alertName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, alertName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    }
    
    string alertTxt = PREFIX + "LicenseAlertTxt";
    
    // Simplified logic for reasons
    string reason = "VERIFICATION FAILED";
    string errLower = g_AuthErrorMsg;
    StringToLower(errLower);

    if(StringFind(errLower, "code") >= 0 || StringFind(errLower, "incorrect") >= 0 || StringFind(errLower, "chang") >= 0)
        reason = "INVALID ACTIVATION CODE";
    else if(StringFind(errLower, "hardware") >= 0 || StringFind(errLower, "id") >= 0 || StringFind(errLower, "appareil") >= 0 || StringFind(errLower, "activé") >= 0)
        reason = "DEVICE MISMATCH";
    else if(StringFind(errLower, "bloqué") >= 0 || StringFind(errLower, "blocked") >= 0 || StringFind(errLower, "status") >= 0)
        reason = "ACCOUNT BLOCKED";
    else if(StringFind(errLower, "certificat") >= 0 || StringFind(errLower, "token") >= 0)
        reason = "CERTIFICATE ERROR";

    // ULTRA-SIMPLIFIED BOLD MESSAGE
    string fullMsg = reason + " - contact@fantomepad.com";
    int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

    if(ObjectFind(0, alertTxt) < 0)
    {
        ObjectCreate(0, alertTxt, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, alertTxt, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, alertTxt, OBJPROP_YDISTANCE, 7); 
        ObjectSetString(0, alertTxt, OBJPROP_FONT, "Trebuchet MS Bold"); // Use a naturally bolder font
        ObjectSetInteger(0, alertTxt, OBJPROP_FONTSIZE, 10); // Slightly larger
        ObjectSetInteger(0, alertTxt, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, alertTxt, OBJPROP_ANCHOR, ANCHOR_UPPER); 
    }
    
    // Exact center position
    ObjectSetInteger(0, alertTxt, OBJPROP_XDISTANCE, chartW / 2);
    ObjectSetString(0, alertTxt, OBJPROP_TEXT, fullMsg);
    
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| HELPER: CLEAR SOFT LOCK UI                                       |
//+------------------------------------------------------------------+
void ClearSoftLockUI()
{
    ObjectDelete(0, PREFIX + "LicenseAlert");
    ObjectDelete(0, PREFIX + "LicenseAlertTxt");
    ChartRedraw();
}


//+------------------------------------------------------------------+
//| CORE: INITIAL LICENSE CHECK                                      |
//+------------------------------------------------------------------+
void HandleInitialLicenseCheck()
{
   if(g_ActivationCode != "")
   {
      if(CheckLicense(g_ActivationCode)) 
      {
         g_IsLicensed = true;
         g_LicenseState = LICENSE_OK;
      }
      else
      {
         if(OrdersTotal() > 0)
         {
             Print("FantomePad: License invalid but positions open. Entering Soft Lock.");
             g_IsLicensed = false; 
             g_LicenseState = LICENSE_REVOKED;
         }
         else
         {
             g_IsLicensed = false;
             g_LicenseState = LICENSE_NONE;
         }
      }
   }
   else if(OrdersTotal() > 0)
   {
       g_IsLicensed = false;
       g_LicenseState = LICENSE_REVOKED;
   }
}

//+------------------------------------------------------------------+
//| CORE: LICENSE HEARTBEAT (TIMER)                                  |
//+------------------------------------------------------------------+
void HandleLicenseHeartbeat()
{
   static uint lastHeartbeat = 0;
   if(lastHeartbeat == 0 && GlobalVariableCheck("FantomePad_LastHeartbeat"))
   {
      lastHeartbeat = (uint)GlobalVariableGet("FantomePad_LastHeartbeat");
      GlobalVariableDel("FantomePad_LastHeartbeat");
   }
   
   uint now = GetTickCount();
   
   if((g_IsLicensed || g_LicenseState == LICENSE_REVOKED) && (now - lastHeartbeat > 1800000 || lastHeartbeat == 0)) 
   {
      if(now - g_LastInteractionTime > 60000) 
      {
         lastHeartbeat = now;
         bool isValid = CheckLicense(g_ActivationCode, 1500);
         
         if(!isValid)
         {
             if(g_AuthErrorMsg != "" && StringFind(g_AuthErrorMsg, "Serveur injoignable") < 0)
             {
                 Print("FantomePad: License Revoked/Invalidated. Enhancing Security.");
                 g_IsLicensed = false; 
                 g_LicenseState = LICENSE_REVOKED;
                 ApplySoftLockMode();
             }
         }
         else
         {
             if(g_LicenseState == LICENSE_REVOKED || g_LicenseState == LICENSE_NONE)
             {
                 g_LicenseState = LICENSE_OK;
                 g_IsLicensed = true;
                 ClearSoftLockUI();
                 RefreshAllPanels();
             }
         }
      }
   }

   if(g_LicenseState == LICENSE_REVOKED)
   {
       if(OrdersTotal() == 0)
       {
           Print("FantomePad: No more positions. Redirecting to Auth.");
           g_LicenseState = LICENSE_NONE;
           g_IsLicensed = false;
           GUI_OnInit(); 
           return;
       }
       ApplySoftLockMode();
       
       if(!g_PanelPositions.IsVisible) TogglePositionsPanel(true);
       if(g_PanelMain.IsVisible) ToggleMainPanel(false);
       if(g_PanelAccount.IsVisible) ToggleAccountPanel(false);
       if(g_PanelHistory.IsVisible) ToggleHistoryPanel(false);
       if(g_PanelSettings.IsVisible) ToggleSettings(); 
   }
}

#endif
