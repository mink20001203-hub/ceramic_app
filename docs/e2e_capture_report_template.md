# E2E Capture Report Template

Date:

Tester:

Build:

Environment:

- Firebase project: `ceramic-app-aadcb`
- Rules version: latest deployed

## Account Matrix

- Buyer account: `user`
- Seller account: `seller`
- Admin account: `admin`

## Step-by-step Result

1. Buyer login and order create
- Action:
- Expected:
- Actual:
- Screenshot path:
- Result: PASS / FAIL

2. Buyer cancel request
- Action:
- Expected:
- Actual:
- Screenshot path:
- Result: PASS / FAIL

3. Seller order list visibility
- Action:
- Expected:
- Actual:
- Screenshot path:
- Result: PASS / FAIL

4. Seller cancel complete
- Action:
- Expected:
- Actual:
- Screenshot path:
- Result: PASS / FAIL

5. Seller ship process
- Action:
- Expected:
- Actual:
- Screenshot path:
- Result: PASS / FAIL

6. Admin role management
- Action:
- Expected:
- Actual:
- Screenshot path:
- Result: PASS / FAIL

## Validation Points

- `orders.sellerId` saved for new orders
- Seller sees only own orders
- Buyer cannot move status to `취소완료`
- Seller can move status to `취소완료`
- Status log is appended on every transition

## Defects

- Defect #1:
- Severity:
- Repro steps:
- Temporary workaround:

## Final Decision

- Release readiness: GO / NO-GO
- Notes:

## Screenshot Naming Rule

- Format: `NN_role_action.png`
- Example: `01_user_login.png`, `02_user_order_create.png`, `07_seller_cancel_complete.png`
