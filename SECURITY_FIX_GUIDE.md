# Security Fix Guide for FantomePad

This guide categorizes fixes into phases based on criticality. Follow the steps sequentially to secure the Expert Advisor.

## Phase 1: Critical Fixes (Trade Execution)

### 1. Implement Pre-Trade Margin Check
**Goal**: Prevent `OrderSend` failures due to insufficient funds (Error 134).

**Step 1**: Add this helper function to `Include/FantomePad/Trade/Trade.mqh` (before `SafeOrderSend`):

```cpp
bool IsSufficientMargin(string symbol, int cmd, double lots, double price)
{
   if(lots <= 0) return false;
   
   double marginRequired = 0.0;
   // AccountFreeMarginCheck returns free margin remaining after the specified order is opened.
   // Use explicit check:
   double freeMargin = AccountFreeMargin();
   double oneLotMargin = MarketInfo(symbol, MODE_MARGINREQUIRED);
   
   // Approximate margin check (standard forex)
   // Better: use AccountFreeMarginCheck if available and reliable
   double check = AccountFreeMarginCheck(symbol, cmd, lots);
   
   if(GetLastError() == 134 || check < 0) return false;
   
   return true;
}
```

**Step 2**: Update `SafeOrderSend` in `Include/FantomePad/Trade/Trade.mqh`:

*Locate comment:* `// Check Free Margin (Optional but good)`
*Replace with:*

```cpp
      // Check Free Margin
      if(!IsSufficientMargin(symbol, cmd, volume, price))
      {
         error = 134; // ERR_NOT_ENOUGH_MONEY
         Print("Critical: Insufficient Margin for ", volume, " lots");
         break; // Fatal, do not retry
      }
```

## Phase 2: Risk Management Hardening

### 1. Fix Risk Floor (MinLot Logic)
**Goal**: Prevent the EA from taking more risk than the user defined (e.g., forcing 0.01 lots when risk allows only 0.001).

**Step 1**: Update `CalculateLotSize` in `Include/FantomePad/Trade/Trade.mqh`.

*Locate:*
```cpp
   if(lotSize < minLot) lotSize = minLot; 
```

*Replace with:*
```cpp
   // STRICT SAFETY: If calculated risk is less than minLot, DO NOT TRADE.
   if(lotSize < minLot) 
   {
       Print("Risk Warning: Calculated lot (", lotSize, ") is below MinLot (", minLot, "). Trade aborted to preserve risk limits.");
       return 0.0;
   }
```

## Phase 3: Input Validation

### 1. Validate Inputs on Init
**Goal**: Ensure `MaxSlippage` and other inputs are sane.

**Step 1**: Update `InitGlobals` in `Include/FantomePad/Core/Defines.mqh`.

*Add at the beginning of `InitGlobals()`:*

```cpp
   if(MaxSlippage < 0) g_MaxSlippage = 0; // Create global for this or clamp it directly
   else g_MaxSlippage = MaxSlippage;
   // Note: You need to define int g_MaxSlippage in globals section or just modify usage.
   // Simpler: Just validate in usage or here.
```

*Better Approach (Modify `ExecuteOrder` usage)*:
In `Include/FantomePad/Trade/Trade.mqh`, function `ExecuteOrder`:

```cpp
   int slip = MaxSlippage;
   if(slip < 0) slip = 0; 
   int slippagePoints = GetSlippagePoints(slip);
```
