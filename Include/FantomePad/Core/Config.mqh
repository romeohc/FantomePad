//+------------------------------------------------------------------+
//|                                                       Config.mqh |
//|                                              FantomePad Project  |
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
      // Changed: Default Risks removed
      FileWrite(handle, "OneRPercent=" + DoubleToString(g_OneRPercent, 2));
      FileWrite(handle, "ManagerPosition=" + IntegerToString(g_ManagerPosition));
      FileWrite(handle, "ShowOrderLines=" + IntegerToString(g_ShowOrderLines));
      FileWrite(handle, "ShowPositionLines=" + IntegerToString(g_ShowPositionLines));
      FileWrite(handle, "ColorBg=" + IntegerToString(g_ColorBg));
      FileWrite(handle, "ColorHeader=" + IntegerToString(g_ColorHeader));
      FileWrite(handle, "ColorInput=" + IntegerToString(g_ColorInput));
      FileWrite(handle, "ColorText=" + IntegerToString(g_ColorText));
      // FileWrite(handle, "ColorLabel=" + IntegerToString(g_ColorLabel)); // Removed
      FileWrite(handle, "ColorGreen=" + IntegerToString(g_ColorGreen));
      FileWrite(handle, "ColorRed=" + IntegerToString(g_ColorRed));
      FileWrite(handle, "ColorBtnValid=" + IntegerToString(g_ColorBtnValid));
      FileWrite(handle, "ColorBtnInvalid=" + IntegerToString(g_ColorBtnInvalid));
      FileWrite(handle, "ColorBtnActive=" + IntegerToString(g_ColorBtnActive));
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
      FileWrite(handle, "IsMainPanelVisible=" + IntegerToString(g_PanelMain.IsVisible));
      FileWrite(handle, "PanelX=" + IntegerToString(g_PanelMain.X));
      FileWrite(handle, "PanelY=" + IntegerToString(g_PanelMain.Y));
      
      FileWrite(handle, "IsPositionsPanelVisible=" + IntegerToString(g_PanelPositions.IsVisible));
      FileWrite(handle, "PositionsPanelX=" + IntegerToString(g_PanelPositions.X));
      FileWrite(handle, "PositionsPanelY=" + IntegerToString(g_PanelPositions.Y));
      
      FileWrite(handle, "IsInfoPanelVisible=" + IntegerToString(g_PanelInfo.IsVisible));
      FileWrite(handle, "InfoPanelX=" + IntegerToString(g_PanelInfo.X));
      FileWrite(handle, "InfoPanelY=" + IntegerToString(g_PanelInfo.Y));
      
      FileWrite(handle, "IsHistoryPanelVisible=" + IntegerToString(g_PanelHistory.IsVisible));
      FileWrite(handle, "HistoryPanelX=" + IntegerToString(g_PanelHistory.X));
      FileWrite(handle, "HistoryPanelY=" + IntegerToString(g_PanelHistory.Y));
      
      FileWrite(handle, "IsSettingsOpen=" + IntegerToString(g_PanelSettings.IsVisible));
      FileWrite(handle, "SettingsX=" + IntegerToString(g_PanelSettings.X));
      FileWrite(handle, "SettingsY=" + IntegerToString(g_PanelSettings.Y));
      
      // Save Palette
      string palStr = "";
      for(int i=0; i<ArraySize(g_ColorPalette); i++) {
         if(i > 0) palStr += ",";
         palStr += IntegerToString(g_ColorPalette[i]);
      }
      FileWrite(handle, "UserPalette=" + palStr);
      
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
            
            if(key == "OneRPercent")      g_OneRPercent      = StringToDouble(val);
            if(key == "ManagerPosition")  g_ManagerPosition  = (int)StringToInteger(val);
            if(key == "ShowOrderLines")   g_ShowOrderLines   = (bool)StringToInteger(val);
            if(key == "ShowPositionLines")g_ShowPositionLines= (bool)StringToInteger(val);
            if(key == "ColorBg")     g_ColorBg     = (color)StringToInteger(val);
            if(key == "ColorHeader") g_ColorHeader = (color)StringToInteger(val);
            if(key == "ColorInput")  g_ColorInput  = (color)StringToInteger(val);
      if(key == "ColorText")   g_ColorText   = (color)StringToInteger(val);
            // Removed ColorLabel and ColorChartFg as requested to simplify to single text color
            if(key == "ColorGreen")  g_ColorGreen  = (color)StringToInteger(val);
            if(key == "ColorRed")    g_ColorRed    = (color)StringToInteger(val);
            if(key == "ColorBtnValid")   g_ColorBtnValid   = (color)StringToInteger(val);
            if(key == "ColorBtnInvalid") g_ColorBtnInvalid = (color)StringToInteger(val);
            if(key == "ColorBtnActive")  g_ColorBtnActive  = (color)StringToInteger(val);
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
            if(key == "IsMainPanelVisible") g_PanelMain.IsVisible = (bool)StringToInteger(val);
            if(key == "PanelX") g_PanelMain.X = (int)StringToInteger(val);
            if(key == "PanelY") g_PanelMain.Y = (int)StringToInteger(val);
            
            if(key == "IsPositionsPanelVisible") g_PanelPositions.IsVisible = (bool)StringToInteger(val);
            if(key == "PositionsPanelX") g_PanelPositions.X = (int)StringToInteger(val);
            if(key == "PositionsPanelY") g_PanelPositions.Y = (int)StringToInteger(val);
            
            if(key == "IsInfoPanelVisible") g_PanelInfo.IsVisible = (bool)StringToInteger(val);
            if(key == "InfoPanelX") g_PanelInfo.X = (int)StringToInteger(val);
            if(key == "InfoPanelY") g_PanelInfo.Y = (int)StringToInteger(val);
            
            if(key == "IsHistoryPanelVisible") g_PanelHistory.IsVisible = (bool)StringToInteger(val);
            if(key == "HistoryPanelX") g_PanelHistory.X = (int)StringToInteger(val);
            if(key == "HistoryPanelY") g_PanelHistory.Y = (int)StringToInteger(val);
            
            if(key == "IsSettingsOpen") g_PanelSettings.IsVisible = (bool)StringToInteger(val);
            if(key == "SettingsX") g_PanelSettings.X = (int)StringToInteger(val);
            if(key == "SettingsY") g_PanelSettings.Y = (int)StringToInteger(val);
            
            if(key == "UserPalette") {
               string cols[];
               if(StringSplit(val, ',', cols) > 0) {
                  ArrayResize(g_ColorPalette, ArraySize(cols));
                  for(int i=0; i<ArraySize(cols); i++) g_ColorPalette[i] = (color)StringToInteger(cols[i]);
               }
            }
         }
      }
      FileClose(handle);
   }
}
