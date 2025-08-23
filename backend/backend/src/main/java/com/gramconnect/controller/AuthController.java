package com.gramconnect.controller;

import com.gramconnect.dto.auth.*;
import com.gramconnect.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "Authentication and OTP operations")
@CrossOrigin(origins = "*")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/signup")
    @Operation(summary = "Create new user account")
    public ResponseEntity<AuthResponse> signup(@Valid @RequestBody SignupRequest request) {
        return ResponseEntity.ok(authService.signup(request));
    }

    @PostMapping("/login")
    @Operation(summary = "Login with email and password")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

   @PostMapping("/admin/login")
   @Operation(summary = "Admin login with email and password")
   public ResponseEntity<AuthResponse> adminLogin(@Valid @RequestBody LoginRequest request) {
       return ResponseEntity.ok(authService.adminLogin(request));
   }
    @PostMapping("/google")
    @Operation(summary = "Google Sign-In verification")
    public ResponseEntity<AuthResponse> googleSignIn(@Valid @RequestBody GoogleSignInRequest request) {
        return ResponseEntity.ok(authService.googleSignIn(request));
    }

    @PostMapping("/otp/generate")
    @Operation(summary = "Generate OTP for phone/email verification")
    public ResponseEntity<AuthResponse> generateOtp(@Valid @RequestBody OtpRequest request) {
        return ResponseEntity.ok(authService.generateOtp(request));
    }

    @PostMapping("/otp/verify")
    @Operation(summary = "Verify OTP")
    public ResponseEntity<AuthResponse> verifyOtp(@Valid @RequestBody OtpRequest request) {
        return ResponseEntity.ok(authService.verifyOtp(request));
    }

    @PostMapping("/otp/resend")
    @Operation(summary = "Resend OTP with cooldown")
    public ResponseEntity<AuthResponse> resendOtp(@Valid @RequestBody OtpRequest request) {
        return ResponseEntity.ok(authService.resendOtp(request));
    }

    @PostMapping("/aadhaar/generate")
    @Operation(summary = "Generate Aadhaar OTP (mock)")
    public ResponseEntity<AuthResponse> generateAadhaarOtp(@RequestBody Map<String, String> requestBody) {
        String aadhaarNumber = requestBody.get("aadhaarNumber");
        OtpRequest otpRequest = new OtpRequest(aadhaarNumber, com.gramconnect.model.OtpLog.Type.AADHAAR);
        return ResponseEntity.ok(authService.generateOtp(otpRequest));
    }

    @PostMapping("/aadhaar/verify")
    @Operation(summary = "Verify Aadhaar OTP")
    public ResponseEntity<AuthResponse> verifyAadhaarOtp(@RequestBody Map<String, String> requestBody) {
        String aadhaarNumber = requestBody.get("aadhaarNumber");
        String otp = requestBody.get("otp");
        
        OtpRequest otpRequest = new OtpRequest(aadhaarNumber, com.gramconnect.model.OtpLog.Type.AADHAAR, otp);
        return ResponseEntity.ok(authService.verifyOtp(otpRequest));
    }
}