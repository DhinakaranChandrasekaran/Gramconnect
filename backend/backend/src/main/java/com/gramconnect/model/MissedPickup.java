package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import jakarta.validation.constraints.NotBlank;

import java.time.LocalDateTime;

@Document(collection = "missedPickups")
public class MissedPickup {
    @Id
    private String id;

    @NotBlank(message = "User ID is required")
    private String userId;

    @NotBlank(message = "Schedule ID is required")
    private String scheduleId;

    private String complaintId;

    @Field("location")
    private Complaint.Location location;

    @NotBlank(message = "Village is required")
    private String village;

    private String note;

    private LocalDateTime timestamp;

    @Field("status")
    private Status status = Status.OPEN;

    private String handledByAdminId;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    public enum Status {
        OPEN, ACKNOWLEDGED, RESOLVED
    }

    // Constructors
    public MissedPickup() {}

    public MissedPickup(String userId, String scheduleId, String village, String note) {
        this.userId = userId;
        this.scheduleId = scheduleId;
        this.village = village;
        this.note = note;
        this.timestamp = LocalDateTime.now();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getScheduleId() { return scheduleId; }
    public void setScheduleId(String scheduleId) { this.scheduleId = scheduleId; }

    public String getComplaintId() { return complaintId; }
    public void setComplaintId(String complaintId) { this.complaintId = complaintId; }

    public Complaint.Location getLocation() { return location; }
    public void setLocation(Complaint.Location location) { this.location = location; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public String getHandledByAdminId() { return handledByAdminId; }
    public void setHandledByAdminId(String handledByAdminId) { this.handledByAdminId = handledByAdminId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}