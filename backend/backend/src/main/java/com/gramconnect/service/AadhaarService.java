package com.gramconnect.service;

import com.gramconnect.model.OtpVerification;
import com.gramconnect.repository.OtpVerificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.Random;

@Service
public class AadhaarService {

    @Autowired
    private OtpVerificationRepository otpRepository;

    @Autowired
    private SmsService smsService;

    public boolean verifyAadhaar(String aadhaarNumber) {
        if (aadhaarNumber == null || aadhaarNumber.length() != 12) {
            throw new RuntimeException("Invalid Aadhaar number");
        }

        if (!aadhaarNumber.matches("\\d{12}")) {
            throw new RuntimeException("Aadhaar number must contain only digits");
        }

        return true;
    }

    public String sendAadhaarOtp(String aadhaarNumber, String phoneNumber) {
        if (!verifyAadhaar(aadhaarNumber)) {
            throw new RuntimeException("Invalid Aadhaar number");
        }

        // 🧹 Clean old unverified OTPs for this Aadhaar
        otpRepository.deleteAllByIdentifierAndTypeAndVerifiedFalse(
            aadhaarNumber, OtpVerification.OtpType.AADHAAR_VERIFICATION
        );

        // 🔢 Generate new OTP
        String otp = generateOtp();

        // 💾 Save new OTP
        OtpVerification otpVerification = new OtpVerification(
            aadhaarNumber, otp, OtpVerification.OtpType.AADHAAR_VERIFICATION
        );
        otpRepository.save(otpVerification);

        try {
            // 📌 Log OTP (for testing only)
            System.out.println("📌 Aadhaar OTP for " + aadhaarNumber + " (Phone: " + phoneNumber + "): " + otp);

            // 📲 Simulate sending OTP via SMS
            smsService.sendOtp(phoneNumber, otp);
        } catch (Exception e) {
            throw new RuntimeException("Failed to send Aadhaar OTP: " + e.getMessage());
        }

        return otp;
    }

    public boolean verifyAadhaarOtp(String aadhaarNumber, String otp) {
        Optional<OtpVerification> otpOpt = otpRepository.findByIdentifierAndTypeAndVerifiedFalse(
            aadhaarNumber, OtpVerification.OtpType.AADHAAR_VERIFICATION
        );

        if (otpOpt.isEmpty()) {
            throw new RuntimeException("Invalid or expired OTP");
        }

        OtpVerification otpVerification = otpOpt.get();

        // 🕒 Debug: Print OTP info
        System.out.println("🔍 Verifying Aadhaar OTP for: " + aadhaarNumber);
        System.out.println("🔐 Stored OTP: " + otpVerification.getOtp() + " | Entered: " + otp);
        System.out.println("🕒 Created At: " + otpVerification.getCreatedAt() + " | Expired? " + otpVerification.isExpired());

        if (otpVerification.isExpired()) {
            throw new RuntimeException("OTP has expired");
        }

        if (!otpVerification.getOtp().equals(otp)) {
            otpVerification.setAttempts(otpVerification.getAttempts() + 1);
            otpRepository.save(otpVerification);

            if (otpVerification.getAttempts() >= 3) {
                otpRepository.delete(otpVerification);
                throw new RuntimeException("Too many failed attempts. Please request a new OTP.");
            }

            throw new RuntimeException("Invalid OTP");
        }

        otpVerification.setVerified(true);
        otpRepository.save(otpVerification);
        return true;
    }

    private String generateOtp() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }
}
