package com.gramconnect.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    // ========================= COMMON EMAIL SENDER =========================
    private void sendEmail(String toEmail, String subject, String body) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject(subject);
            message.setText(body);
            mailSender.send(message);
            System.out.println("✅ Email sent to: " + toEmail + " | Subject: " + subject);
        } catch (Exception e) {
            System.err.println("❌ Failed to send email to: " + toEmail + " | Error: " + e.getMessage());
        }
    }

    // ========================= USER EMAILS =========================
    public void sendOtp(String toEmail, String otp) {
        String body = "Dear User,\n\n"
                + "Your OTP for GramConnect verification is: " + otp + "\n\n"
                + "This OTP is valid for 5 minutes.\n"
                + "Please do not share this OTP with anyone.\n\n"
                + "Thank you,\nGramConnect Team";
        sendEmail(toEmail, "GramConnect - OTP Verification", body);
    }

    public void sendComplaintStatusUpdate(String toEmail, String complaintId, String status) {
        String body = "Dear Citizen,\n\n"
                + "Your complaint (ID: " + complaintId + ") status has been updated to: " + status + ".\n"
                + "You can check the details in the GramConnect app.\n\n"
                + "Thank you for using GramConnect.\n\n"
                + "Best regards,\nGramConnect Team";
        sendEmail(toEmail, "GramConnect - Complaint Status Updated", body);
    }

    public void sendWelcomeEmail(String toEmail, String userName) {
        String body = "Dear " + userName + ",\n\n"
                + "Welcome to GramConnect - Smart Village Grievance & Civic Service Reporting System!\n\n"
                + "Your account has been successfully created. You can now:\n"
                + "• Report civic issues in your village\n"
                + "• Track complaint status in real-time\n"
                + "• View garbage collection schedules\n"
                + "• Send reminders for pending complaints\n\n"
                + "Thank you for being part of our smart village initiative.\n\n"
                + "Best regards,\nGramConnect Team";
        sendEmail(toEmail, "Welcome to GramConnect", body);
    }

    public void sendLoginWelcomeEmail(String toEmail, String userName) {
        String body = "Dear " + userName + ",\n\n"
                + "Welcome back to GramConnect!\n\n"
                + "You have successfully logged into your account.\n"
                + "Continue managing your civic complaints and stay connected with your village services.\n\n"
                + "If you didn't log in, please contact our support team immediately.\n\n"
                + "Best regards,\nGramConnect Team";
        sendEmail(toEmail, "Welcome Back to GramConnect", body);
    }

    public void sendGarbagePickupReminder(String toEmail, String userName, String reminderMessage) {
        String body = "Dear " + userName + ",\n\n"
                + reminderMessage + "\n\n"
                + "Thank you for keeping your village clean.\n\n"
                + "Best regards,\nGramConnect Team";
        sendEmail(toEmail, "GramConnect - Garbage Pickup Reminder", body);
    }

    // ========================= ADMIN EMAILS =========================
    public void sendAdminWelcomeEmail(String toEmail, String adminName, String temporaryPassword) {
        String body = "Dear " + adminName + ",\n\n"
                + "Welcome to GramConnect Admin Panel!\n\n"
                + "Your admin account has been successfully created.\n\n"
                + "Login Details:\n"
                + "Email: " + toEmail + "\n"
                + "Temporary Password: " + temporaryPassword + "\n\n"
                + "Please change your password after first login for security.\n\n"
                + "You can now access the admin panel to:\n"
                + "• Manage complaints and civic issues\n"
                + "• Handle garbage collection schedules\n"
                + "• Monitor user feedback and reports\n"
                + "• Oversee village civic services\n\n"
                + "Thank you for joining our smart village initiative.\n\n"
                + "Best regards,\nGramConnect Team";
        sendEmail(toEmail, "Welcome to GramConnect Admin Panel", body);
    }

    public void sendAdminPromotionEmail(String toEmail, String adminName) {
        String body = "Dear " + adminName + ",\n\n"
                + "Congratulations! Your GramConnect account has been promoted to Admin.\n\n"
                + "You now have access to the admin panel with the following capabilities:\n"
                + "• Manage complaints and civic issues\n"
                + "• Handle garbage collection schedules\n"
                + "• Monitor user feedback and reports\n"
                + "• Oversee village civic services\n\n"
                + "You can continue using your existing login credentials to access the admin panel.\n\n"
                + "Thank you for your continued support of our smart village initiative.\n\n"
                + "Best regards,\nGramConnect Team";
        sendEmail(toEmail, "GramConnect - Account Promoted to Admin", body);
    }
}
