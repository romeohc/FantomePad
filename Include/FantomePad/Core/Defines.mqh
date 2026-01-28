//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _DEFINES_MQH_
#define _DEFINES_MQH_
#property strict

//--- Inputs externes (Configuration de base)
// Default Risk inputs removed
input double   OneRPercent = 2.0;      // Valeur de 1R en %
input int      DefaultNavigationPosition = 4; // 0=TL, 1=TC, 2=TR, 3=BL, 4=BC, 5=BR
// IMPORTANT: Change this MagicNumber if running multiple instances of FantomePad!
// Each EA instance MUST have a unique MagicNumber to avoid trade conflicts.
input int      MagicNumber = 123456;   // Magic Number for trade identification (MUST BE UNIQUE PER INSTANCE)
input color    ColorBg     = C'21,23,28';  // Fond Panel (Deep Dark Theme)
input color    ColorHeader = C'14,16,19';  // Header Darker
input color    ColorInput  = C'34,38,46';  // Fond Inputs / Elements
input color    ColorText   = C'224,228,230'; // Texte Principal (Off-White)
// input color    ColorLabel removed
input color    ColorGreen  = C'0,184,148';   // Vibrant Mint (Modern Buy)
input color    ColorRed    = C'214,48,49';   // Vibrant Red (Modern Sell)
input color    ColorChartBg= clrBlack;       // Chart Background
input color    ColorChartFg = clrWhite;      // Chart Axes/Text Color
input color    ColorCandleUp = C'0,184,148'; // Candle Up
input color    ColorCandleDown = C'214,48,49'; // Candle Down
input color    ColorBtnValid = C'0,90,180';    // Button Valid (Functional)
input color    ColorBtnInvalid = C'80,80,80';  // Button Invalid (Non-functional)
input color    ColorBtnActive  = C'0,184,148'; // Active Button (Mint)
input color    ColorEntryLine = clrWhite;      // Entry Line Color
input color    ColorSLLine   = C'214,48,49';   // Stop Loss Line Color
input color    ColorTPLine   = C'0,184,148';   // Take Profit Line Color
input int      MaxSlippage   = 10;             // Max Slippage (Pips)

//--- Couleurs pour la liste
color ColorListNormal = C'34,38,46';   // Couleur normale item liste
color ColorListHover  = C'45,52,60';   // Couleur au survol


//--- Préfixe pour tous les objets graphiques
string PREFIX = "PTP_";
string ConfigFileName = "FantomePad_Config.txt";

//--- STRUCTS FOR STATE MANAGEMENT (Phase 2.2)
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

//--- États globaux
int    CurrentTypeIndex = 0; // 0=Market, 1=BuyLim, 2=SellLim, 3=BuyStop, 4=SellStop
int    CurrentDirection = 0; // 0=Buy, 1=Sell (utilisé pour le cycle toggle)
int    RiskMode   = 0; // 0=%, 1=Currency, 2=Risk R
string OrderTypes[] = {"MARKET ORDER", "BUY LIMIT", "SELL LIMIT", "BUY STOP", "SELL STOP"};
string NavigationPositions[] = {"Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"};

// --- PANEL STATE INSTANCES ---
TPanelState g_PanelMain;
TPanelState g_PanelAccount;
TPanelState g_PanelPositions;
TPanelState g_PanelHistory;
TPanelState g_PanelSettings;
TPanelState g_PanelNavigation;

// --- SCROLL STATE INSTANCES ---
TScrollState g_ScrollSettings;
TScrollState g_ScrollHistory;
TScrollState g_ScrollAccountOrders; // Scroll for Active Orders in Account Panel

// --- ACCOUNT ORDERS SCROLL GLOBALS ---
int g_AccountOrdersScrollOffset = 0;   // Current scroll offset for orders list
int g_AccountOrdersMaxVisible = 3;     // Max visible orders before scroll appears

// --- LIST GLOBALS ---
bool   IsListOpen = false; // État de la liste déroulante
int    VisibleListItems = 0; // Nombre d'items affichés dans la liste
int    g_SymbolListOffset = 0; // Scroll offset for symbol list
int    g_SymbolListMaxVisible = 20; // Max visible items in symbol list

// --- POSITIONS SPECIFIC ---
int    SelectedPositionTicket = -1; // -1 = None
bool   IsPosListOpen = false;
int    g_PosListOffset = 0;
int    g_PosListMaxVisible = 10;

// --- HISTORY FILTER GLOBALS ---
enum ENUM_HISTORY_FILTER { H_FILTER_DAILY, H_FILTER_WEEKLY, H_FILTER_MONTHLY, H_FILTER_CUSTOM };
ENUM_HISTORY_FILTER g_HistoryFilterMode = H_FILTER_DAILY; // Default to Daily
int    g_HistoryFilteredIndices[]; // Stores original indices of filtered orders
datetime g_HistoryCustomStart = 0;
datetime g_HistoryCustomEnd = 0;
string g_HistoryFilterSymbol = ""; // Symbol filter string

