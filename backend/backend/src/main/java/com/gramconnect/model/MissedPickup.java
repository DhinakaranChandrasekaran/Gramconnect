package com.gramconnect.model;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DBRef;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.io.Serializable;
import java.time.LocalDateTime;

@Document(collection = "missed_pickups")
public class MissedPickup implements Serializable {

    public enum Status {
        PENDING, ACKNOWLEDGED, RESOLVED
    }

    @Id
    private String id;

    @DBRef(lazy = true)
    @JsonIgnore
    private User user;

    private String userId;
    private String district;
    private String village;
    private String ward;
    private LocalDateTime scheduledDate;
    private String reason;
    private String description;
    private Status status = Status.PENDING;
    private String adminResponse;

    @CreatedDate
    private LocalDateTime reportedAt;

    @LastModifiedDate
    private LocalDateTime resolvedAt;

    // Constructors
    public MissedPickup() {}

    public MissedPickup(String userId, String district, String village, String ward,
                        LocalDateTime scheduledDate, String reason, String description) {
        this.userId = userId;
        this.district = district;
        this.village = village;
        this.ward = ward;
        this.scheduledDate = scheduledDate;
        this.reason = reason;
        this.description = description;
        this.status = Status.PENDING;
        this.reportedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public LocalDateTime getScheduledDate() { return scheduledDate; }
    public void setScheduledDate(LocalDateTime scheduledDate) { this.scheduledDate = scheduledDate; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public String getAdminResponse() { return adminResponse; }
    public void setAdminResponse(String adminResponse) { this.adminResponse = adminResponse; }

    public LocalDateTime getReportedAt() { return reportedAt; }
    public void setReportedAt(LocalDateTime reportedAt) { this.reportedAt = reportedAt; }

    public LocalDateTime getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(LocalDateTime resolvedAt) { this.resolvedAt = resolvedAt; }
}