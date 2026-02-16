//+------------------------------------------------------------------+
//|                                                  FileManager.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _FILE_MANAGER_MQH_
#define _FILE_MANAGER_MQH_

#property strict
#include "../Defines.mqh"

//+------------------------------------------------------------------+
//| File Manager Class (Static)                                      |
//| Handles I/O operations safely in the Common Data Path            |
//+------------------------------------------------------------------+
class C_FileManager
{
public:
   //+------------------------------------------------------------------+
   //| Read entire file content as string                               |
   //+------------------------------------------------------------------+
   static string Read(string filename)
   {
      // Open in Common folder, Binary mode for raw read, Shared Read access
      int handle = FileOpen(filename, FILE_READ | FILE_BIN | FILE_COMMON | FILE_SHARE_READ);
      
      if(handle == INVALID_HANDLE) return "";
      
      // Check file size
      ulong size = FileSize(handle);
      if(size == 0)
      {
         FileClose(handle);
         return "";
      }
      
      // Read raw bytes
      uchar data[];
      ArrayResize(data, (int)size);
      FileReadArray(handle, data);
      
      // Always close handle
      FileClose(handle);
      
      // Convert to String (UTF-8 assumption for modern apps)
      return CharArrayToString(data, 0, WHOLE_ARRAY, CP_UTF8);
   }

   //+------------------------------------------------------------------+
   //| Write string content to file (Overwrites existing)               |
   //+------------------------------------------------------------------+
   static bool Write(string filename, string content)
   {
      // Open for Write (truncates existing), Binary mode, Common folder
      int handle = FileOpen(filename, FILE_WRITE | FILE_BIN | FILE_COMMON | FILE_SHARE_READ);
      
      if(handle == INVALID_HANDLE) return false;
      
      // Convert String to Bytes
      uchar data[];
      // We only convert the characters, no null terminator needed for text file compat
      int len = StringLen(content);
      if(len > 0)
      {
         StringToCharArray(content, data, 0, len);
         FileWriteArray(handle, data);
      }
      
      FileClose(handle);
      return true;
   }

   //+------------------------------------------------------------------+
   //| Delete file                                                     |
   //+------------------------------------------------------------------+
   static bool Delete(string filename)
   {
      return FileDelete(filename, FILE_COMMON);
   }
};

#endif
