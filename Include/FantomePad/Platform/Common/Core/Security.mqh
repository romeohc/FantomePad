//+------------------------------------------------------------------+
//|                                                   Security.mqh   |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _SECURITY_MQH_
#define _SECURITY_MQH_

#property strict
#include "Defines.mqh"

//+------------------------------------------------------------------+
//| Generate a unique Hardware ID for the machine                    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Get a stable Session Name from the common path                   |
//+------------------------------------------------------------------+
string GetSessionID()
{
   string path = TerminalInfoString(TERMINAL_COMMONDATA_PATH);
   int cpu = (int)TerminalInfoInteger(TERMINAL_CPU_CORES);
   StringReplace(path, "\\", "/");
   
   string sessionName = "unknown";
   string pathLower = path;
   StringToLower(pathLower);
   
   int start = StringFind(pathLower, "users/");
   if(start >= 0)
   {
      string sub = StringSubstr(path, start + 6);
      int end = StringFind(sub, "/");
      if(end > 0) sessionName = StringSubstr(sub, 0, end);
      else sessionName = sub;
   }
   else 
   {
      // Fallback : prendre la fin du chemin
      int len = StringLen(path);
      sessionName = (len > 15) ? StringSubstr(path, len - 15) : path;
      StringReplace(sessionName, "/", "-");
   }
   
   // On combine Session + CPU pour une unicité maximale sans DLL
   return "ID-" + sessionName + "-" + IntegerToString(cpu);
}

//+------------------------------------------------------------------+
//| Manage the Secret Token file (Internal Certificate)              |
//+------------------------------------------------------------------+
string GetSecretToken()
{
   string fileName = "fantome_cert.dat";
   int handle = FileOpen(fileName, FILE_READ|FILE_BIN|FILE_COMMON);
   
   if(handle != INVALID_HANDLE)
   {
      string token = FileReadString(handle);
      FileClose(handle);
      if(token != "") return token;
   }
   
   // Si le fichier n'existe pas, on générera un token lors de l'activation
   return "";
}

void SaveSecretToken(string token)
{
   string fileName = "fantome_cert.dat";
   int handle = FileOpen(fileName, FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(handle != INVALID_HANDLE)
   {
      FileWriteString(handle, token);
      FileClose(handle);
   }
}

//+------------------------------------------------------------------+
//| Check the license status with Supabase                           |
//+------------------------------------------------------------------+
bool CheckLicense(string code, int timeout_ms = 5000)
{
   if(code == "") return false;

   // Sanitize code to prevent JSON injection
   string cleanCode = code;
   StringReplace(cleanCode, "\"", "");
   StringReplace(cleanCode, "\\", "");
   
   string url = "https://zxgkjytxqqxkizqcrdwf.functions.supabase.co/verify-license";
   
   // Préparation des IDs
   string sessionID = GetSessionID();
   string secretToken = GetSecretToken();
   
   // Payload avec les 3 clés
   string payload = "{\"code\":\"" + cleanCode + "\", \"session_id\":\"" + sessionID + "\", \"secret_token\":\"" + secretToken + "\"}";
   
   char data[], result[];
   string responseHeaders;
   StringToCharArray(payload, data, 0, StringLen(payload));
   
   string headers = "Content-Type: application/json\r\n";
   
   ResetLastError();
   int res = WebRequest("POST", url, headers, timeout_ms, data, result, responseHeaders);
   int lastError = GetLastError();
   
   if(res == 200) 
   {
      string response = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
      if(StringFind(response, "\"valid\":true") >= 0) 
      {
         g_AuthErrorMsg = ""; // Suppression des erreurs précédentes
         // Si le serveur nous renvoie un NOUVEAU token (première activation), on l'enregistre
         int tokenPos = StringFind(response, "\"new_token\":\"");
         if(tokenPos >= 0)
         {
            string sub = StringSubstr(response, tokenPos + 13);
            int endPos = StringFind(sub, "\"");
            if(endPos > 0) SaveSecretToken(StringSubstr(sub, 0, endPos));
         }
         return true;
      }
      else 
      {
         // On essaie d'extraire le message d'erreur du JSON {"valid":false, "error":"..."}
         int errPos = StringFind(response, "\"error\":\"");
         if(errPos >= 0)
         {
            string sub = StringSubstr(response, errPos + 9);
            int endPos = StringFind(sub, "\"");
            if(endPos > 0) g_AuthErrorMsg = StringSubstr(sub, 0, endPos);
            else g_AuthErrorMsg = "Erreur inconnue";
            
            // SELF-HEALING: Si le token est invalide (fichier corrompu ou reset serveur),
            // on supprime le fichier local pour permettre une ré-activation propre.
            if(StringFind(g_AuthErrorMsg, "Certificat") >= 0)
            {
               FileDelete("fantome_cert.dat", FILE_COMMON);
            }
         }
         else g_AuthErrorMsg = "Réponse invalide du serveur";
      }
   }
   else 
   {
      if(res == -1)
      {
         if(lastError == 4060) g_AuthErrorMsg = "URL non ajouté dans les options";
         else if(lastError == 4014) g_AuthErrorMsg = "Fonction non permise (Err 4014)";
         else g_AuthErrorMsg = "Erreur Connexion (Err " + IntegerToString(lastError) + ")";
      }
      else
      {
         g_AuthErrorMsg = "Erreur Serveur (HTTP " + IntegerToString(res) + ")";
      }
   }
   return false;
}

#endif
