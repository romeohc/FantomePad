//+------------------------------------------------------------------+
//|                                     Handler_SymbolManager.mqh    |
//|                                        FantomePad Project        |
//+------------------------------------------------------------------+
#property strict

bool Handle_SymbolManager_Events(string sparam)
{
    // 1. OPEN MANAGER (From Navigation Panel)
    if(sparam == PREFIX + "List_Btn_Add")
    {
        FP_ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        CloseSymbolList();
        ToggleSymbolManager(true);
        return true;
    }

    if(!g_PanelSymbolManager.IsVisible) return false;

    // 2. CLOSE MANAGER
    if(sparam == PREFIX + "SYM_Btn_Close")
    {
        FP_ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        ToggleSymbolManager(false);
        return true;
    }
    
    // 3. CATEGORY SELECTION
    if(StringFind(sparam, PREFIX + "SYM_Cat_") >= 0)
    {
        string sub = StringSubstr(sparam, StringLen(PREFIX + "SYM_Cat_"));
        int idx = (int)StringToInteger(sub);
        
        if(idx >= 0 && idx < g_SymMgr_CategoryCount)
        {
            g_SymMgr_CurrentCategory = g_SymMgr_Categories[idx];
            LoadSymbolsForCategory(g_SymMgr_CurrentCategory);
            FP_ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
            RefreshAllPanels();
        }
        return true;
    }
    

    
    // 5. SYMBOL SELECTION (Toggle Logic: Add/Remove)
    if(StringFind(sparam, PREFIX + "SYM_Sym_") >= 0)
    {
        string sub = StringSubstr(sparam, StringLen(PREFIX + "SYM_Sym_"));
        int visIdx = (int)StringToInteger(sub);
        int realIdx = g_SymMgr_ScrollOffset + visIdx;
        
        if(realIdx >= 0 && realIdx < g_SymMgr_SymbolCount)
        {
            string sym = g_SymMgr_SymbolsInCat[realIdx];
            
            // Détecter l'état actuel (Présent dans le Market Watch ou non)
            bool isInMarket = (bool)SymbolInfoInteger(sym, SYMBOL_SELECT);
            
            // Inverser l'état
            if(SymbolSelect(sym, !isInMarket))
            {
                // On rafraîchit la vue pour mettre à jour la couleur
                CreateSymbolManagerPanel();
                ChartRedraw();
            }
        }
        FP_ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        return true;
    }
    
    return false;
}
