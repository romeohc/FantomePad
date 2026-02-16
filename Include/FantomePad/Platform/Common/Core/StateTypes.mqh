#ifndef _STATE_TYPES_MQH_
#define _STATE_TYPES_MQH_
#property strict

//--- STRUCTS FOR STATE MANAGEMENT
struct TPanelState {
   int X;
   int Y;
   int Width;
   int Height;
   bool IsVisible;
   bool IsDragging;
   int DragOffsetX;
   int DragOffsetY;
};

struct TScrollState {
   int ScrollY;
   bool IsDragging;
   int DragAnchorY;
   int ViewportHeight;
   int ContentHeight;
};

//--- ENUMS
enum ENUM_HISTORY_FILTER { H_FILTER_DAILY, H_FILTER_WEEKLY, H_FILTER_MONTHLY, H_FILTER_ALL, H_FILTER_CUSTOM };
enum ENUM_LICENSE_STATE { LICENSE_OK, LICENSE_REVOKED, LICENSE_NONE };

#endif
