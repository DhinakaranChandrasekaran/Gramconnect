package com.gramconnect.service;

import com.gramconnect.dto.AdminCreateRequest;
import com.gramconnect.model.Admin;
import com.gramconnect.model.User;
import com.gramconnect.repository.AdminRepository;
import com.gramconnect.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AdminService {

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private EmailService emailService;

    /**
     * Create a new admin account (SUPER_ADMIN only)
     */
    public Admin createAdmin(AdminCreateRequest request) {
        // Validate email is not already used by admin
        if (adminRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Admin with this email already exists");
        }

        // Validate email is not already used by user
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email is already registered as a user account");
        }

        // Create new admin
        Admin admin = new Admin();
        admin.setFullName(request.getFullName());
        admin.setEmail(request.getEmail());
        admin.setPassword(passwordEncoder.encode(request.getPassword()));
        
        // Set role based on request or default to VILLAGE_ADMIN
        try {
            admin.setRole(Admin.AdminRole.valueOf(request.getRole().toUpperCase()));
        } catch (IllegalArgumentException e) {
            admin.setRole(Admin.AdminRole.VILLAGE_ADMIN);
        }
        
        admin.setActive(true);

        // Save admin to database
        Admin savedAdmin = adminRepository.save(admin);

        // Send welcome email to new admin
        try {
            emailService.sendAdminWelcomeEmail(
                savedAdmin.getEmail(), 
                savedAdmin.getFullName(),
                request.getPassword() // Send temporary password
            );
        } catch (Exception e) {
            System.err.println("Failed to send admin welcome email: " + e.getMessage());
        }

        return savedAdmin;
    }

    /**
     * Promote an existing user to admin (SUPER_ADMIN only)
     */
    public Admin promoteUserToAdmin(String userId) {
        // Find the user
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found with ID: " + userId);
        }

        User user = userOpt.get();

        // Check if user email is already an admin
        if (adminRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("User is already an admin");
        }

        // Create admin account from user data
        Admin admin = new Admin();
        admin.setFullName(user.getFullName());
        admin.setEmail(user.getEmail());
        admin.setPassword(user.getPassword()); // Keep same password
        admin.setRole(Admin.AdminRole.VILLAGE_ADMIN); // Default role for promoted users
        admin.setActive(true);

        // Save admin
        Admin savedAdmin = adminRepository.save(admin);

        // Send promotion notification email
        try {
            emailService.sendAdminPromotionEmail(
                savedAdmin.getEmail(), 
                savedAdmin.getFullName()
            );
        } catch (Exception e) {
            System.err.println("Failed to send admin promotion email: " + e.getMessage());
        }

        return savedAdmin;
    }

    /**
     * Get all admins (SUPER_ADMIN only)
     */
    public List<Admin> getAllAdmins() {
        return adminRepository.findAll();
    }

    /**
     * Get admin by ID
     */
    public Admin getAdminById(String adminId) {
        Optional<Admin> adminOpt = adminRepository.findById(adminId);
        if (adminOpt.isEmpty()) {
            throw new RuntimeException("Admin not found with ID: " + adminId);
        }
        return adminOpt.get();
    }

    /**
     * Update admin role (SUPER_ADMIN only)
     */
    public Admin updateAdminRole(String adminId, String newRole) {
        Admin admin = getAdminById(adminId);
        
        try {
            admin.setRole(Admin.AdminRole.valueOf(newRole.toUpperCase()));
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid admin role: " + newRole);
        }
        
        return adminRepository.save(admin);
    }

    /**
     * Deactivate admin (SUPER_ADMIN only)
     */
    public Admin deactivateAdmin(String adminId) {
        Admin admin = getAdminById(adminId);
        
        if (admin.getRole() == Admin.AdminRole.SUPER_ADMIN) {
            throw new RuntimeException("Cannot deactivate SUPER_ADMIN");
        }
        
        admin.setActive(false);
        return adminRepository.save(admin);
    }

    /**
     * Activate admin (SUPER_ADMIN only)
     */
    public Admin activateAdmin(String adminId) {
        Admin admin = getAdminById(adminId);
        admin.setActive(true);
        return adminRepository.save(admin);
    }

    /**
     * Get admin statistics
     */
    public long getAdminCount() {
        return adminRepository.count();
    }

    public long getActiveAdminCount() {
        return adminRepository.findAll().stream()
            .mapToLong(admin -> admin.isActive() ? 1 : 0)
            .sum();
    }
}