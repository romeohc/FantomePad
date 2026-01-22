//+------------------------------------------------------------------+
//|                                                       Config.mqh |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// Helpers
string ColorToStringRGB(color clr)
{
   int r = clr & 0xFF;
   int g = (clr >> 8) & 0xFF;
   int b = (clr >> 16) & 0xFF;
   return IntegerToString(r) + "," + IntegerToString(g) + "," + IntegerToString(b);
}

color StringToRGB(string str)
{
   string sb[];
   if(StringSplit(str, ',', sb) == 3)
   {
      int r = (int)StringToInteger(sb[0]);
      int g = (int)StringToInteger(sb[1]);
      int b = (int)StringToInteger(sb[2]);
      return (color)(r | (g << 8) | (b << 16));
   }
   return clrBlack;
}

int HexToInt(string hex)
{
   int res = 0;
   for(int i=0; i<StringLen(hex); i++)
   {
      res *= 16;
      ushort c = StringGetCharacter(hex, i);
      
      if(c >= '0' && c <= '9')      res += (c - '0');
      else if(c >= 'a' && c <= 'f') res += (c - 'a' + 10);
      else if(c >= 'A' && c <= 'F') res += (c - 'A' + 10);
   }
   return res;
}

color HexStringToColor(string hex)
{
   // Nettoyage: suppression du hash et des espaces
   StringReplace(hex, "#", "");
   StringReplace(hex, " ", "");
   
   if(StringLen(hex) != 6) return clrBlack; 
   
   string rStr = StringSubstr(hex, 0, 2);
   string gStr = StringSubstr(hex, 2, 2);
   string bStr = StringSubstr(hex, 4, 2);
   
   // Conversion manuelle fiable (StringToInteger ne gère pas "0x" nativement partout)
   int r = HexToInt(rStr);
   int g = HexToInt(gStr);
   int b = HexToInt(bStr);
   
   return (color)(r | (g << 8) | (b << 16));
}

