package com.gramconnect.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class SmsService {

    private static final Logger logger = LoggerFactory.getLogger(SmsService.class);

    // Simulate sending OTP by just logging it
    public void sendOtp(String phoneNumber, String otp) {
        logger.info("📲 Simulated SMS OTP sent to {}: OTP = {}", phoneNumber, otp);
    }

    public void sendComplaintStatusUpdate(String phoneNumber, String complaintId, String status) {
        String message = "📢 GramConnect: Your complaint " + complaintId + " status updated to " + status + ". Check app for details.";
        sendTransactionalSms(phoneNumber, message);
    }

    public void sendWelcomeSms(String phoneNumber, String userName) {
        String message = "👋 Welcome to GramConnect, " + userName + "! Your account is ready. Start reporting civic issues and track complaints. Thank you for joining our smart village initiative.";
        sendTransactionalSms(phoneNumber, message);
    }

    public void sendLoginWelcomeSms(String phoneNumber, String userName) {
        String message = "✅ Welcome back to GramConnect, " + userName + "! You have successfully logged in. Continue managing your civic complaints.";
        sendTransactionalSms(phoneNumber, message);
    }

    public void sendGarbagePickupReminder(String phoneNumber, String message) {
        String finalMessage = "🗑️ Garbage Pickup Reminder: " + message + " - GramConnect";
        sendTransactionalSms(phoneNumber, finalMessage);
    }

    // Core method to simulate transactional SMS
    private void sendTransactionalSms(String phoneNumber, String message) {
        logger.info("📩 Simulated transactional SMS sent to {}: Message = {}", phoneNumber, message);
    }
}
