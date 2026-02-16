//+------------------------------------------------------------------+
//|                                               TradeValidator.mqh |
//|                                              FantomePad Project  |
//|                                       Unified Engine Validation  |
//+------------------------------------------------------------------+
#ifndef _TRADE_VALIDATOR_MQH_
#define _TRADE_VALIDATOR_MQH_

#include "../DataTypes.mqh"
#include "../Defines.mqh"
#include "../TradeLogic/TradeCalc.mqh"
#include "TradeErrorHandler.mqh"

class TradeValidator
{
public:
   //+------------------------------------------------------------------+
   //| Validate a Trade Request against all rules                       |
   //+------------------------------------------------------------------+
   static TradeResult Validate(TradeRequest &req)
   {
      // --- Level 1: Input Check ---
      if(req.Symbol == "")
         return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Invalid Symbol", "Symbol string is empty");
      
      if(req.Lots <= 0)
         return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Invalid Volume", "Lots must be greater than 0");
         
      // Price check only for pending orders or if explicitly provided for market
      // Usually, Market execution uses current price, but req.Price must be > 0
      if(req.Price <= 0 && (req.Type != OP_BUY && req.Type != OP_SELL)) // Market orders might use 0 if not filled yet, but better safe
      {
          // Actually, for Market Orders, if price is 0, we can't calculate Margin properly later without fetch.
          // The Handler is supposed to fill it.
          return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Invalid Price", "Price must be > 0");
      }
      // Relaxed check for Market orders if they are strictly 0 (will use Ask/Bid), but plan says Handler fills it.
      if(req.Price <= 0)
         return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Invalid Price", "Price <= 0");

      // --- Level 2: SL Logic ---
      if(req.SL <= 0)
      {
         return MakeErrorResult(0, TRADE_ERR_VALIDATION, "SL Required", "Stop Loss is mandatory for risk management");
      }

      if(!ValidateSlDirection(req.Type, req.Price, req.SL))
      {
         string context = (req.Type == OP_BUY || req.Type == OP_BUYLIMIT || req.Type == OP_BUYSTOP) ? "Below" : "Above";
         return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Invalid SL Direction", "SL must be " + context + " Entry Price");
      }

      // --- Level 3: Risk Management ---
      // 1. Check Max Risk Percent (if risk is calculated/provided)
      if(req.RiskPercent > g_MaxRiskPercent && g_MaxRiskPercent > 0)
      {
         return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Risk Too High", 
            StringFormat("Risk: %.2f%% > Max: %.2f%%", req.RiskPercent, g_MaxRiskPercent));
      }

      // --- Level 4: Broker Rules (Volume) ---
      double minLot = MarketInfo(req.Symbol, MODE_MINLOT);
      double maxLot = MarketInfo(req.Symbol, MODE_MAXLOT);
      double lotStep = MarketInfo(req.Symbol, MODE_LOTSTEP);

      if(lotStep <= 0) lotStep = 0.01; // Safety fallback

      // Normalize lots to LotStep (round DOWN to nearest step)
      req.Lots = MathFloor(req.Lots / lotStep) * lotStep;
      req.Lots = NormalizeDouble(req.Lots, 2); // Avoid floating point drift

      if(req.Lots < minLot)
         return MakeErrorResult(0, TRADE_ERR_BROKER, "Volume Too Small", 
            StringFormat("Calculated: %.2f, Min: %.2f", req.Lots, minLot));
      
      if(req.Lots > maxLot)
      {
         req.Lots = maxLot; // Cap silently instead of rejecting
      }

      // --- Level 5: Market Conditions ---
      
      // 5.1 Spread Check (For Market Orders primarily)
      if(req.Type == OP_BUY || req.Type == OP_SELL)
      {
         int currentSpread = (int)MarketInfo(req.Symbol, MODE_SPREAD); // Points
         // g_MaxSpread is in Points
         if(currentSpread > g_MaxSpread && g_MaxSpread > 0)
         {
            return MakeErrorResult(0, TRADE_ERR_MARKET, "Spread Too High", 
               StringFormat("Spread: %d > Max: %d", currentSpread, g_MaxSpread));
         }
      }

