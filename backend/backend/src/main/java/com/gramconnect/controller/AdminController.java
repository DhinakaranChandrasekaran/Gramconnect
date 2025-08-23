package com.gramconnect.controller;

import com.gramconnect.model.Admin;
import com.gramconnect.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admins")
@Tag(name = "Admin Management", description = "Admin management operations")
@CrossOrigin(origins = "*")
public class AdminController {
    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @PostMapping("/seed")
    @Operation(summary = "Seed super admin (one-time setup)")
    public ResponseEntity<Admin> seedSuperAdmin(@RequestBody Map<String, String> request) {
        return ResponseEntity.ok(adminService.seedSuperAdmin(
            request.get("email"),
            request.get("password")
        ));
    }

    @PostMapping
    @Operation(summary = "Create admin (super admin only)")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Admin> createAdmin(@RequestBody Map<String, String> request) {
        return ResponseEntity.ok(adminService.createAdmin(
            request.get("fullName"),
            request.get("email"),
            request.get("password"),
            request.get("assignedDistrict"),
            request.get("assignedPanchayat")
        ));
    }

    @GetMapping
    @Operation(summary = "Get all admins (super admin only)")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<List<Admin>> getAllAdmins() {
        return ResponseEntity.ok(adminService.getAllAdmins());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get admin by ID")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Admin> getAdmin(@PathVariable String id) {
        return ResponseEntity.ok(adminService.getAdminById(id));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update admin (super admin only)")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Admin> updateAdmin(
            @PathVariable String id,
            @RequestBody Map<String, Object> request) {
        return ResponseEntity.ok(adminService.updateAdmin(
            id,
            (String) request.get("fullName"),
            (String) request.get("assignedDistrict"),
            (String) request.get("assignedPanchayat"),
            (Boolean) request.get("active")
        ));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete admin (super admin only)")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<String> deleteAdmin(@PathVariable String id) {
        adminService.deleteAdmin(id);
        return ResponseEntity.ok("Admin deleted successfully");
    }
}