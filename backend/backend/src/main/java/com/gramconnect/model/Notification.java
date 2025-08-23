package com.gramconnect.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.Map;

@Document(collection = "notifications")
public class Notification {
    @Id
    private String id;

    @NotBlank(message = "User ID is required")
    private String userId;

    @NotBlank(message = "Title is required")
    @Size(max = 100, message = "Title must not exceed 100 characters")
    private String title;

    @NotBlank(message = "Body is required")
    @Size(max = 300, message = "Body must not exceed 300 characters")
    private String body;

    @Field("type")
    private Type type = Type.INFO;

    @Field("meta")
    private Map<String, Object> meta;

    private boolean read = false;

    @CreatedDate
    private LocalDateTime createdAt;

    public enum Type {
        INFO, COMPLAINT_UPDATE, REMINDER, SCHEDULE_UPDATE, ADMIN_MESSAGE
    }

    // Constructors
    public Notification() {}

    public Notification(String userId, String title, String body, Type type) {
        this.userId = userId;
        this.title = title;
        this.body = body;
        this.type = type;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public Type getType() { return type; }
    public void setType(Type type) { this.type = type; }

    public Map<String, Object> getMeta() { return meta; }
    public void setMeta(Map<String, Object> meta) { this.meta = meta; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}