      // 5.2 StopLevel Check
      double stopLevelPoints = MarketInfo(req.Symbol, MODE_STOPLEVEL);
      double point = MarketInfo(req.Symbol, MODE_POINT);
      if(point == 0) point = Point; // Safety fallback
      if(stopLevelPoints > 0)
      {
         double stopLevelDist = stopLevelPoints * point;
         
         // Check SL distance
         if(req.SL > 0)
         {
            if(MathAbs(req.Price - req.SL) < stopLevelDist)
               return MakeErrorResult(0, TRADE_ERR_STOPLEVEL, "SL Too Close", "SL is within StopLevel distance");
         }
         
         // Check TP distance
         if(req.TP > 0)
         {
            if(MathAbs(req.Price - req.TP) < stopLevelDist)
               return MakeErrorResult(0, TRADE_ERR_STOPLEVEL, "TP Too Close", "TP is within StopLevel distance");
         }
         
         // Check Pending Entry distance
         if(req.Type != OP_BUY && req.Type != OP_SELL)
         {
             double currentPrice = (req.Type == OP_BUYLIMIT || req.Type == OP_BUYSTOP) ? MarketInfo(req.Symbol, MODE_ASK) : MarketInfo(req.Symbol, MODE_BID);
             if(MathAbs(req.Price - currentPrice) < stopLevelDist)
               return MakeErrorResult(0, TRADE_ERR_STOPLEVEL, "Entry Too Close", "Pending price is within StopLevel distance");
         }
      }

      // 5.3 Margin Check
      double marginRequired = 0.0;
      
      #ifdef __MQL5__
         if(!OrderCalcMargin((ENUM_ORDER_TYPE)req.Type, req.Symbol, req.Lots, req.Price, marginRequired))
         {
            // If calculation fails, it might be a symbol error or other.
            // We can return error or warning. Let's be strict.
            return MakeErrorResult(0, TRADE_ERR_MARGIN, "Margin Calc Error", "OrderCalcMargin failed");
         }
      #else
         // MT4 Logic
         // MODE_MARGINREQUIRED returns margin for 1 lot.
         // Note: For pending orders, it calculates margin as if it were market.
         double marginPerLot = MarketInfo(req.Symbol, MODE_MARGINREQUIRED);
         if(marginPerLot > 0)
            marginRequired = marginPerLot * req.Lots;
      #endif

      if(marginRequired > 0)
      {
         // Safety Buffer 10%
         double safetyMargin = marginRequired * 1.10;
         double freeMargin = AccountFreeMargin();
         
         if(freeMargin < safetyMargin)
         {
            return MakeErrorResult(0, TRADE_ERR_MARGIN, "Insufficient Margin", 
               StringFormat("Req: %.2f, Free: %.2f", safetyMargin, freeMargin));
         }
      }

      // --- Level 6: Permissions ---
#ifdef __MQL5__
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
          return MakeErrorResult(0, TRADE_ERR_PERMISSION, "AutoTrading Disabled", "AutoTrading button is off in Terminal");
      
      if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
          return MakeErrorResult(0, TRADE_ERR_PERMISSION, "Account Trading Disabled", "Investor password or broker restriction");
#else
      if(!IsTradeAllowed())
          return MakeErrorResult(0, TRADE_ERR_PERMISSION, "AutoTrading Disabled", "Check 'Allow Live Trading' in EA properties or AutoTrading button");
      
      if(!IsExpertEnabled())
          return MakeErrorResult(0, TRADE_ERR_PERMISSION, "Expert Trading Disabled", "Expert Advisors are disabled in terminal");
#endif

      // License Check
      if(g_LicenseState != LICENSE_OK)
      {
          return MakeErrorResult(0, TRADE_ERR_PERMISSION, "No License", "License not active");
      }

      if(AccountInfoInteger(ACCOUNT_LOGIN) == 0)
      {
          return MakeErrorResult(0, TRADE_ERR_PERMISSION, "No Account", "Not logged in");
      }

      // All checks passed
      return MakeSuccessResult(0, "Validation Passed");
   }
};

#endif
