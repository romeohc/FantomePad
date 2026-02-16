#ifndef _INPUTS_MQH_
#define _INPUTS_MQH_
#property strict

// --- DATA ABSTRACTION LAYER (Compatibility MQL4/MQL5) ---
#include "../Compatibility.mqh"

//--- Inputs externes (Configuration de base)
input double   OneRPercent = 2.0;      // Valeur de 1R en %
input double   MaxRiskPercent = 2.0;   // Max Risk allowed per trade in %
input int      DefaultNavigationPosition = 4; // 0=TL, 1=TC, 2=TR, 3=BL, 4=BC, 5=BR
// IMPORTANT: Change this MagicNumber if running multiple instances of FantomePad!
// Each EA instance MUST have a unique MagicNumber to avoid trade conflicts.
input int      MagicNumber = 123456;   // Magic Number for trade identification (MUST BE UNIQUE PER INSTANCE)
input color    ColorBg     = C'34,38,46';  // Panel Background (User Custom)
input color    ColorHeader = C'12,12,12';  // Header (Black)
input color    ColorInput  = C'12,12,12';  // Input Fields (Black)
input color    ColorText   = C'255,255,255'; // Main Text (White)
input color    ColorGreen  = C'41,98,255';   // Positive / Buy (Blue)
input color    ColorRed    = C'161,161,166'; // Negative / Sell (Gray)
input color    ColorChartBg= C'12,12,12';    // Chart Background (Black)
input color    ColorChartFg = C'161,161,166'; // Chart Axes/Text (Gray)
input color    ColorCandleUp = C'41,98,255'; // Candle Up (Blue)
input color    ColorCandleDown = C'161,161,166'; // Candle Down (Gray)
input color    ColorBtnValid = C'41,98,255';    // Button Valid (Blue)
input color    ColorBtnInvalid = C'161,161,166';  // Button Invalid (Gray)
input color    ColorBtnActive  = C'41,98,255'; // Active Button (Blue)
input color    ColorEntryLine = C'255,255,255';      // Entry Line Color (White)
input color    ColorSLLine   = C'161,161,166';   // Stop Loss Line Color (Gray)
input color    ColorTPLine   = C'41,98,255';   // Take Profit Line Color (Blue)
input int      MaxSlippage   = 10;             // Max Slippage (Pips)
input int      MaxSpread     = 50;             // Max Spread (Points)

//--- Couleurs pour la liste
color ColorListNormal = C'12,12,12';   // List Item (Black)
color ColorListHover  = C'22,26,46';   // List Hover (Panel Bg)


//--- Préfixe pour tous les objets graphiques
string PREFIX = "PTP_";
string ConfigFileName = "FantomePad_Config2.txt";

#endif
