//+------------------------------------------------------------------+
//|                                              Panel_History.mqh   |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

#include "History_Filter.mqh"
#include "History_UI.mqh"

//+------------------------------------------------------------------+
//| CREATION DU PANEL HISTORIQUE                                     |
//+------------------------------------------------------------------+
void CreateHistoryPanel()
{
   if(!g_PanelHistory.IsVisible) return;
   
   int width = 800;
   int rowHeight = 30; 
   int headerHeight = 40;
   int startX = g_PanelHistory.X;
   int startY = g_PanelHistory.Y;
   
   int toolbarHeight = 35;
   int customInputHeight = (g_HistoryFilterMode == H_FILTER_CUSTOM) ? 35 : 0;
   int topSectionHeight = headerHeight + toolbarHeight + customInputHeight;
   int footerHeight = 40;
   int footerMargin = 20;
   
   // 1. Fond & Header
   CreateRect("Hist_Bg", startX, startY, width, topSectionHeight + g_ScrollHistory.ViewportHeight + footerMargin + footerHeight, g_ColorBg, BORDER_FLAT);
   CreateRect("Hist_Header", startX, startY, width, headerHeight, g_ColorBg, BORDER_FLAT);
   CreateLabel("Hist_Title", "Transaction History", startX + 15, startY + 10, 10, g_ColorText, "Trebuchet MS Bold");
   
   // 2. Toolbar
   DrawHistoryToolbar(startX, startY, headerHeight);
   
   // 3. Headings
   int colY = startY + topSectionHeight + 10;
   int colX = startX + 20;
   
   int wTime  = 150;
   int wType  = 100;
   int wSym   = 100;
   int wFees  = 100;
   int wProf  = 120;
   int wRetP  = 90;
   
   CreateLabel("Hist_H_Time", "TIME", colX, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Type", "TYPE", colX + wTime, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Sym",  "SYMBOL", colX + wTime + wType, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Fees", "FEES", colX + wTime + wType + wSym, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Prof", "PROFIT", colX + wTime + wType + wSym + wFees, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_RetP", "RETURN %", colX + wTime + wType + wSym + wFees + wProf, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_RetR", "RETURN R", colX + wTime + wType + wSym + wFees + wProf + wRetP, colY, 8, g_ColorText, "Trebuchet MS Bold");
   
   // 4. Content
   int contentY = colY + 25;
   DrawHistoryContent(startX, contentY, width, rowHeight);
   
   // 5. Scrollbar
   int scrollY = contentY;
   DrawHistoryScrollbar(startX, scrollY, width);
   
   // 6. Footer
   DrawHistoryFooter(startX, startY + topSectionHeight + g_ScrollHistory.ViewportHeight + footerMargin, width, footerHeight);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| TOGGLE                                                           |
//+------------------------------------------------------------------+
void ToggleHistoryPanel(bool visible)
{
   SetObjVisible("Hist_Bg", visible);
   SetObjVisible("Hist_Header", visible);
   SetObjVisible("Hist_Title", visible);
   
   SetObjVisible("Hist_H_Time", visible);
   SetObjVisible("Hist_H_Type", visible);
   SetObjVisible("Hist_H_Sym", visible);
   SetObjVisible("Hist_H_Fees", visible);
   SetObjVisible("Hist_H_Prof", visible);
   SetObjVisible("Hist_H_RetP", visible);
   SetObjVisible("Hist_H_RetR", visible);
   
   SetObjVisible("Hist_Footer_Line", visible);
   SetObjVisible("Hist_Foot_Label", visible);
   SetObjVisible("Hist_Foot_Fees", visible);
   SetObjVisible("Hist_Foot_Prof", visible);
   SetObjVisible("Hist_Foot_RetP", visible);
   SetObjVisible("Hist_Foot_RetR", visible);
   
   SetObjVisible("Hist_ScrollTrack", visible);
   SetObjVisible("Hist_ScrollThumb", visible);
   
   SetObjVisible("Hist_Btn_Daily", visible);
   SetObjVisible("Hist_Btn_Weekly", visible);
   SetObjVisible("Hist_Btn_Monthly", visible);
   SetObjVisible("Hist_Btn_Custom", visible);
   
   SetObjVisible("Hist_Lbl_SymFilter", visible);
   SetObjVisible("Hist_Input_Symbol", visible);
   
   if(visible && g_HistoryFilterMode == H_FILTER_CUSTOM)
   {
       SetObjVisible("Hist_Input_Start", true);
       SetObjVisible("Hist_Input_End", true);
       SetObjVisible("Hist_Lbl_From", true);
       SetObjVisible("Hist_Lbl_To", true);
   }
   else
   {
       SetObjVisible("Hist_Input_Start", false);
       SetObjVisible("Hist_Input_End", false);
       SetObjVisible("Hist_Lbl_From", false);
       SetObjVisible("Hist_Lbl_To", false);
   }
   
   if(!visible)
   {
        for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
        {
            string name = ObjectName(0, i);
            if(StringFind(name, PREFIX + "Hist_Item_") >= 0) ObjectDelete(0, name);
        }
   }
   else
   {
        UpdateHistoryFilter();
        CreateHistoryPanel(); 
   }
}
