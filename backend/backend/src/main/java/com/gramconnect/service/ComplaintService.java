package com.gramconnect.service;

import com.gramconnect.dto.complaint.ComplaintRequest;
import com.gramconnect.dto.complaint.ComplaintResponse;
import com.gramconnect.model.Complaint;
import com.gramconnect.model.Notification;
import com.gramconnect.repository.ComplaintRepository;
import com.gramconnect.repository.NotificationRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ComplaintService {
    private final ComplaintRepository complaintRepository;
    private final NotificationRepository notificationRepository;

    public ComplaintService(ComplaintRepository complaintRepository, 
                           NotificationRepository notificationRepository) {
        this.complaintRepository = complaintRepository;
        this.notificationRepository = notificationRepository;
    }

    public ComplaintResponse createComplaint(String userId, ComplaintRequest request) {
        Complaint complaint = new Complaint();
        complaint.setUserId(userId);
        complaint.setCategory(request.getCategory());
       complaint.setTitle(request.getTitle());
        complaint.setDescription(request.getDescription());
        complaint.setDistrict(request.getDistrict());
        complaint.setPanchayat(request.getPanchayat());
        complaint.setVillage(request.getVillage());
        complaint.setWard(request.getWard());

        // Set location if provided
        if (request.getLat() != 0 && request.getLng() != 0) {
            complaint.setLocation(new Complaint.Location(request.getLat(), request.getLng()));
        }

        complaint = complaintRepository.save(complaint);

        // Create notification
        Notification notification = new Notification(
            userId,
            "Complaint Submitted",
            "Your complaint has been submitted successfully. ID: " + complaint.getId(),
            Notification.Type.COMPLAINT_UPDATE
        );
        notificationRepository.save(notification);

        return new ComplaintResponse(complaint);
    }

    public List<ComplaintResponse> getUserComplaints(String userId) {
        return complaintRepository.findByUserId(userId)
                .stream()
                .map(ComplaintResponse::new)
                .collect(Collectors.toList());
    }

    public ComplaintResponse getComplaintDetails(String complaintId, String userId) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Complaint not found"));

        if (!complaint.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }

        return new ComplaintResponse(complaint);
    }

    public ComplaintResponse updateStatus(String complaintId, Complaint.Status status) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Complaint not found"));

        complaint.setStatus(status);
        complaint = complaintRepository.save(complaint);

        // Create notification for user
        String statusText = status.toString().toLowerCase().replace("_", " ");
        Notification notification = new Notification(
            complaint.getUserId(),
            "Complaint Status Updated",
            "Your complaint status has been updated to: " + statusText,
            Notification.Type.COMPLAINT_UPDATE
        );
        notificationRepository.save(notification);

        return new ComplaintResponse(complaint);
    }

    public boolean canSendReminder(String complaintId, String userId) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Complaint not found"));

        if (!complaint.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }

        // Can send reminder if:
        // 1. Complaint is older than 24 hours
        // 2. Status is PENDING or IN_PROGRESS
        // 3. Reminder not already sent
        LocalDateTime twentyFourHoursAgo = LocalDateTime.now().minusHours(24);
        return complaint.getCreatedAt().isBefore(twentyFourHoursAgo) && 
               (complaint.getStatus() == Complaint.Status.PENDING || 
                complaint.getStatus() == Complaint.Status.IN_PROGRESS) &&
               !complaint.isReminderSent();
    }

    public void sendReminder(String complaintId, String userId) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Complaint not found"));

        if (!complaint.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }

        if (!canSendReminder(complaintId, userId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cannot send reminder at this time");
        }

        complaint.setReminderSent(true);
        complaintRepository.save(complaint);

        // Create reminder notification
        Notification notification = new Notification(
            userId,
            "Reminder Sent",
            "Your complaint reminder has been sent to administrators",
            Notification.Type.REMINDER
        );
        notificationRepository.save(notification);
    }

    public ComplaintResponse submitFeedback(String complaintId, String userId, 
                                          Complaint.Feedback.Rating rating, String note) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Complaint not found"));

        if (!complaint.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }

        if (complaint.getStatus() != Complaint.Status.RESOLVED) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Can only provide feedback for resolved complaints");
        }

        complaint.setFeedback(new Complaint.Feedback(rating, note));
        complaint = complaintRepository.save(complaint);

        return new ComplaintResponse(complaint);
    }
}