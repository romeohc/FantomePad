//+------------------------------------------------------------------+
//|                                                  HttpManager.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _HTTP_MANAGER_MQH_
#define _HTTP_MANAGER_MQH_

#property strict
#include "../Defines.mqh"

//+------------------------------------------------------------------+
//| HTTP Manager Class (Singleton/Static)                            |
//| Dedicated to handling WebRequests safely across MT4 and MT5      |
//+------------------------------------------------------------------+
class C_HttpManager
{
public:
   //+------------------------------------------------------------------+
   //| Send a POST request with JSON payload                            |
   //| Returns: HTTP Status Code (200, 404...) or MQL Error (4060, -1)  |
   //+------------------------------------------------------------------+
   static int Post(string url, string payload, string &response, int timeout=5000)
   {
      char data[];
      char result[];
      string result_headers;
      
      // 1. Prepare Data (String -> CharArray)
      // Note: We use StringLen to avoid including the null terminator in the payload if not needed,
      // but usually for JSON it's fine. 
      StringToCharArray(payload, data, 0, StringLen(payload));
      
      // 2. Prepare Headers
      string headers = "Content-Type: application/json\r\n";
      
      // 3. Reset Errors
      ResetLastError();
      
      // 4. Execute Request
      // WebRequest is synchronous in EAs.
      // Timeout is in milliseconds.
      int res = WebRequest("POST", url, headers, timeout, data, result, result_headers);
      int lastError = GetLastError();
      
      // 5. Handle Errors
      if(res == -1)
      {
         // MQL4/5 Specific Errors
         if(lastError == 4060) return 4060; // ERR_FUNCTION_NOT_ALLOWED (URL not allowed)
         if(lastError == 4014) return 4014; // ERR_NOT_ALLOWED_IN_TESTING (DLL/WebRequest not allowed)
         return -1; // Unknown connection error
      }
      
      // 6. Process Response (CharArray -> String)
      if(ArraySize(result) > 0)
      {
         response = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
      }
      else
      {
         response = "";
      }
      
      // Return the HTTP Status Code (e.g., 200)
      return res; 
   }
};

#endif
