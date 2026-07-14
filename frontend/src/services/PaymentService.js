import { apiRequest } from "../JS/APi.js";

// Ask the backend to build a VNPay payment URL for a fine.
// Returns { payUrl, txnRef }; the caller redirects the browser to payUrl.
export function createVnpayPayment(fineId) {
    return apiRequest("/payments/vnpay/create", {
        method: "POST",
        body: { fineId },
    });
}