void SaveConfigToFile()
{
   int handle = FileOpen(ConfigFileName, FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(handle > 0)
   {
      // Format: Key=Value
      FileWrite(handle, "DefaultRisk=" + DoubleToString(g_DefaultRisk, 2));
      FileWrite(handle, "DefaultRiskMoney=" + DoubleToString(g_DefaultRiskMoney, 2));
      FileWrite(handle, "DefaultRiskR=" + DoubleToString(g_DefaultRiskR, 2));
      FileWrite(handle, "OneRPercent=" + DoubleToString(g_OneRPercent, 2));
      FileWrite(handle, "ColorBg=" + IntegerToString(g_ColorBg));
      FileWrite(handle, "ColorHeader=" + IntegerToString(g_ColorHeader));
      FileWrite(handle, "ColorInput=" + IntegerToString(g_ColorInput));
      FileWrite(handle, "ColorText=" + IntegerToString(g_ColorText));
      FileWrite(handle, "ColorLabel=" + IntegerToString(g_ColorLabel));
      FileWrite(handle, "ColorGreen=" + IntegerToString(g_ColorGreen));
      FileWrite(handle, "ColorRed=" + IntegerToString(g_ColorRed));
      FileWrite(handle, "ColorBtnValid=" + IntegerToString(g_ColorBtnValid));
      FileWrite(handle, "ColorBtnInvalid=" + IntegerToString(g_ColorBtnInvalid));
      FileWrite(handle, "ColorChartBg=" + IntegerToString(g_ColorChartBg));
      FileWrite(handle, "ColorChartFg=" + IntegerToString(g_ColorChartFg));
      FileWrite(handle, "ColorEntryLine=" + IntegerToString(g_ColorEntryLine));
      FileWrite(handle, "ColorSLLine=" + IntegerToString(g_ColorSLLine));
      FileWrite(handle, "ColorTPLine=" + IntegerToString(g_ColorTPLine));
      FileWrite(handle, "ColorCandleUp=" + IntegerToString(g_ColorCandleUp));
      FileWrite(handle, "ColorCandleDown=" + IntegerToString(g_ColorCandleDown));
      FileWrite(handle, "ColorListNormal=" + IntegerToString(g_ColorListNormal));
      FileWrite(handle, "ColorListHover=" + IntegerToString(g_ColorListHover));
      
      // Panel States & Positions
      FileWrite(handle, "IsMainPanelVisible=" + IntegerToString(IsMainPanelVisible));
      FileWrite(handle, "PanelX=" + IntegerToString(PanelX));
      FileWrite(handle, "PanelY=" + IntegerToString(PanelY));
      
      FileWrite(handle, "IsPositionsPanelVisible=" + IntegerToString(IsPositionsPanelVisible));
      FileWrite(handle, "PositionsPanelX=" + IntegerToString(PositionsPanelX));
      FileWrite(handle, "PositionsPanelY=" + IntegerToString(PositionsPanelY));
      
      FileWrite(handle, "IsInfoPanelVisible=" + IntegerToString(IsInfoPanelVisible));
      FileWrite(handle, "InfoPanelX=" + IntegerToString(InfoPanelX));
      FileWrite(handle, "InfoPanelY=" + IntegerToString(InfoPanelY));
      
      FileWrite(handle, "IsHistoryPanelVisible=" + IntegerToString(IsHistoryPanelVisible));
      FileWrite(handle, "HistoryPanelX=" + IntegerToString(HistoryPanelX));
      FileWrite(handle, "HistoryPanelY=" + IntegerToString(HistoryPanelY));
      
      FileWrite(handle, "IsSettingsOpen=" + IntegerToString(IsSettingsOpen));
      FileWrite(handle, "SettingsX=" + IntegerToString(SettingsX));
      FileWrite(handle, "SettingsY=" + IntegerToString(SettingsY));
      
      FileClose(handle);
   }
}

void LoadConfig()
{
   if(!FileIsExist(ConfigFileName, FILE_COMMON)) return;
   
   int handle = FileOpen(ConfigFileName, FILE_READ|FILE_TXT|FILE_COMMON);
   if(handle > 0)
   {
      while(!FileIsEnding(handle))
      {
         string str = FileReadString(handle);
         string sep[];
         if(StringSplit(str, '=', sep) == 2)
         {
            string key = sep[0];
            string val = sep[1];
            
            if(key == "DefaultRisk") g_DefaultRisk = StringToDouble(val);
            if(key == "DefaultRiskMoney") g_DefaultRiskMoney = StringToDouble(val);
            if(key == "DefaultRiskR")     g_DefaultRiskR     = StringToDouble(val);
            if(key == "OneRPercent")      g_OneRPercent      = StringToDouble(val);
            if(key == "ColorBg")     g_ColorBg     = (color)StringToInteger(val);
            if(key == "ColorHeader") g_ColorHeader = (color)StringToInteger(val);
            if(key == "ColorInput")  g_ColorInput  = (color)StringToInteger(val);
            if(key == "ColorText")   g_ColorText   = (color)StringToInteger(val);
            if(key == "ColorLabel")  g_ColorLabel  = (color)StringToInteger(val);
            if(key == "ColorGreen")  g_ColorGreen  = (color)StringToInteger(val);
            if(key == "ColorRed")    g_ColorRed    = (color)StringToInteger(val);
            if(key == "ColorBtnValid")   g_ColorBtnValid   = (color)StringToInteger(val);
            if(key == "ColorBtnInvalid") g_ColorBtnInvalid = (color)StringToInteger(val);
            if(key == "ColorChartBg")g_ColorChartBg= (color)StringToInteger(val);
            if(key == "ColorChartFg")g_ColorChartFg= (color)StringToInteger(val);
            if(key == "ColorEntryLine")g_ColorEntryLine= (color)StringToInteger(val);
            if(key == "ColorSLLine")   g_ColorSLLine   = (color)StringToInteger(val);
            if(key == "ColorTPLine")   g_ColorTPLine   = (color)StringToInteger(val);
            if(key == "ColorCandleUp")   g_ColorCandleUp = (color)StringToInteger(val);
            if(key == "ColorCandleDown") g_ColorCandleDown = (color)StringToInteger(val);
            if(key == "ColorListNormal") g_ColorListNormal = (color)StringToInteger(val);
            if(key == "ColorListHover")  g_ColorListHover  = (color)StringToInteger(val);
            
            // Panel States & Positions
            if(key == "IsMainPanelVisible") IsMainPanelVisible = (bool)StringToInteger(val);
            if(key == "PanelX") PanelX = (int)StringToInteger(val);
            if(key == "PanelY") PanelY = (int)StringToInteger(val);
            
            if(key == "IsPositionsPanelVisible") IsPositionsPanelVisible = (bool)StringToInteger(val);
            if(key == "PositionsPanelX") PositionsPanelX = (int)StringToInteger(val);
            if(key == "PositionsPanelY") PositionsPanelY = (int)StringToInteger(val);
            
            if(key == "IsInfoPanelVisible") IsInfoPanelVisible = (bool)StringToInteger(val);
            if(key == "InfoPanelX") InfoPanelX = (int)StringToInteger(val);
            if(key == "InfoPanelY") InfoPanelY = (int)StringToInteger(val);
            
            if(key == "IsHistoryPanelVisible") IsHistoryPanelVisible = (bool)StringToInteger(val);
            if(key == "HistoryPanelX") HistoryPanelX = (int)StringToInteger(val);
            if(key == "HistoryPanelY") HistoryPanelY = (int)StringToInteger(val);
            
            if(key == "IsSettingsOpen") IsSettingsOpen = (bool)StringToInteger(val);
            if(key == "SettingsX") SettingsX = (int)StringToInteger(val);
            if(key == "SettingsY") SettingsY = (int)StringToInteger(val);
         }
      }
      FileClose(handle);
   }
}
