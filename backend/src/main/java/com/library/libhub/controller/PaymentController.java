package com.library.libhub.controller;

import com.library.libhub.config.VNPayConfig;
import com.library.libhub.entity.Fines;
import com.library.libhub.entity.Users;
import com.library.libhub.service.IFineService;
import com.library.libhub.service.IBorrowTicketService;
import com.library.libhub.service.IReturnDetailService;
import com.library.libhub.service.IReturnService;
import com.library.libhub.utils.VNPayUtil;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RequestMapping("/api/payments")
@RestController
public class PaymentController {

    private final VNPayConfig vnp;
    private final IFineService fineService;
    private final IReturnDetailService returnDetailService;
    private final IReturnService returnService;
    private final IBorrowTicketService borrowTicketService;

    public PaymentController(VNPayConfig vnp, IFineService fineService, IReturnDetailService returnDetailService,
                             IReturnService returnService, IBorrowTicketService borrowTicketService) {
        this.vnp = vnp;
        this.fineService = fineService;
        this.returnDetailService = returnDetailService;
        this.returnService = returnService;
        this.borrowTicketService = borrowTicketService;
    }

    @GetMapping("/fines")
    public ResponseEntity<?> getMyFines(HttpSession session) {
        Users user = (Users) session.getAttribute("USER_LOGIN");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(err("Chưa đăng nhập"));
        }

