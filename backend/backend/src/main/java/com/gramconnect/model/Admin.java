package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;

import java.time.LocalDateTime;
import java.util.List;

@Document(collection = "admins")
public class Admin {
    @Id
    private String id;
    
    private String fullName;
    
    @Indexed(unique = true)
    private String email;
    
    private String password;
    
    private List<String> assignedAreas;
    
    private List<String> assignedVillages;
    
    private AdminRole role = AdminRole.VILLAGE_ADMIN;
    
    private boolean isActive = true;
    
    @CreatedDate
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;

    public enum AdminRole {
        SUPER_ADMIN, DISTRICT_ADMIN, BLOCK_ADMIN, VILLAGE_ADMIN
    }

    // Constructors
    public Admin() {}

    public Admin(String fullName, String email, List<String> assignedVillages) {
        this.fullName = fullName;
        this.email = email;
        this.assignedVillages = assignedVillages;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public List<String> getAssignedAreas() { return assignedAreas; }
    public void setAssignedAreas(List<String> assignedAreas) { this.assignedAreas = assignedAreas; }

    public List<String> getAssignedVillages() { return assignedVillages; }
    public void setAssignedVillages(List<String> assignedVillages) { this.assignedVillages = assignedVillages; }

    public AdminRole getRole() { return role; }
    public void setRole(AdminRole role) { this.role = role; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}