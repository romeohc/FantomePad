//+------------------------------------------------------------------+
//|                                              Panel_Auth.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_AUTH_MQH_
#define _PANEL_AUTH_MQH_

#include "Panel_Auth_UI.mqh"
#include "../../Core/Security.mqh"
#include "../../Core/Config.mqh"

// RefreshAllPanels is now handled via CGUI_Master in Components.mqh

void OnClick_AuthActivate()
{
   string code = ObjectGetString(0, PREFIX + "Auth_Input", OBJPROP_TEXT);
   StringTrimLeft(code);
   StringTrimRight(code);
   StringReplace(code, "\"", "");
   StringReplace(code, "\\", "");
   
   UpdateAuthStatus("Vérification en cours...", clrWhite);
   
   if(CheckLicense(code))
   {
      g_IsLicensed = true;
      g_ActivationCode = code;
      
      // Save the validated code to persistence
      SaveConfigToFile();
      
      // Success feedback
      UpdateAuthStatus("Licence Activée !", g_ColorGreen);
      Sleep(500);
      
      // Hide Auth Panel and showing the real interface
      ShowAuthPanel(false);
      
      // Cleanup auth objects
      ObjectsDeleteAll(0, PREFIX + "Auth_");
      
      // Trigger full UI refresh
      RefreshAllPanels();
   }
   else
   {
      string error = (g_AuthErrorMsg != "") ? g_AuthErrorMsg : "Erreur de connexion";
      UpdateAuthStatus(error, g_ColorRed);
      g_IsLicensed = false;
   }
   
   ChartRedraw();
}

#endif
