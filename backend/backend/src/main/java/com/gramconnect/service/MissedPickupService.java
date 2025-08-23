package com.gramconnect.service;

import com.gramconnect.model.MissedPickup;
import com.gramconnect.model.Notification;
import com.gramconnect.repository.MissedPickupRepository;
import com.gramconnect.repository.NotificationRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class MissedPickupService {
    private final MissedPickupRepository missedPickupRepository;
    private final NotificationRepository notificationRepository;

    public MissedPickupService(MissedPickupRepository missedPickupRepository,
                              NotificationRepository notificationRepository) {
        this.missedPickupRepository = missedPickupRepository;
        this.notificationRepository = notificationRepository;
    }

    public MissedPickup reportMissedPickup(String userId, String scheduleId, String village, String note) {
        MissedPickup missedPickup = new MissedPickup(userId, scheduleId, village, note);
        missedPickup = missedPickupRepository.save(missedPickup);

        // Create notification
        Notification notification = new Notification(
            userId,
            "Missed Pickup Reported",
            "Your missed pickup report has been submitted successfully",
            Notification.Type.INFO
        );
        notificationRepository.save(notification);

        return missedPickup;
    }

    public List<MissedPickup> getUserMissedPickups(String userId) {
        return missedPickupRepository.findByUserId(userId);
    }

    public List<MissedPickup> getAllMissedPickups() {
        return missedPickupRepository.findAll();
    }

    public List<MissedPickup> getMissedPickupsByStatus(MissedPickup.Status status) {
        return missedPickupRepository.findByStatus(status);
    }

    public List<MissedPickup> getMissedPickupsByVillage(String village) {
        return missedPickupRepository.findByVillage(village);
    }

    public MissedPickup updateStatus(String id, MissedPickup.Status status, String adminId) {
        MissedPickup missedPickup = missedPickupRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Missed pickup not found"));

        missedPickup.setStatus(status);
        missedPickup.setHandledByAdminId(adminId);
        missedPickup = missedPickupRepository.save(missedPickup);

        // Create notification for user
        String statusText = status.toString().toLowerCase().replace("_", " ");
        Notification notification = new Notification(
            missedPickup.getUserId(),
            "Missed Pickup Update",
            "Your missed pickup report status has been updated to: " + statusText,
            Notification.Type.INFO
        );
        notificationRepository.save(notification);

        return missedPickup;
    }
}