        List<Fines> fines = fineService.getAllFines().stream()
                .filter(fine -> belongsToUser(fine, user.getUserId()))
                .toList();
        return ResponseEntity.ok(fines);
    }

    @PostMapping("/vnpay/create")
    public ResponseEntity<?> createPayment(
            @RequestBody Map<String, Object> body,
            HttpSession session,
            HttpServletRequest request) {

        Users user = (Users) session.getAttribute("USER_LOGIN");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(err("Chưa đăng nhập"));
        }
        if (body.get("fineId") == null) {
            return ResponseEntity.badRequest().body(err("Thiếu fineId"));
        }

        long fineId = Long.parseLong(String.valueOf(body.get("fineId")));
        Fines fine = fineService.getFineById(fineId)
                .orElse(null);
        if (fine == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(err("Không tìm thấy khoản phạt"));
        }
        if (!belongsToUser(fine, user.getUserId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(err("Khoản phạt không thuộc về bạn"));
        }
        if ("Paid".equalsIgnoreCase(fine.getPaidStatus())) {
            return ResponseEntity.badRequest().body(err("Khoản phạt đã được thanh toán"));
        }
        double amount = fine.getAmount() == null ? 0 : fine.getAmount();
        if (amount <= 0) {
            return ResponseEntity.badRequest().body(err("Số tiền không hợp lệ"));
        }
        if (isBlank(vnp.getTmnCode()) || isBlank(vnp.getHashSecret()) || isBlank(vnp.getPayUrl())
                || isBlank(vnp.getReturnUrl())) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(err("VNPay chưa được cấu hình. Vui lòng liên hệ quản trị viên."));
        }

        String txnRef = fineId + "_" + VNPayUtil.randomTxnRef();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        ZonedDateTime now = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));

        Map<String, String> params = new HashMap<>();
        params.put("vnp_Version", vnp.getApiVersion());
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", vnp.getTmnCode());
        params.put("vnp_Amount", String.valueOf(Math.round(amount * 100)));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", txnRef);
        params.put("vnp_OrderInfo", "Thanh toan phat thu vien #" + fineId);
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", vnp.getReturnUrl());
        params.put("vnp_IpAddr", clientIp(request));
        params.put("vnp_CreateDate", now.format(fmt));
        params.put("vnp_ExpireDate", now.plusMinutes(15).format(fmt));

        String hashData = VNPayUtil.buildHashData(params);
        String secureHash = VNPayUtil.hmacSHA512(vnp.getHashSecret(), hashData);
        String payUrl = vnp.getPayUrl() + "?" + VNPayUtil.buildQuery(params)
                + "&vnp_SecureHash=" + secureHash;

        Map<String, Object> out = new HashMap<>();
        out.put("payUrl", payUrl);
        out.put("txnRef", txnRef);
        return ResponseEntity.ok(out);
    }

    @GetMapping("/vnpay/return")
    public void vnpayReturn(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Map<String, String> fields = new HashMap<>();
        for (Map.Entry<String, String[]> e : request.getParameterMap().entrySet()) {
            if (e.getValue() != null && e.getValue().length > 0) {
                fields.put(e.getKey(), e.getValue()[0]);
            }
        }

        boolean configured = !isBlank(vnp.getHashSecret()) && !isBlank(vnp.getFrontendResultUrl());
        boolean validSig = configured && VNPayUtil.verifySignature(fields, vnp.getHashSecret());
        String responseCode = fields.get("vnp_ResponseCode");
        String transactionStatus = fields.get("vnp_TransactionStatus");
        String txnRef = fields.getOrDefault("vnp_TxnRef", "");
        String returnedAmount = fields.getOrDefault("vnp_Amount", "");
        boolean success = validSig && "00".equals(responseCode)
                && (transactionStatus == null || "00".equals(transactionStatus))
                && paymentAmountMatches(txnRef, returnedAmount);

        String status;
        if (!validSig) {
            status = "invalid";
        } else if (success) {
            status = "success";
            markFinePaid(txnRef);
        } else {
            status = "failed";
        }

        String redirect = vnp.getFrontendResultUrl()
                + "?status=" + status
                + "&code=" + enc(responseCode == null ? "" : responseCode)
                + "&txnRef=" + enc(txnRef)
                + "&amount=" + enc(fields.getOrDefault("vnp_Amount", ""));
        response.sendRedirect(redirect);
    }

    // Marks the fine referenced by the txnRef ("<fineId>_<rand>") as Paid.
    private void markFinePaid(String txnRef) {
        try {
            long fineId = Long.parseLong(txnRef.split("_")[0]);
            Optional<Fines> opt = fineService.getFineById(fineId);
            if (opt.isPresent()) {
                Fines fine = opt.get();
                if (!"Paid".equalsIgnoreCase(fine.getPaidStatus())) {
                    fine.setPaidStatus("Paid");
                    fineService.updateFine(fineId, fine);
                }
            }
        } catch (Exception ignored) {
            // Bad txnRef — nothing to update; the browser still lands on the result page.
        }
    }

    private boolean paymentAmountMatches(String txnRef, String returnedAmount) {
        try {
            long fineId = Long.parseLong(txnRef.split("_")[0]);
            long amount = Long.parseLong(returnedAmount);
            return fineService.getFineById(fineId)
                    .map(fine -> fine.getAmount() != null && Math.round(fine.getAmount() * 100) == amount)
                    .orElse(false);
        } catch (RuntimeException ex) {
            return false;
        }
    }

    private boolean belongsToUser(Fines fine, Long userId) {
        if (fine.getReturnDetailId() == null || userId == null) return false;
        return returnDetailService.getReturnDetailById(fine.getReturnDetailId())
                .flatMap(detail -> returnService.getReturnById(detail.getReturnId()))
                .flatMap(returnRecord -> borrowTicketService.getBorrowTicketById(returnRecord.getTicketId()))
                .map(ticket -> userId.equals(ticket.getUserId()))
                .orElse(false);
    }

    private static Map<String, Object> err(String message) {
        Map<String, Object> m = new HashMap<>();
        m.put("message", message);
        return m;
    }

    private static String enc(String v) {
        return URLEncoder.encode(v, StandardCharsets.UTF_8);
    }

    private static String clientIp(HttpServletRequest request) {
        String xff = request.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isBlank()) {
            return xff.split(",")[0].trim();
        }
        String ip = request.getRemoteAddr();
        return ip == null ? "127.0.0.1" : ip;
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
