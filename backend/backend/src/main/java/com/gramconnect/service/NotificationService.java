package com.gramconnect.service;

import com.gramconnect.model.GarbageSchedule;
import com.gramconnect.model.User;
import com.gramconnect.repository.GarbageScheduleRepository;
import com.gramconnect.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.TextStyle;
import java.util.List;
import java.util.Locale;

@Service
public class NotificationService {

    @Autowired
    private GarbageScheduleRepository garbageScheduleRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmailService emailService;

    @Autowired
    private SmsService smsService;

    // 🔁 Runs every 5 minutes to check upcoming garbage pickups
    @Scheduled(fixedRate = 300000) // 5 minutes
    public void checkGarbagePickupReminders() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime thirtyMinutesLater = now.plusMinutes(30);

        String currentDay = now.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH);
        List<GarbageSchedule> schedules = garbageScheduleRepository.findAll();

        for (GarbageSchedule schedule : schedules) {
            if (schedule.isActive() && schedule.getCollectionDays().contains(currentDay)) {
                LocalTime pickupTime = schedule.getPickupTime();
                LocalDateTime scheduledPickup = now.toLocalDate().atTime(pickupTime);

                if (scheduledPickup.isAfter(now) && scheduledPickup.isBefore(thirtyMinutesLater)) {
                    sendGarbagePickupReminders(schedule);
                }
            }
        }
    }

    private void sendGarbagePickupReminders(GarbageSchedule schedule) {
        List<User> users = userRepository.findAll().stream()
            .filter(user ->
                user.getDistrict().equalsIgnoreCase(schedule.getDistrict()) &&
                user.getPanchayat().equalsIgnoreCase(schedule.getPanchayat()) &&
                (schedule.getWard() == null || schedule.getWard().equalsIgnoreCase(user.getWard()))
            )
            .toList();

        for (User user : users) {
            try {
                String message = "Garbage collection in " +
                        (schedule.getArea() != null ? schedule.getArea() : "your area") +
                        " starts in 30 minutes at " + schedule.getPickupTime() +
                        ". Please keep your garbage ready.";

                // ✅ Email
                if (user.getEmail() != null && !user.getEmail().isBlank()) {
                    emailService.sendGarbagePickupReminder(user.getEmail(), user.getFullName(), message);
                }

                // ✅ SMS
                if (user.getPhoneNumber() != null && !user.getPhoneNumber().isBlank()) {
                    smsService.sendGarbagePickupReminder(user.getPhoneNumber(),
                            "Garbage pickup in your area starts in 30 minutes. Please be ready. - GramConnect");
                }

            } catch (Exception e) {
                System.err.println("❌ Failed to send pickup reminder to user " + user.getId() + ": " + e.getMessage());
            }
        }
    }

    public void sendComplaintStatusNotification(String userId, String complaintId, String status) {
    try {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) return;

        if (user.getEmail() != null && !user.getEmail().isBlank()) {
            emailService.sendComplaintStatusUpdate(user.getEmail(), complaintId, status);
        }

        if (user.getPhoneNumber() != null && !user.getPhoneNumber().isBlank()) {
            smsService.sendComplaintStatusUpdate(user.getPhoneNumber(), complaintId, status);
        }

    } catch (Exception e) {
        System.err.println("❌ Failed to send complaint status notification: " + e.getMessage());
    }
}

}
