//+------------------------------------------------------------------+
//|                                                   ColorManager.mqh |
//|                                              FantomePad Project  |
//|                                          Color Customization Logic |
//+------------------------------------------------------------------+
#ifndef _COLOR_MANAGER_MQH_
#define _COLOR_MANAGER_MQH_

#include "../Core/Defines.mqh"

//+------------------------------------------------------------------+
//| HELPER: APPLY COLOR CHANGE                                       |
//+------------------------------------------------------------------+
void ApplyColorChange(color pickedCol)
{
    if(g_ColorPickerTarget != "")
    {
       ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BGCOLOR, pickedCol);
       ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BORDER_COLOR, pickedCol);
       
       if(StringFind(g_ColorPickerTarget, "_Bg") > 0)          g_ColorBg = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Head") > 0)        g_ColorHeader = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Input") > 0)       g_ColorInput = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Txt") > 0)         g_ColorText = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Green") > 0)       g_ColorGreen = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Red") > 0)         g_ColorRed = (color)pickedCol;
       
       if(StringFind(g_ColorPickerTarget, "_ChrtBg") > 0) {
          g_ColorChartBg = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_BACKGROUND, g_ColorChartBg);
       }
       if(StringFind(g_ColorPickerTarget, "_ChrtFg") > 0) {
           g_ColorChartFg = (color)pickedCol;
           ChartSetInteger(0, CHART_COLOR_FOREGROUND, g_ColorChartFg);
       }
       
       if(StringFind(g_ColorPickerTarget, "_EntLine") > 0)     g_ColorEntryLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_SLLine") > 0)      g_ColorSLLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_TPLine") > 0)      g_ColorTPLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnVal") > 0)      g_ColorBtnValid = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnInv") > 0)      g_ColorBtnInvalid = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnAct") > 0)      g_ColorBtnActive  = (color)pickedCol;
       
       if(StringFind(g_ColorPickerTarget, "_CUp") > 0) {
          g_ColorCandleUp = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, g_ColorCandleUp);
          ChartSetInteger(0, CHART_COLOR_CHART_UP, g_ColorCandleUp);
       }
       if(StringFind(g_ColorPickerTarget, "_CDown") > 0) {
          g_ColorCandleDown = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, g_ColorCandleDown);
          ChartSetInteger(0, CHART_COLOR_CHART_DOWN, g_ColorCandleDown);
       }
       if(StringFind(g_ColorPickerTarget, "_LNorm") > 0)       g_ColorListNormal = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_LHov") > 0)        g_ColorListHover = (color)pickedCol;

       if(StringFind(g_ColorPickerTarget, "_PosInd") > 0)      g_ColorPositive = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_NegInd") > 0)      g_ColorNegative = (color)pickedCol;
       
       SaveConfigToFile();
       RefreshAllPanels();
    }
}

#endif
