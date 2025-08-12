package com.gramconnect.service;

import com.gramconnect.dto.AuthRequest;
import com.gramconnect.dto.AuthResponse;
import com.gramconnect.dto.OtpRequest;
import com.gramconnect.dto.ProfileUpdateRequest;
import com.gramconnect.model.User;
import com.gramconnect.model.Admin;
import com.gramconnect.model.OtpVerification;
import com.gramconnect.repository.UserRepository;
import com.gramconnect.repository.AdminRepository;
import com.gramconnect.repository.OtpVerificationRepository;
import com.gramconnect.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private OtpVerificationRepository otpRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private EmailService emailService;

    @Autowired
    private SmsService smsService;

    public AuthResponse register(AuthRequest request) {
        // Check if user already exists
        if (request.getEmail() != null && userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("User with this email already exists");
        }
        
        if (request.getPhoneNumber() != null && userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new RuntimeException("User with this phone number already exists");
        }

        // Create new user
        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setDistrict(request.getDistrict());
        user.setPanchayat(request.getPanchayat());
        user.setWard(request.getWard());
        user.setHomeAddress(request.getHomeAddress());
        user.setAadhaarNumber(request.getAadhaarNumber());
        user.setAadhaarVerified(request.isAadhaarVerified());
        
        if (request.getPassword() != null) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        // Set auth type based on request
        if (request.getAuthType() == AuthRequest.AuthType.PHONE_OTP) {
            // Send OTP for verification
            String otp = generateOtp();
            OtpVerification.OtpType otpType = OtpVerification.OtpType.PHONE_REGISTRATION;
            
            saveOtp(request.getPhoneNumber(), otp, otpType);
            
            smsService.sendOtp(request.getPhoneNumber(), otp);
            
            // Save user but don't activate until OTP verification
            user.setActive(false);
            user = userRepository.save(user);
            
            AuthResponse response = new AuthResponse();
            response.setUserId(user.getId());
            response.setRequiresOtpVerification(true);
            response.setMessage("OTP sent to " + request.getPhoneNumber() + ". Please verify to complete registration.");
            return response;
        }

        // Password-based registration
        user.setActive(true);
        user = userRepository.save(user);

        // Send welcome messages
        try {
            if (user.getEmail() != null) {
                emailService.sendWelcomeEmail(user.getEmail(), user.getFullName());
            }
            if (user.getPhoneNumber() != null) {
                smsService.sendWelcomeSms(user.getPhoneNumber(), user.getFullName());
            }
        } catch (Exception e) {
            System.err.println("Failed to send welcome messages: " + e.getMessage());
        }

        String token = jwtUtil.generateToken(user.getId(), "USER");
        
        AuthResponse response = new AuthResponse(token, user.getId(), user.getFullName(), "USER");
        response.setEmail(user.getEmail());
        response.setPhoneNumber(user.getPhoneNumber());
        response.setDistrict(user.getDistrict());
        response.setPanchayat(user.getPanchayat());
        response.setWard(user.getWard());
        response.setHomeAddress(user.getHomeAddress());
        response.setAadhaarNumber(user.getAadhaarNumber());
        response.setAadhaarVerified(user.isAadhaarVerified());
        response.setExpiresAt(LocalDateTime.now().plusDays(1));
        
        return response;
    }

    public AuthResponse login(AuthRequest request) {
        Optional<User> userOpt = request.getEmail() != null ? 
            userRepository.findByEmail(request.getEmail()) : 
            userRepository.findByPhoneNumber(request.getPhoneNumber());

        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        User user = userOpt.get();

        if (!user.isActive()) {
            throw new RuntimeException("Account not activated. Please verify your OTP.");
        }

        // For all login attempts, require OTP verification
        String identifier = request.getEmail() != null ? request.getEmail() : request.getPhoneNumber();
        String otp = generateOtp();
        
        // Determine OTP type based on identifier
        OtpVerification.OtpType otpType = identifier.contains("@") ? 
            OtpVerification.OtpType.EMAIL_LOGIN : OtpVerification.OtpType.PHONE_LOGIN;
        
        // First verify password for security
        if (request.getPassword() != null && !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }
        
        // Save and send OTP
        saveOtp(identifier, otp, otpType);
        
        if (identifier.contains("@")) {
            emailService.sendOtp(identifier, otp);
        } else {
            smsService.sendOtp(identifier, otp);
        }
        
        AuthResponse response = new AuthResponse();
        response.setUserId(user.getId());
        response.setRequiresOtpVerification(true);
        response.setMessage("OTP sent to " + identifier + ". Please verify to complete login.");
        response.setOtpForTesting(otp); // For testing only
        
        return response;
    }

    public AuthResponse loginWithPassword(AuthRequest request) {
        // This method is for direct password login without OTP (if needed)
        Optional<User> userOpt = request.getEmail() != null ?
                userRepository.findByEmail(request.getEmail()) :
                userRepository.findByPhoneNumber(request.getPhoneNumber());

        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        User user = userOpt.get();
        // Password-based login
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        // Send welcome messages only for direct password login (without OTP)
        // Send login welcome messages
        try {
            if (user.getEmail() != null) {
                emailService.sendLoginWelcomeEmail(user.getEmail(), user.getFullName());
            }
            if (user.getPhoneNumber() != null) {
                smsService.sendLoginWelcomeSms(user.getPhoneNumber(), user.getFullName());
            }
        } catch (Exception e) {
            System.err.println("Failed to send login welcome messages: " + e.getMessage());
        }

        String token = jwtUtil.generateToken(user.getId(), "USER");
        
        AuthResponse response = new AuthResponse(token, user.getId(), user.getFullName(), "USER");
        response.setEmail(user.getEmail());
        response.setPhoneNumber(user.getPhoneNumber());
        response.setDistrict(user.getDistrict());
        response.setPanchayat(user.getPanchayat());
        response.setWard(user.getWard());
        response.setHomeAddress(user.getHomeAddress());
        response.setAadhaarNumber(user.getAadhaarNumber());
        response.setAadhaarVerified(user.isAadhaarVerified());
        response.setExpiresAt(LocalDateTime.now().plusDays(1));
        
        return response;
    }

    public AuthResponse adminLogin(AuthRequest request) {
        Optional<Admin> adminOpt = adminRepository.findByEmail(request.getEmail());
        
        if (adminOpt.isEmpty()) {
            throw new RuntimeException("Admin not found");
        }

        Admin admin = adminOpt.get();

        if (!admin.isActive()) {
            throw new RuntimeException("Admin account is deactivated");
        }

        if (!passwordEncoder.matches(request.getPassword(), admin.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        // Generate token with specific role
        String userType = admin.getRole() == Admin.AdminRole.SUPER_ADMIN ? "SUPER_ADMIN" : "ADMIN";
        String token = jwtUtil.generateToken(admin.getId(), userType);
        
        AuthResponse response = new AuthResponse(token, admin.getId(), admin.getFullName(), userType);
        response.setEmail(admin.getEmail());
        response.setExpiresAt(LocalDateTime.now().plusDays(1));
        
        return response;
    }

    public AuthResponse verifyOtp(OtpRequest request) {
        String identifier = request.getIdentifier();
        
        Optional<OtpVerification> otpOpt = otpRepository.findByIdentifierAndTypeAndVerifiedFalse(
            identifier, request.getType());
        
        if (otpOpt.isEmpty()) {
            throw new RuntimeException("Invalid or expired OTP");
        }

        OtpVerification otpVerification = otpOpt.get();
        
        if (otpVerification.isExpired()) {
            throw new RuntimeException("OTP has expired");
        }

        if (!otpVerification.getOtp().equals(request.getOtp())) {
            otpVerification.setAttempts(otpVerification.getAttempts() + 1);
            otpRepository.save(otpVerification);
            
            if (otpVerification.getAttempts() >= 3) {
                otpRepository.delete(otpVerification);
                throw new RuntimeException("Too many failed attempts. Please request a new OTP.");
            }
            
            throw new RuntimeException("Invalid OTP");
        }

        // Mark OTP as verified
        otpVerification.setVerified(true);
        otpRepository.save(otpVerification);

        // Activate user if it's a registration OTP
        if (request.getType() == OtpVerification.OtpType.EMAIL_REGISTRATION || 
            request.getType() == OtpVerification.OtpType.PHONE_REGISTRATION) {
            
            Optional<User> userOpt = identifier.contains("@") ? 
                userRepository.findByEmail(identifier) : 
                userRepository.findByPhoneNumber(identifier);
            
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                user.setActive(true);
                user = userRepository.save(user);
                
                // Send welcome messages after OTP verification for registration
                if (request.getType() == OtpVerification.OtpType.PHONE_REGISTRATION) {
                    try {
                        if (user.getEmail() != null) {
                            emailService.sendWelcomeEmail(user.getEmail(), user.getFullName());
                        }
                        if (user.getPhoneNumber() != null) {
                            smsService.sendWelcomeSms(user.getPhoneNumber(), user.getFullName());
                        }
                    } catch (Exception e) {
                        System.err.println("Failed to send welcome messages after OTP: " + e.getMessage());
                    }
                }
            }
        }

        // Send login welcome messages for login OTP verification
        if (request.getType() == OtpVerification.OtpType.EMAIL_LOGIN || 
            request.getType() == OtpVerification.OtpType.PHONE_LOGIN) {
            
            Optional<User> userOpt = identifier.contains("@") ? 
                userRepository.findByEmail(identifier) : 
                userRepository.findByPhoneNumber(identifier);
            
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                try {
                    if (user.getEmail() != null) {
                        emailService.sendLoginWelcomeEmail(user.getEmail(), user.getFullName());
                    }
                    if (user.getPhoneNumber() != null) {
                        smsService.sendLoginWelcomeSms(user.getPhoneNumber(), user.getFullName());
                    }
                } catch (Exception e) {
                    System.err.println("Failed to send login welcome messages after OTP: " + e.getMessage());
                }
            }
        }

        // Get user and generate token
        Optional<User> userOpt = identifier.contains("@") ? 
            userRepository.findByEmail(identifier) : 
            userRepository.findByPhoneNumber(identifier);
        
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        User user = userOpt.get();
        String token = jwtUtil.generateToken(user.getId(), "USER");
        
        AuthResponse response = new AuthResponse(token, user.getId(), user.getFullName(), "USER");
        response.setEmail(user.getEmail());
        response.setPhoneNumber(user.getPhoneNumber());
        response.setDistrict(user.getDistrict());
        response.setPanchayat(user.getPanchayat());
        response.setWard(user.getWard());
        response.setHomeAddress(user.getHomeAddress());
        response.setAadhaarNumber(user.getAadhaarNumber());
        response.setAadhaarVerified(user.isAadhaarVerified());
        response.setExpiresAt(LocalDateTime.now().plusDays(1));
        
        return response;
    }

    public void resendOtp(String identifier, OtpVerification.OtpType type) {
        // Check rate limiting
        long count = otpRepository.countByIdentifierAndType(identifier, type);
        if (count >= 3) {
            throw new RuntimeException("Maximum OTP requests exceeded. Please try again later.");
        }

        // Delete existing OTP
        otpRepository.deleteByIdentifierAndType(identifier, type);
        
        // Generate and send new OTP
        String otp = generateOtp();
        saveOtp(identifier, otp, type);
        
        if (identifier.contains("@")) {
            emailService.sendOtp(identifier, otp);
        } else {
            smsService.sendOtp(identifier, otp);
        }
    }

    private String generateOtp() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }

    private void saveOtp(String identifier, String otp, OtpVerification.OtpType type) {
        OtpVerification otpVerification = new OtpVerification(identifier, otp, type);
        otpRepository.save(otpVerification);
    }

    public User updateProfile(ProfileUpdateRequest request) {
        Optional<User> userOpt = userRepository.findById(request.getUserId());
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        User user = userOpt.get();

        try {
            // Update full name if provided
            if (request.getFullName() != null) user.setFullName(request.getFullName());

            // Safely update profile fields
            if (request.getDistrict() != null) user.setDistrict(request.getDistrict());
            if (request.getPanchayat() != null) user.setPanchayat(request.getPanchayat());
            if (request.getWard() != null) user.setWard(request.getWard());
            if (request.getHomeAddress() != null) user.setHomeAddress(request.getHomeAddress());
            if (request.getAadhaarNumber() != null) user.setAadhaarNumber(request.getAadhaarNumber());

            // Update Aadhaar verification status
            user.setAadhaarVerified(request.isAadhaarVerified());

            // Set profileCompleted only if all required fields are filled
            user.setProfileCompleted(
                user.getFullName() != null &&
                user.getDistrict() != null &&
                user.getPanchayat() != null &&
                user.getWard() != null &&
                user.getHomeAddress() != null
            );

            return userRepository.save(user);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Profile update failed: " + e.getMessage());
        }
    }
}