package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.time.LocalDateTime;

@Document(collection = "complaints")
public class Complaint {
    @Id
    private String id;
    
    private String complaintId;
    
    @DBRef
    private User user;
    
    private String userId;
    
    private Category category;
    
    private String description;
    
    private String imageUrl;
    
    private Location location;
    
    private String village;
    
    private String ward;
    
    private Status status = Status.PENDING;
    
    private boolean reminderSent = false;
    
    private String feedback;
    
    private Integer rating;
    
    private String adminResponse;
    
    @CreatedDate
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;
    
    private LocalDateTime resolvedAt;

    public enum Category {
        GARBAGE, WATER_SUPPLY, ELECTRICITY, DRAINAGE, ROAD_DAMAGE, HEALTH_CENTER, TRANSPORT
    }

    public enum Status {
        PENDING, IN_PROGRESS, RESOLVED, REJECTED
    }

    public static class Location {
        private double latitude;
        private double longitude;
        private String address;

        public Location() {}

        public Location(double latitude, double longitude, String address) {
            this.latitude = latitude;
            this.longitude = longitude;
            this.address = address;
        }

        // Getters and Setters
        public double getLatitude() { return latitude; }
        public void setLatitude(double latitude) { this.latitude = latitude; }

        public double getLongitude() { return longitude; }
        public void setLongitude(double longitude) { this.longitude = longitude; }

        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
    }

    // Constructors
    public Complaint() {}

    public Complaint(String userId, Category category, String description, Location location, String village) {
        this.userId = userId;
        this.category = category;
        this.description = description;
        this.location = location;
        this.village = village;
        this.complaintId = generateComplaintId();
    }

    private String generateComplaintId() {
        return "GC" + System.currentTimeMillis();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getComplaintId() { return complaintId; }
    public void setComplaintId(String complaintId) { this.complaintId = complaintId; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public Location getLocation() { return location; }
    public void setLocation(Location location) { this.location = location; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public boolean isReminderSent() { return reminderSent; }
    public void setReminderSent(boolean reminderSent) { this.reminderSent = reminderSent; }

    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getAdminResponse() { return adminResponse; }
    public void setAdminResponse(String adminResponse) { this.adminResponse = adminResponse; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public LocalDateTime getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(LocalDateTime resolvedAt) { this.resolvedAt = resolvedAt; }
}