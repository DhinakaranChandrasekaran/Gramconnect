package com.gramconnect.dto.complaint;

import com.gramconnect.model.Complaint;

import java.time.LocalDateTime;

public class ComplaintResponse {
    private String id;
    private String userId;
    private Complaint.Category category;
    private String description;
    private String imageUrl;
    private String district;
    private String panchayat;
    private String village;
    private String ward;
    private Complaint.Location location;
    private Complaint.Status status;
    private boolean reminderSent;
    private Complaint.Feedback feedback;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public ComplaintResponse() {}

    public ComplaintResponse(Complaint complaint) {
        this.id = complaint.getId();
        this.userId = complaint.getUserId();
        this.category = complaint.getCategory();
        this.description = complaint.getDescription();
        this.imageUrl = complaint.getImageUrl();
        this.district = complaint.getDistrict();
        this.panchayat = complaint.getPanchayat();
        this.village = complaint.getVillage();
        this.ward = complaint.getWard();
        this.location = complaint.getLocation();
        this.status = complaint.getStatus();
        this.reminderSent = complaint.isReminderSent();
        this.feedback = complaint.getFeedback();
        this.createdAt = complaint.getCreatedAt();
        this.updatedAt = complaint.getUpdatedAt();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public Complaint.Category getCategory() { return category; }
    public void setCategory(Complaint.Category category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPanchayat() { return panchayat; }
    public void setPanchayat(String panchayat) { this.panchayat = panchayat; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public Complaint.Location getLocation() { return location; }
    public void setLocation(Complaint.Location location) { this.location = location; }

    public Complaint.Status getStatus() { return status; }
    public void setStatus(Complaint.Status status) { this.status = status; }

    public boolean isReminderSent() { return reminderSent; }
    public void setReminderSent(boolean reminderSent) { this.reminderSent = reminderSent; }

    public Complaint.Feedback getFeedback() { return feedback; }
    public void setFeedback(Complaint.Feedback feedback) { this.feedback = feedback; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}