# Portfolio Capture Checklist

## Capture Flow Order

### User Flow
1. Home
2. Detail
3. Cart
4. Checkout
5. Order Complete
6. My Page
7. User Order List
8. User Order Detail (cancel request state)

### Seller Flow
9. Seller Dashboard (own products only)
10. Seller Order List (own orders only)
11. Seller Order Detail - Ship (`배송중` + tracking)
12. Seller Order Detail - Cancel Complete (`취소완료`)

### Admin Flow
13. Admin Role Management - before change
14. Admin Role Management - after change

## File Name Convention
- `01_user_home.png`
- `02_user_detail.png`
- `03_user_cart.png`
- `04_user_checkout.png`
- `05_user_order_complete.png`
- `06_user_my_page.png`
- `07_user_order_list.png`
- `08_user_cancel_request.png`
- `09_seller_dashboard.png`
- `10_seller_order_list.png`
- `11_seller_ship_complete.png`
- `12_seller_cancel_complete.png`
- `13_admin_role_before.png`
- `14_admin_role_after.png`

## Capture Rules
1. Use one fixed data snapshot after seed
2. Keep app bar and bottom nav visible where possible
3. Keep Korean text fully visible (no clipping)
4. Capture with same viewport for comparison consistency
5. Include state-critical elements (status chips, tracking number, role dropdown)

## Quality Gate
1. Price format must be `₩` and comma-separated
2. No mojibake/garbled Korean text
3. Seller screens must not show other sellers' records
4. User cannot directly complete cancel; only request
5. Admin role update result must be visible in UI

## Recommended Capture Path
- `C:\ceramic_app\captures\YYYYMMDD_portfolio`
