//+------------------------------------------------------------------+
//|                                           Handler_Validation.mqh |
//+------------------------------------------------------------------+
#property strict

// Returns true if event was handled
bool Handle_Validation_Events(string sparam)
{
    // --- VALIDATION ERROR CLOSE BUTTON ---
    if(sparam == PREFIX + "ValErr_Close")
    {
        HideValidationError();
        ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        ChartRedraw();
        return true;
    }
    
    // --- POSITION VALIDATION ERROR CLOSE BUTTON ---
    if(sparam == PREFIX + "PosValErr_Close")
    {
        HidePosValidationError();
        ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        ChartRedraw();
        return true;
    }
    
    return false;
}
