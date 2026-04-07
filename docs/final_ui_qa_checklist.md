# Final UI QA Checklist

## Scope
- Home
- Detail
- Cart
- Checkout
- Order Complete
- My Page
- Benefit (Coupons)
- User Order List
- Seller screens (`Seller Demo`, `Seller Order Detail`)

## Device Matrix
- Chrome desktop (`flutter run -d chrome`)
- Android emulator or real device (`flutter run -d <android-id>`)

## Navigation Flow QA
1. Home -> Detail -> Cart -> Checkout -> Order Complete -> Home
2. Home -> My Page -> Benefit -> My Page
3. My Page -> User Order List -> Order Detail
4. Seller account -> Seller Demo -> Seller Order Detail

## State QA
- Loading state shows `OudLoadingState` where applicable.
- Empty state shows `OudEmptyState` with readable Korean copy.
- Error feedback appears as `SnackBar` for invalid action (e.g., out-of-stock, missing form data).
- CTA press interaction uses `OudTapScale` on key submit buttons.

## Cart/Checkout Rules
- Cart total formula: `subtotal + shippingFee`.
- Checkout total formula: `subtotal + shippingFee - couponDiscount - mileage`.
- Shipping fee rule: `0` when subtotal >= `50,000`, else `3,000`.
- Coupon selection updates total immediately.
- Mileage slider max is clamped to payable amount.
- Agreement checkbox blocks payment if unchecked.

## Orders
- After payment, `OrderCompleteScreen` is shown.
- Order appears in user order list.
- Order detail shows status logs, payment summary, coupon/mileage info when present.
- Cancellation request path works for eligible statuses.

## Seller
- Seller sees only permitted orders in seller views.
- Shipment action requires tracking number.
- Cancel action saves reason and updates status log.

## Text/Encoding
- All Korean labels are readable in app UI.
- No mojibake strings in primary flows.

## Regression Notes
- Re-check custom widgets after any theme/token change:
  - `OudSectionCard`
  - `OudAmountRow`
  - `OudMenuTile`
  - `OudFadeSwitcher`
  - `OudTapScale`
