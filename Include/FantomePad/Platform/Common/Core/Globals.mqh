#ifndef _GLOBALS_MQH_
#define _GLOBALS_MQH_
#property strict

#include "Inputs.mqh"
#include "StateTypes.mqh"

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
TPanelState g_PanelSymbolManager; // New Symbol Manager Overlay
TPanelState g_PanelAuth;

// --- SCROLL STATE INSTANCES ---
TScrollState g_ScrollSettings;
TScrollState g_ScrollHistory;
TScrollState g_ScrollAccountOrders; // Scroll for Active Orders in Account Panel
TScrollState g_ScrollSymbolManager; // Scroll for Symbol Manager grid

// --- ACCOUNT ORDERS SCROLL GLOBALS ---
int g_AccountOrdersScrollOffset = 0;   // Current scroll offset for orders list
int g_AccountOrdersMaxVisible = 3;     // Max visible orders before scroll appears

// --- LIST GLOBALS ---
bool   IsListOpen = false; // État de la liste déroulante
int    VisibleListItems = 0; // Nombre d'items affichés dans la liste
int    g_SymbolListOffset = 0; // Scroll offset for symbol list
int    g_SymbolListMaxVisible = 20; // Max visible items in symbol list
int    g_SymbolHoverIndex = -1; // Current highlighted index for wheel navigation

// --- POSITIONS SPECIFIC ---
long   SelectedPositionTicket = -1; // -1 = None
bool   IsPosListOpen = false;
int    g_PosListOffset = 0;
int    g_PosListMaxVisible = 10;

// --- HISTORY FILTER GLOBALS ---
ENUM_HISTORY_FILTER g_HistoryFilterMode = H_FILTER_DAILY; // Default to Daily
int    g_HistoryFilteredIndices[]; // Stores original indices of filtered orders
datetime g_HistoryCustomStart = 0;
datetime g_HistoryCustomEnd = 0;
string g_HistoryFilterSymbol = ""; // Symbol filter string

// --- AUTHENTICATION GLOBALS ---
ENUM_LICENSE_STATE g_LicenseState = LICENSE_NONE;
#define g_IsLicensed (g_LicenseState == LICENSE_OK)
bool   g_NeedsReinit = false;  // Flag for deferred GUI re-initialization
uint   g_LastLicenseCheckTime = 0;

string g_ActivationCode = "";
string g_AuthErrorMsg    = ""; // Stores the last error from the server

// --- SETTINGS GLOBALS ---
double   g_OneRPercent;
double   g_MaxRiskPercent;
int      g_NavigationPosition; // 0..5
color    g_ColorBg, g_ColorHeader, g_ColorInput, g_ColorText;
color    g_ColorGreen, g_ColorRed, g_ColorChartBg;
color    g_ColorChartFg;
color    g_ColorBtnValid, g_ColorBtnInvalid, g_ColorEntryLine, g_ColorBtnActive;
color    g_ColorSLLine, g_ColorTPLine;
color    g_ColorCandleUp, g_ColorCandleDown;
color    g_ColorListNormal, g_ColorListHover;
color    g_ColorPositive, g_ColorNegative; // NEW: Global Positive/Negative indicators

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
uint   g_LastInteractionTime = 0;

// --- COLOR PICKER GLOBALS ---
bool   g_IsColorPickerOpen = false;
int    g_ColorPickerX = 0;
int    g_ColorPickerY = 0;
int    g_ColorPickerW = 0;
int    g_ColorPickerH = 0;
color  g_ColorPalette[]; 

// --- SPREAD PROTECTION GLOBAL ---
int    g_MaxSpread = 50; 

// --- TOAST NOTIFICATION GLOBALS ---
string g_ToastMsg = "";
uint   g_ToastStartTime = 0;
color  g_ToastColor = C'214,48,49'; // Red by default 

// --- VALIDATION ERROR MESSAGE GLOBALS ---
string g_ValidationErrorMsg = "";     // Current error message to display
bool   g_ValidationErrorVisible = false; // Is the error message currently visible
bool   g_PosValidationErrorVisible = false; // Is the position error message currently visible
string g_LastTradeErrorMsg = "";      // Last error from trading logic (to be picked up by GUI)

// --- SYMBOL MANAGER GLOBALS ---
bool   g_SymbolManagerLoaded = false;
string g_SymMgr_CurrentCategory = ""; // Currently selected category path
int    g_SymMgr_ScrollOffset = 0;     // Scroll for symbol grid
int    g_SymMgr_MaxVisible = 20;      // Max visible rows in grid
string g_SymMgr_SearchQuery = "";     // Optional search query logic for future use
string g_SymMgr_SelectedSymbol = "";  // Currently selected symbol in manager

#endif
