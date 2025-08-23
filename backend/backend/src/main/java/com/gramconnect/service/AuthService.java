package com.gramconnect.service;

import com.gramconnect.dto.auth.*;
import com.gramconnect.model.Admin;
import com.gramconnect.model.OtpLog;
import com.gramconnect.model.User;
import com.gramconnect.repository.AdminRepository;
import com.gramconnect.repository.OtpLogRepository;
import com.gramconnect.repository.UserRepository;
import com.gramconnect.security.JwtService;
import com.gramconnect.util.OtpGenerator;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class AuthService {
    private final UserRepository userRepository;
    private final AdminRepository adminRepository;
    private final OtpLogRepository otpLogRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;

    @Value("${app.environment:dev}")
    private String environment;

    public AuthService(UserRepository userRepository, AdminRepository adminRepository,
                      OtpLogRepository otpLogRepository, PasswordEncoder passwordEncoder,
                      JwtService jwtService, EmailService emailService) {
        this.userRepository = userRepository;
        this.adminRepository = adminRepository;
        this.otpLogRepository = otpLogRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.emailService = emailService;
    }

    public AuthResponse signup(SignupRequest request) {
        // Check if user already exists
        if (request.getEmail() != null && userRepository.existsByEmail(request.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already exists");
        }
        if (request.getPhoneNumber() != null && userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Phone number already exists");
        }

        // Create user (will be activated after OTP verification)
        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhoneNumber());
        
        if (request.getPassword() != null) {
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }

        user = userRepository.save(user);

        // For signup, always send OTP to phone number
        if (request.getPhoneNumber() != null) {
            OtpRequest otpRequest = new OtpRequest(request.getPhoneNumber(), OtpLog.Type.PHONE);
            return generateOtp(otpRequest);
        } else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Phone number is required for signup");
        }
    }

    public AuthResponse login(LoginRequest request) {
        // For login, determine if identifier is email or phone and send OTP accordingly
        String identifier = request.getEmail();
        OtpLog.Type otpType;
        
        if (isEmail(identifier)) {
            otpType = OtpLog.Type.EMAIL;
        } else if (isPhoneNumber(identifier)) {
            otpType = OtpLog.Type.PHONE;
        } else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid email or phone number format");
        }
        
        // Check if user exists
        User user = null;
        if (otpType == OtpLog.Type.EMAIL) {
            Optional<User> userOpt = userRepository.findByEmail(identifier);
            user = userOpt.orElse(null);
        } else if (otpType == OtpLog.Type.PHONE) {
            Optional<User> userOpt = userRepository.findByPhoneNumber(identifier);
            user = userOpt.orElse(null);
        }

        if (user == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found. Please signup first.");
        }
        
        // Generate OTP for login
        OtpRequest otpRequest = new OtpRequest(identifier, otpType);
        return generateOtp(otpRequest);
    }
    
    private boolean isEmail(String input) {
        return input != null && input.contains("@") && input.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$");
    }
    
    private boolean isPhoneNumber(String input) {
        return input != null && input.matches("^\\+?[1-9]\\d{1,14}$");
    }
    
    public AuthResponse adminLogin(LoginRequest request) {
        // Try to find admin
        Optional<Admin> adminOpt = adminRepository.findByEmail(request.getEmail());
        if (adminOpt.isPresent()) {
            Admin admin = adminOpt.get();
            if (passwordEncoder.matches(request.getPassword(), admin.getPasswordHash())) {
                String token = jwtService.generateToken(admin.getId(), admin.getRole().toString());
                return new AuthResponse(token, admin.getId(), admin.getRole(), true);
            }
        }

        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
    }

    public AuthResponse generateOtp(OtpRequest request) {
        // Check if blocked
        Optional<OtpLog> existingOtp = otpLogRepository.findByIdentifierAndTypeOrderByCreatedAtDesc(
                request.getIdentifier(), request.getType());
        
        if (existingOtp.isPresent() && existingOtp.get().isBlocked()) {
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Too many attempts. Please try again later.");
        }

        // Check resend limit
        if (existingOtp.isPresent() && existingOtp.get().getResendCount() >= 3) {
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Resend limit exceeded");
        }

        // Generate new OTP
        String otp = OtpGenerator.generate();
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(5);

        OtpLog otpLog = new OtpLog(request.getType(), request.getIdentifier(), otp, expiresAt);
        if (existingOtp.isPresent()) {
            otpLog.setResendCount(existingOtp.get().getResendCount() + 1);
        }
        otpLogRepository.save(otpLog);

        // Send OTP based on type
        String message = String.format("Your GramConnect OTP is: %s. Valid for 5 minutes.", otp);
        
        switch (request.getType()) {
            case EMAIL:
                emailService.sendOtp(request.getIdentifier(), "GramConnect OTP", message);
                break;
            case PHONE:
                // In dev mode, just log to terminal
                System.out.println("📱 Phone OTP for " + request.getIdentifier() + ": " + otp);
                break;
            case AADHAAR:
                System.out.println("🔒 Aadhaar OTP for " + request.getIdentifier() + ": " + otp);
                break;
        }

        System.out.println("🔐 Generated OTP: " + otp + " for " + request.getType() + " " + request.getIdentifier());

        AuthResponse response = new AuthResponse("OTP sent successfully");
        if ("dev".equals(environment)) {
            response.setOtp(otp); // Only in dev mode
        }
        return response;
    }

    public AuthResponse verifyOtp(OtpRequest request) {
        Optional<OtpLog> otpLogOpt = otpLogRepository.findFirstByIdentifierAndTypeAndExpiresAtAfterOrderByCreatedAtDesc(
                request.getIdentifier(), request.getType(), LocalDateTime.now());

        if (otpLogOpt.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "OTP expired or not found");
        }

        OtpLog otpLog = otpLogOpt.get();

        // Check if blocked
        if (otpLog.isBlocked()) {
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Too many failed attempts");
        }

        // Verify OTP
        if (!otpLog.getOtp().equals(request.getOtp())) {
            otpLog.incrementAttempts();
            if (otpLog.getAttempts() >= 3) {
                otpLog.setBlockedUntil(LocalDateTime.now().plusMinutes(15));
            }
            otpLogRepository.save(otpLog);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid OTP");
        }

        // OTP verified successfully
        otpLogRepository.delete(otpLog);

        // Find user based on OTP type
        String identifier = request.getIdentifier();
        User user = null;

        if (request.getType() == OtpLog.Type.EMAIL) {
            Optional<User> userOpt = userRepository.findByEmail(identifier);
            user = userOpt.orElse(null);
        } else if (request.getType() == OtpLog.Type.PHONE) {
            Optional<User> userOpt = userRepository.findByPhoneNumber(identifier);
            user = userOpt.orElse(null);
        } else if (request.getType() == OtpLog.Type.AADHAAR) {
            // For Aadhaar verification, we don't create a new user
            return new AuthResponse("Aadhaar verified successfully");
        }

        if (user == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found");
        }

        String token = jwtService.generateToken(user.getId(), user.getRole().toString());
        return new AuthResponse(token, user.getId(), user.getRole(), user.isProfileCompleted());
    }

    public AuthResponse resendOtp(OtpRequest request) {
        return generateOtp(request);
    }

    public AuthResponse googleSignIn(GoogleSignInRequest request) {
        // Google token verification would be implemented here
        // This would involve verifying the ID token with Google's servers
        // For now, return a mock response
        return new AuthResponse("Google Sign-In not implemented yet");
    }
}