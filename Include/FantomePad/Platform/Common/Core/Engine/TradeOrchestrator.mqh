// TradeOrchestrator.mqh
// Part of the "Ghost Engine" - Core Orchestration Layer
// Orchestrates trade execution: Validates request -> Selects Engine -> Returns Result
// 100% Core Logic. No UI dependency.

#ifndef _TRADE_ORCHESTRATOR_MQH_
#define _TRADE_ORCHESTRATOR_MQH_

#include "../DataTypes.mqh"
#include "ITradeEngine.mqh"
#include "TradeValidator.mqh"

// Forward declaration of the global engine pointer
// This pointer is defined in Bridge.mqh and MUST be initialized before use
// (We rely on correct include order in Bridge.mqh)


class TradeOrchestrator {
private:
   static bool       m_isBusy;  // Atomic execution lock

public:
   // --- MAIN ENTRY POINT FOR NEW TRADES ---
   // Validates the request and dispatches to the correct engine method (Market or Pending)
   static TradeResult Execute(TradeRequest &req) {
      if(m_isBusy) return MakeErrorResult(0, TRADE_ERR_BUSY, "A trade operation is already in progress. Please wait.");
      m_isBusy = true;

      // 1. Validation Logic
      TradeResult valResult = TradeValidator::Validate(req);
      if(!valResult.Success) {
         m_isBusy = false;
         return valResult;
      }
      
      // 2. Engine Availability Check
      if(CheckPointer(g_TradeEngine) == POINTER_INVALID) {
         m_isBusy = false;
         return MakeErrorResult(0, TRADE_ERR_UNKNOWN, "Internal Error: Trade Engine not initialized!");
      }
      
      // 3. Execution Dispatch
      TradeResult res;
      
      // Market Orders
      if(req.Type == OP_BUY || req.Type == OP_SELL) {
         res = g_TradeEngine.OpenMarket(req.Symbol, req.Type, req.Lots, req.Price,
                                         req.SL, req.TP, req.Comment, req.Magic);
      }
      // Pending Orders
      else {
         res = g_TradeEngine.OpenPending(req.Symbol, req.Type, req.Lots, req.Price,
                                          req.SL, req.TP, req.Comment, req.Magic, req.Expiration);
      }
      
      // 4. Return Result (Caller handles UI feedback)
      m_isBusy = false;
      return res;
   }
   
   // --- POSITION MANAGEMENT HELPERS ---
   // These methods wrap the engine calls to provide a consistent interface
   
   // Close a position (Close specific volume)
   static TradeResult ClosePosition(long ticket, double lots, string comment) {
      if(m_isBusy) return MakeErrorResult(0, TRADE_ERR_BUSY, "A trade operation is already in progress.");
      m_isBusy = true;

      if(CheckPointer(g_TradeEngine) == POINTER_INVALID) {
         m_isBusy = false;
         return MakeErrorResult(0, TRADE_ERR_UNKNOWN, "Internal Error: Trade Engine not initialized!");
      }
      
      TradeResult res = g_TradeEngine.Close(ticket, lots, comment);
      m_isBusy = false;
      return res;
   }
   
   // Modify a position (SL/TP)
   static TradeResult ModifyPosition(long ticket, double sl, double tp) {
      if(m_isBusy) return MakeErrorResult(0, TRADE_ERR_BUSY, "A trade operation is already in progress.");
      m_isBusy = true;

      if(CheckPointer(g_TradeEngine) == POINTER_INVALID) {
         m_isBusy = false;
         return MakeErrorResult(0, TRADE_ERR_UNKNOWN, "Internal Error: Trade Engine not initialized!");
      }
      
      TradeResult res = g_TradeEngine.Modify(ticket, sl, tp);
      m_isBusy = false;
      return res;
   }
   
   // Delete a pending order
   static TradeResult DeleteOrder(long ticket) {
      if(m_isBusy) return MakeErrorResult(0, TRADE_ERR_BUSY, "A trade operation is already in progress.");
      m_isBusy = true;

      if(CheckPointer(g_TradeEngine) == POINTER_INVALID) {
         m_isBusy = false;
         return MakeErrorResult(0, TRADE_ERR_UNKNOWN, "Internal Error: Trade Engine not initialized!");
      }
      
      TradeResult res = g_TradeEngine.Delete(ticket);
      m_isBusy = false;
      return res;
   }
};

// Initialize static member
static bool TradeOrchestrator::m_isBusy = false;

#endif
