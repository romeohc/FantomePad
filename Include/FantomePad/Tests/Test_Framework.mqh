//+------------------------------------------------------------------+
//|                                              Test_Framework.mqh  |
//+------------------------------------------------------------------+
#property strict

int g_TestsPassed = 0;
int g_TestsFailed = 0;
string g_LastError = "";
string g_TestFailures[]; // Stores list of failure messages

void AssertTrue(bool condition, string message)
{
   if(condition)
   {
      g_TestsPassed++;
      // Optional: Print("PASS: ", message);
   }
   else
   {
      g_TestsFailed++;
      g_LastError = message; // Capture finding
      Print("FAILED: ", message);
      
      // Store failure for chart display
      int size = ArraySize(g_TestFailures);
      ArrayResize(g_TestFailures, size + 1);
      g_TestFailures[size] = "FAILED: " + message;
   }
}

void AssertEquals(double expected, double actual, string message, double epsilon=0.00001)
{
   if(MathAbs(expected - actual) < epsilon)
   {
      g_TestsPassed++;
   }
   else
   {
      g_TestsFailed++;
      string errorDetail = message + " | Exp: " + DoubleToString(expected, 5) + " Got: " + DoubleToString(actual, 5);
      g_LastError = errorDetail;
      Print("FAILED: ", errorDetail);
      
      // Store failure for chart display
      int size = ArraySize(g_TestFailures);
      ArrayResize(g_TestFailures, size + 1);
      g_TestFailures[size] = "FAILED: " + errorDetail;
   }
}

void DisplayChartReport()
{
   string prefix = "TestReport_";
   ObjectsDeleteAll(0, prefix);
   
   int yBase = 30;
   int rowHeight = 20;
   
   // Summary Label
   string summaryName = prefix + "Summary";
   string summaryText = (g_TestsFailed == 0) ? "✅ ALL TESTS PASSED (" + IntegerToString(g_TestsPassed) + ")" : "❌ TEST FAILED: " + IntegerToString(g_TestsFailed) + " ERRORS";
   color  summaryColor = (g_TestsFailed == 0) ? clrLime : clrRed;
   
   ObjectCreate(0, summaryName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, summaryName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, summaryName, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, summaryName, OBJPROP_YDISTANCE, yBase);
   ObjectSetString(0, summaryName, OBJPROP_TEXT, summaryText);
   ObjectSetInteger(0, summaryName, OBJPROP_COLOR, summaryColor);
   ObjectSetInteger(0, summaryName, OBJPROP_FONTSIZE, 14);
   
   yBase += 30;
   
   // If failures, list them
   if (g_TestsFailed > 0)
   {
      for(int i=0; i<ArraySize(g_TestFailures); i++)
      {
         string lblName = prefix + "Error_" + IntegerToString(i);
         ObjectCreate(0, lblName, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, lblName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, lblName, OBJPROP_XDISTANCE, 20);
         ObjectSetInteger(0, lblName, OBJPROP_YDISTANCE, yBase + (i * rowHeight));
         ObjectSetString(0, lblName, OBJPROP_TEXT, g_TestFailures[i]);
         ObjectSetInteger(0, lblName, OBJPROP_COLOR, clrRed);
         ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 10);
         
         // Limit display to 20 errors to avoid overflow
         if (i >= 19) {
             string moreParams = prefix + "More";
             ObjectCreate(0, moreParams, OBJ_LABEL, 0, 0, 0);
             ObjectSetInteger(0, moreParams, OBJPROP_CORNER, CORNER_LEFT_UPPER);
             ObjectSetInteger(0, moreParams, OBJPROP_XDISTANCE, 20);
             ObjectSetInteger(0, moreParams, OBJPROP_YDISTANCE, yBase + ((i+1) * rowHeight));
             ObjectSetString(0, moreParams, OBJPROP_TEXT, "... Check Experts tab for full logs ...");
             ObjectSetInteger(0, moreParams, OBJPROP_COLOR, clrRed);
             break;
         }
      }
   }
   
   ChartRedraw();
}

void PrintTestSummary()
{
   Print("--------------------------------------------------");
   Print("TEST RESULTS SUMMARY");
   Print("PASSED: ", g_TestsPassed);
   Print("FAILED: ", g_TestsFailed);
   Print("--------------------------------------------------");
   
   DisplayChartReport();
   
   if(g_TestsFailed == 0) 
   {
      Alert("✅ ALL TESTS PASSED (", g_TestsPassed, ")");
   }
   else 
   {
      Alert("❌ ", g_TestsFailed, " TESTS FAILED\nCheck Chart/Logs for details.");
   }
}
