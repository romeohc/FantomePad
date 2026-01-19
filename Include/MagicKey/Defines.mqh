//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

//--- Inputs externes (Configuration de base)
input double   DefaultRisk = 1.0;      // Risque par défaut (%)
input double   DefaultRiskMoney = 100.0; // Risque par défaut (Devise)
input color    ColorBg     = C'21,23,28';  // Fond Panel (Deep Dark Theme)
input color    ColorHeader = C'14,16,19';  // Header Darker
input color    ColorInput  = C'34,38,46';  // Fond Inputs / Elements
input color    ColorText   = C'224,228,230'; // Texte Principal (Off-White)
input color    ColorLabel  = C'140,148,160'; // Texte Label (Muted Blue-Grey)
input color    ColorGreen  = C'0,184,148';   // Vibrant Mint (Modern Buy)
input color    ColorRed    = C'214,48,49';   // Vibrant Red (Modern Sell)
input color    ColorChartBg= clrBlack;       // Chart Background
input color    ColorChartFg= clrWhite;       // Chart Foreground (Axis Text)
input color    ColorCandleUp = C'0,184,148'; // Candle Up
input color    ColorCandleDown = C'214,48,49'; // Candle Down
input color    ColorBtnValid = C'0,90,180';    // Button Valid (Functional)
input color    ColorBtnInvalid = C'80,80,80';  // Button Invalid (Non-functional)
input color    ColorEntryLine = clrWhite;      // Entry Line Color
input color    ColorSLLine   = C'214,48,49';   // Stop Loss Line Color
input color    ColorTPLine   = C'0,184,148';   // Take Profit Line Color

//--- Couleurs pour la liste
color ColorListNormal = C'34,38,46';   // Couleur normale item liste
color ColorListHover  = C'45,52,60';   // Couleur au survol

//--- Préfixe pour tous les objets graphiques
string PREFIX = "PTP_";
string ConfigFileName = "MagicKey_Config.txt";

//--- États globaux
int    CurrentTypeIndex = 0; // 0=Market, 1=BuyLim, 2=SellLim, 3=BuyStop, 4=SellStop

int    CurrentDirection = 0; // 0=Buy, 1=Sell (utilisé pour le cycle toggle)
bool   RiskInCurrency   = false; // Nouvelle variable : false=%, true=Devise du compte
string OrderTypes[] = {"MARKET ORDER", "BUY LIMIT", "SELL LIMIT", "BUY STOP", "SELL STOP"};
int    PanelWidth  = 280; // Slightly wider for comfort
bool   IsListOpen = false; // État de la liste déroulante
int    VisibleListItems = 0; // Nombre d'items affichés dans la liste
int    g_SymbolListOffset = 0; // Scroll offset for symbol list
int    g_SymbolListMaxVisible = 20; // Max visible items in symbol list
int    PanelX = -1;          // Position X du panel (-1 = centré)
int    PanelY = -1;          // Position Y du panel (-1 = centré)
bool   IsDragging = false;   // État du drag-and-drop
int    DragOffsetX = 0;      // Offset X pour le drag
int    DragOffsetY = 0;      // Offset Y pour le drag

// --- SETTINGS GLOBALS ---
double   g_DefaultRisk;
double   g_DefaultRiskMoney;
color    g_ColorBg, g_ColorHeader, g_ColorInput, g_ColorText, g_ColorLabel;
color    g_ColorGreen, g_ColorRed, g_ColorChartBg, g_ColorChartFg;
color    g_ColorBtnValid, g_ColorBtnInvalid, g_ColorEntryLine;
color    g_ColorSLLine, g_ColorTPLine;
color    g_ColorCandleUp, g_ColorCandleDown;
color    g_ColorListNormal, g_ColorListHover;

bool     IsSettingsOpen = false;
string   g_ColorPickerTarget = ""; // Target button to update

// --- SETTINGS DRAG GLOBALS ---
int    SettingsX = -1;
int    SettingsY = -1;
bool   IsSettingsDragging = false;
int    SettingsDragOffsetX = 0;
int    SettingsDragOffsetY = 0;

// --- MOUSE TRACKING ---
int    LastMouseX = -1;
int    LastMouseY = -1;
bool   IsScrollDragging = false;
int    ScrollDragY = 0;
bool   g_BlockClick = false;
uint   LastClickTime = 0;

// --- INITIALIZATION HELPER ---
void InitGlobals()
{
   g_DefaultRisk = DefaultRisk;
   g_DefaultRiskMoney = DefaultRiskMoney;
   g_ColorBg     = ColorBg;
   g_ColorHeader = ColorHeader;
   g_ColorInput  = ColorInput;
   g_ColorText   = ColorText;
   g_ColorLabel  = ColorLabel;
   g_ColorGreen  = ColorGreen;
   g_ColorRed    = ColorRed;
   g_ColorBtnValid = ColorBtnValid;
   g_ColorBtnInvalid = ColorBtnInvalid;
   g_ColorChartBg= ColorChartBg;
   g_ColorChartFg= ColorChartFg;
   g_ColorEntryLine = ColorEntryLine;
   g_ColorSLLine = ColorSLLine;
   g_ColorTPLine = ColorTPLine;
   g_ColorCandleUp = ColorCandleUp;
   g_ColorCandleDown = ColorCandleDown;
   g_ColorListNormal = ColorListNormal;
   g_ColorListHover = ColorListHover;
}
