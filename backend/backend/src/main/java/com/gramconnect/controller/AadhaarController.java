package com.gramconnect.controller;

import com.gramconnect.service.AadhaarService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/aadhaar")
@CrossOrigin(origins = "*")
public class AadhaarController {

    @Autowired
    private AadhaarService aadhaarService;

    @PostMapping("/verify")
    public ResponseEntity<?> verifyAadhaar(@RequestBody Map<String, String> request) {
        try {
            String aadhaarNumber = request.get("aadhaarNumber");
            String phoneNumber = request.get("phoneNumber");

            // ✅ Log request info
            System.out.println("📥 Aadhaar OTP Request: Aadhaar = " + aadhaarNumber + ", Phone = " + phoneNumber);

            // ✅ Get OTP for logging and testing
            String otp = aadhaarService.sendAadhaarOtp(aadhaarNumber, phoneNumber);

            // ✅ Return OTP in response for testing (remove in production)
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "OTP sent to your registered mobile number",
                "otp", otp  // ⚠️ For testing only
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyAadhaarOtp(@RequestBody Map<String, String> request) {
        try {
            String aadhaarNumber = request.get("aadhaarNumber");
            String otp = request.get("otp");

            boolean verified = aadhaarService.verifyAadhaarOtp(aadhaarNumber, otp);

            return ResponseEntity.ok(Map.of(
                "success", true,
                "verified", verified,
                "message", "Aadhaar verified successfully"
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
}
