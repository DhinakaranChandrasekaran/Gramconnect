package com.gramconnect.service;

import com.gramconnect.model.Admin;
import com.gramconnect.model.User;
import com.gramconnect.repository.AdminRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class AdminService {
    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.environment:dev}")
    private String environment;

    public AdminService(AdminRepository adminRepository, PasswordEncoder passwordEncoder) {
        this.adminRepository = adminRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public Admin seedSuperAdmin(String email, String password) {
        // Only allow seeding in development or if no super admin exists
        if (!"dev".equals(environment) && adminRepository.count() > 0) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Super admin already exists");
        }

        if (adminRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Admin with this email already exists");
        }

        Admin superAdmin = new Admin();
        superAdmin.setFullName("Super Administrator");
        superAdmin.setEmail(email);
        superAdmin.setPasswordHash(passwordEncoder.encode(password));
        superAdmin.setRole(User.Role.SUPER_ADMIN);
        superAdmin.setActive(true);

        return adminRepository.save(superAdmin);
    }

    public Admin createAdmin(String fullName, String email, String password, 
                           String assignedDistrict, String assignedPanchayat) {
        if (adminRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Admin with this email already exists");
        }

        Admin admin = new Admin();
        admin.setFullName(fullName);
        admin.setEmail(email);
        admin.setPasswordHash(passwordEncoder.encode(password));
        admin.setRole(User.Role.ADMIN);
        admin.setAssignedDistrict(assignedDistrict);
        admin.setAssignedPanchayat(assignedPanchayat);
        admin.setActive(true);

        return adminRepository.save(admin);
    }

    public List<Admin> getAllAdmins() {
        return adminRepository.findAll();
    }

    public Admin getAdminById(String id) {
        return adminRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Admin not found"));
    }

    public Admin updateAdmin(String id, String fullName, String assignedDistrict, String assignedPanchayat, Boolean active) {
        Admin admin = getAdminById(id);
        
        if (fullName != null) admin.setFullName(fullName);
        if (assignedDistrict != null) admin.setAssignedDistrict(assignedDistrict);
        if (assignedPanchayat != null) admin.setAssignedPanchayat(assignedPanchayat);
        if (active != null) admin.setActive(active);

        return adminRepository.save(admin);
    }

    public void deleteAdmin(String id) {
        Admin admin = getAdminById(id);
        if (admin.getRole() == User.Role.SUPER_ADMIN) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Cannot delete super admin");
        }
        adminRepository.deleteById(id);
    }

    public Admin findByEmail(String email) {
        return adminRepository.findByEmail(email).orElse(null);
    }
}