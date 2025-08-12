package com.gramconnect.controller;

import com.gramconnect.dto.AuthRequest;
import com.gramconnect.dto.AuthResponse;
import com.gramconnect.dto.OtpRequest;
import com.gramconnect.dto.ProfileUpdateRequest;
import com.gramconnect.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody AuthRequest request) {
        try {
            AuthResponse response = authService.register(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            AuthResponse errorResponse = new AuthResponse();
            errorResponse.setMessage(e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            AuthResponse errorResponse = new AuthResponse();
            errorResponse.setMessage(e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    @PostMapping("/admin/login")
    public ResponseEntity<AuthResponse> adminLogin(@Valid @RequestBody AuthRequest request) {
        try {
            AuthResponse response = authService.adminLogin(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            AuthResponse errorResponse = new AuthResponse();
            errorResponse.setMessage(e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<AuthResponse> verifyOtp(@Valid @RequestBody OtpRequest request) {
        try {
            AuthResponse response = authService.verifyOtp(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            AuthResponse errorResponse = new AuthResponse();
            errorResponse.setMessage(e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    @PostMapping("/resend-otp")
    public ResponseEntity<String> resendOtp(@RequestParam String identifier,
                                            @RequestParam String type) {
        try {
            authService.resendOtp(identifier,
                    com.gramconnect.model.OtpVerification.OtpType.valueOf(type));
            return ResponseEntity.ok("OTP resent successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@Valid @RequestBody ProfileUpdateRequest request) {
        try {
            var updatedUser = authService.updateProfile(request);
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Profile updated successfully.");
            response.put("userId", updatedUser.getId());
            response.put("fullName", updatedUser.getFullName());
            response.put("district", updatedUser.getDistrict());
            response.put("panchayat", updatedUser.getPanchayat());
            response.put("ward", updatedUser.getWard());
            response.put("homeAddress", updatedUser.getHomeAddress());
            response.put("aadhaarNumber", updatedUser.getAadhaarNumber());
            response.put("aadhaarVerified", updatedUser.isAadhaarVerified());
            response.put("profileCompleted", updatedUser.isProfileCompleted());

            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
}