// --- SETTINGS GLOBALS ---
// Default Risk Globals removed
double   g_OneRPercent;
int      g_NavigationPosition; // 0..5
color    g_ColorBg, g_ColorHeader, g_ColorInput, g_ColorText;
color    g_ColorGreen, g_ColorRed, g_ColorChartBg;
color    g_ColorChartFg;
color    g_ColorBtnValid, g_ColorBtnInvalid, g_ColorEntryLine, g_ColorBtnActive;
color    g_ColorSLLine, g_ColorTPLine;
color    g_ColorCandleUp, g_ColorCandleDown;
color    g_ColorListNormal, g_ColorListHover;

string   g_ColorPickerTarget = ""; // Target button to update
bool     g_ShowOrderLines;       // Toggle for Order Lines visibility
bool     g_ShowPositionLines;    // Toggle for Open Position Lines visibility (Entry/SL/TP)

// --- MOUSE TRACKING ---
int    LastMouseX = -1;
int    LastMouseY = -1;
bool   IsScrollDragging = false; // Symbol List Scroll
int    ScrollDragY = 0;
bool   g_BlockClick = false;
uint   LastClickTime = 0;

// --- COLOR PICKER GLOBALS ---
bool   g_IsColorPickerOpen = false;
int    g_ColorPickerX = 0;
int    g_ColorPickerY = 0;
int    g_ColorPickerW = 0;
int    g_ColorPickerH = 0;
color  g_ColorPalette[]; 

// --- TOAST NOTIFICATION GLOBALS ---
string g_ToastMsg = "";
uint   g_ToastStartTime = 0;
color  g_ToastColor = C'214,48,49'; // Red by default 

// --- VALIDATION ERROR MESSAGE GLOBALS ---
string g_ValidationErrorMsg = "";     // Current error message to display
bool   g_ValidationErrorVisible = false; // Is the error message currently visible

// --- INITIALIZATION HELPER ---
void InitGlobals()
{
   // Init State Structs
   g_PanelMain.Width = 280; // Default
   g_PanelMain.IsVisible = true;
   g_PanelMain.X = -1;
   g_PanelMain.Y = -1;
   
   g_PanelAccount.IsVisible = true;
   g_PanelAccount.X = 20;
   g_PanelAccount.Y = 70;
   
   g_PanelPositions.IsVisible = false;
   g_PanelPositions.X = 260; // Default
   g_PanelPositions.Y = 70;
   
   g_PanelHistory.IsVisible = false;
   g_PanelHistory.X = 50;
   g_PanelHistory.Y = 100;
   
   g_PanelSettings.IsVisible = false;
   g_PanelSettings.X = -1;
   g_PanelSettings.Y = -1;
   
   g_ScrollSettings.ViewportHeight = 400;
   g_ScrollSettings.ContentHeight = 620; 
   g_ScrollHistory.ViewportHeight = 400;
   g_ScrollHistory.ContentHeight = 0;

   // Default Risk Init removed
   g_OneRPercent = OneRPercent;
   g_NavigationPosition = DefaultNavigationPosition;
   g_ColorBg     = ColorBg;
   g_ColorHeader = ColorHeader;
   g_ColorInput  = ColorInput;
   g_ColorText   = ColorText;
   // g_ColorLabel removed
   g_ColorGreen  = ColorGreen;
   g_ColorRed    = ColorRed;
   g_ColorBtnValid = ColorBtnValid;
   g_ColorBtnInvalid = ColorBtnInvalid;
   g_ColorBtnActive  = ColorBtnActive;
   g_ColorChartBg= ColorChartBg;
   g_ColorChartFg = ColorChartFg;
   g_ColorEntryLine = ColorEntryLine;
   g_ColorSLLine = ColorSLLine;
   g_ColorTPLine = ColorTPLine;
   g_ColorCandleUp = ColorCandleUp;
   g_ColorCandleDown = ColorCandleDown;
   g_ColorListNormal = ColorListNormal;
   g_ColorListHover = ColorListHover;
   
   g_ShowOrderLines = true; // Default to ON
   g_ShowPositionLines = true; // Default to ON

   // Init default custom dates (last 7 days by default)
   g_HistoryCustomStart = TimeCurrent() - 7 * 24 * 3600;
   g_HistoryCustomEnd = TimeCurrent() + 24 * 3600;
   
   // Init Color Palette
   color Defaults[] = {
      // Darks
      C'21,23,28', C'34,38,46', C'45,52,60', clrDimGray, clrBlack,
      // Lights
      clrWhite, clrWhiteSmoke, clrSilver, clrLightGray, clrAliceBlue,
      // Greens
      C'0,184,148', clrSeaGreen, clrMediumSeaGreen, clrLimeGreen, clrSpringGreen,
      // Reds
      C'214,48,49', clrCrimson, clrFireBrick, clrRed, clrTomato,
      // Blues
      C'0,90,180', clrRoyalBlue, clrDodgerBlue, clrCornflowerBlue, clrDeepSkyBlue,
      // Extra
      clrGold, clrOrange, clrOrchid, clrMagenta, clrSlateBlue
   };
   ArrayResize(g_ColorPalette, ArraySize(Defaults));
   for(int i=0; i<ArraySize(Defaults); i++) g_ColorPalette[i] = Defaults[i];
}
#endif
