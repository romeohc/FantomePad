//+------------------------------------------------------------------+
//|                                                       Crypto.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _CRYPTO_MQH_
#define _CRYPTO_MQH_

#property strict

// Static key for obfuscation
static string XOR_KEY = "FPad2026Sec";

/**
 * Converts a hex character or string to integer.
 */
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

/**
 * Checks if a string is a valid hex string of even length.
 */
bool IsEncodedHexString(string strText)
{
   int len = StringLen(strText);
   if(len == 0 || len % 2 != 0) return false;
   for(int i = 0; i < len; i++)
   {
      ushort c = StringGetCharacter(strText, i);
      if(!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')))
         return false;
   }
   return true;
}

/**
 * Encodes a string for storage using XOR + Hex conversion.
 */
string EncodeString(string strText)
{
   string result = "";
   int keyLen = StringLen(XOR_KEY);
   if(keyLen == 0) return strText;
   
   for(int i = 0; i < StringLen(strText); i++)
   {
      int xored = StringGetCharacter(strText, i) ^ StringGetCharacter(XOR_KEY, i % keyLen);
      result += StringFormat("%02X", xored);
   }
   return result;
}

/**
 * Decodes a string encoded with EncodeString.
 * Supports legacy plain text via auto-detection.
 */
string DecodeString(string encoded)
{
   // Backward compatibility: if not hex or odd length, return as is
   if(!IsEncodedHexString(encoded)) return encoded;
   
   string result = "";
   int keyLen = StringLen(XOR_KEY);
   if(keyLen == 0) return encoded;
   
   for(int i = 0; i < StringLen(encoded); i += 2)
   {
      string hexByte = StringSubstr(encoded, i, 2);
      int val = HexToInt(hexByte);
      int decoded = val ^ StringGetCharacter(XOR_KEY, (i/2) % keyLen);
      result += CharToString((uchar)decoded);
   }
   return result;
}

#endif
