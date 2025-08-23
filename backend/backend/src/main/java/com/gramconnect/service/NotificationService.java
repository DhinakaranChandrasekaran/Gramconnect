package com.gramconnect.service;

import com.gramconnect.model.Notification;
import com.gramconnect.repository.NotificationRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@Service
public class NotificationService {
    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    public List<Notification> getUserNotifications(String userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<Notification> getUnreadNotifications(String userId) {
        return notificationRepository.findByUserIdAndReadOrderByCreatedAtDesc(userId, false);
    }

    public long getUnreadCount(String userId) {
        return notificationRepository.countByUserIdAndRead(userId, false);
    }

    public Notification markAsRead(String notificationId, String userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Notification not found"));

        if (!notification.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }

        notification.setRead(true);
        return notificationRepository.save(notification);
    }

    public Notification createNotification(String userId, String title, String body, 
                                         Notification.Type type, Map<String, Object> meta) {
        Notification notification = new Notification(userId, title, body, type);
        if (meta != null) {
            notification.setMeta(meta);
        }
        return notificationRepository.save(notification);
    }

    public void createSystemNotification(String userId, String title, String body) {
        createNotification(userId, title, body, Notification.Type.INFO, null);
    }

    public void createComplaintUpdateNotification(String userId, String complaintId, String status) {
        Map<String, Object> meta = Map.of("complaintId", complaintId, "status", status);
        createNotification(
            userId,
            "Complaint Status Updated",
            "Your complaint status has been updated to: " + status.toLowerCase(),
            Notification.Type.COMPLAINT_UPDATE,
            meta
        );
    }

    public void createReminderNotification(String userId, String complaintId) {
        Map<String, Object> meta = Map.of("complaintId", complaintId);
        createNotification(
            userId,
            "Complaint Reminder Sent",
            "Your complaint reminder has been sent to administrators",
            Notification.Type.REMINDER,
            meta
        );
    }
}