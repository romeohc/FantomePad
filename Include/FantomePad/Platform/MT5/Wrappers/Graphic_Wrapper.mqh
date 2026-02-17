//+------------------------------------------------------------------+
//|                                              Graphic_Wrapper.mqh |
//|                                              FantomePad Project  |
//|                                                  (MT5 Specific)  |
//+------------------------------------------------------------------+
#property strict

//--- Wrapper for ObjectCreate
bool FP_ObjectCreate(long chart_id, string name, int type, int nwin, datetime time1, double price1, datetime time2=0, double price2=0)
{
   return ObjectCreate(chart_id, name, (ENUM_OBJECT)type, nwin, time1, price1, time2, price2);
}

//--- Wrapper for ObjectSetInteger
bool FP_ObjectSetInteger(long chart_id, string name, int prop_id, long value)
{
   return ObjectSetInteger(chart_id, name, (ENUM_OBJECT_PROPERTY_INTEGER)prop_id, value);
}

//--- Wrapper for ObjectGetInteger
long FP_ObjectGetInteger(long chart_id, string name, int prop_id, int prop_modifier=0)
{
   return ObjectGetInteger(chart_id, name, (ENUM_OBJECT_PROPERTY_INTEGER)prop_id, prop_modifier);
}

//--- Wrapper for ObjectSetDouble
bool FP_ObjectSetDouble(long chart_id, string name, int prop_id, double value)
{
   return ObjectSetDouble(chart_id, name, (ENUM_OBJECT_PROPERTY_DOUBLE)prop_id, value);
}

//--- Wrapper for ObjectGetDouble
double FP_ObjectGetDouble(long chart_id, string name, int prop_id, int prop_modifier=0)
{
   return ObjectGetDouble(chart_id, name, (ENUM_OBJECT_PROPERTY_DOUBLE)prop_id, prop_modifier);
}

//--- Wrapper for ObjectSetString
bool FP_ObjectSetString(long chart_id, string name, int prop_id, string value)
{
   return ObjectSetString(chart_id, name, (ENUM_OBJECT_PROPERTY_STRING)prop_id, value);
}

//--- Wrapper for ObjectGetString
string FP_ObjectGetString(long chart_id, string name, int prop_id, int prop_modifier=0)
{
   return ObjectGetString(chart_id, name, (ENUM_OBJECT_PROPERTY_STRING)prop_id, prop_modifier);
}

//--- Wrapper for ObjectDelete
bool FP_ObjectDelete(long chart_id, string name)
{
   return ObjectDelete(chart_id, name);
}

//--- Wrapper for ObjectFind
int FP_ObjectFind(long chart_id, string name)
{
   return ObjectFind(chart_id, name);
}
