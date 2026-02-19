#ifndef _SECURITY_MQH_
#define _SECURITY_MQH_

#property strict
#include "Defines.mqh"
#include "IO/HttpManager.mqh"
#include "IO/FileManager.mqh"

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
   return C_FileManager::Read("fantome_cert.dat");
}

void SaveSecretToken(string token)
{
   C_FileManager::Write("fantome_cert.dat", token);
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
   
   string url = "https://api.fantomepad.com/verify-license";
   
   // Préparation des IDs
   string sessionID = GetSessionID();
   string secretToken = GetSecretToken();
   
   // Sanitize all fields for JSON safety
   StringReplace(sessionID, "\"", "");
   StringReplace(sessionID, "\\", "");
   StringReplace(secretToken, "\"", "");
   StringReplace(secretToken, "\\", "");
   
   // Payload avec les 3 clés
   string payload = "{\"code\":\"" + cleanCode + "\", \"session_id\":\"" + sessionID + "\", \"secret_token\":\"" + secretToken + "\"}";
   
   string response;
   int res = C_HttpManager::Post(url, payload, response, timeout_ms);
   
   if(res == 200) 
   {
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
            if(endPos > 0) 
            {
               g_AuthErrorMsg = StringSubstr(sub, 0, endPos);
               // Simplify message if it's a device mismatch
               if(StringFind(g_AuthErrorMsg, "activé sur un autre appareil") >= 0)
                  g_AuthErrorMsg = "Déjà activé sur un autre appareil";
            }
            else g_AuthErrorMsg = "Erreur inconnue";
            
            // SELF-HEALING: Si le token est invalide (fichier corrompu ou reset serveur),
            // on supprime le fichier local pour permettre une ré-activation propre.
            if(StringFind(g_AuthErrorMsg, "Certificat") >= 0 || StringFind(g_AuthErrorMsg, "appareil") >= 0)
            {
               C_FileManager::Delete("fantome_cert.dat");
            }
         }
         else g_AuthErrorMsg = "Réponse invalide du serveur";
      }
   }
   else 
   {
      if(res == 4060 || res == 4014) g_AuthErrorMsg = "Fantomepad n'est pas connecté";
      else if(res == -1) g_AuthErrorMsg = "Erreur Connexion (Err -1)";
      else g_AuthErrorMsg = "Erreur Serveur (HTTP " + IntegerToString(res) + ")";
   }
   return false;
}

#endif
