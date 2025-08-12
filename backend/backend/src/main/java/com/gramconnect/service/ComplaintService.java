package com.gramconnect.service;

import com.gramconnect.dto.ComplaintRequest;
import com.gramconnect.model.Complaint;
import com.gramconnect.model.User;
import com.gramconnect.repository.ComplaintRepository;
import com.gramconnect.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ComplaintService {

    @Autowired
    private ComplaintRepository complaintRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FileStorageService fileStorageService;

    public Complaint createComplaint(String userId, ComplaintRequest request) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        User user = userOpt.get();
        
        Complaint complaint = new Complaint();
        complaint.setUserId(userId);
        complaint.setUser(user);
        complaint.setCategory(request.getCategory());
        complaint.setDescription(request.getDescription());
        complaint.setVillage(request.getVillage());
        complaint.setWard(request.getWard());
        
        // Convert location
        if (request.getLocation() != null) {
            Complaint.Location location = new Complaint.Location(
                request.getLocation().getLatitude(),
                request.getLocation().getLongitude(),
                request.getLocation().getAddress()
            );
            complaint.setLocation(location);
        }
        
        // Handle image upload
        if (request.getImageBase64() != null && !request.getImageBase64().isEmpty()) {
            String imageUrl = fileStorageService.saveImage(request.getImageBase64());
            complaint.setImageUrl(imageUrl);
        }
        
        // Generate complaint ID
        complaint.setComplaintId("GC" + System.currentTimeMillis());
        
        return complaintRepository.save(complaint);
    }

    public List<Complaint> getUserComplaints(String userId) {
        return complaintRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<Complaint> getAllComplaints() {
        return complaintRepository.findAll();
    }

    public List<Complaint> getComplaintsByStatus(Complaint.Status status) {
        return complaintRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    public List<Complaint> getComplaintsByVillage(String village) {
        return complaintRepository.findByVillageOrderByCreatedAtDesc(village);
    }

    public List<Complaint> getComplaintsByCategory(Complaint.Category category) {
        return complaintRepository.findByCategoryOrderByCreatedAtDesc(category);
    }

    public Optional<Complaint> getComplaintById(String id) {
        return complaintRepository.findById(id);
    }

    public Complaint updateComplaintStatus(String id, Complaint.Status status, String adminResponse) {
        Optional<Complaint> complaintOpt = complaintRepository.findById(id);
        if (complaintOpt.isEmpty()) {
            throw new RuntimeException("Complaint not found");
        }

        Complaint complaint = complaintOpt.get();
        complaint.setStatus(status);
        
        if (adminResponse != null) {
            complaint.setAdminResponse(adminResponse);
        }
        
        if (status == Complaint.Status.RESOLVED) {
            complaint.setResolvedAt(LocalDateTime.now());
        }
        
        return complaintRepository.save(complaint);
    }

    public Complaint sendReminder(String complaintId, String userId) {
        Optional<Complaint> complaintOpt = complaintRepository.findById(complaintId);
        if (complaintOpt.isEmpty()) {
            throw new RuntimeException("Complaint not found");
        }

        Complaint complaint = complaintOpt.get();
        
        if (!complaint.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized to send reminder for this complaint");
        }

        // Check if 24 hours have passed
        LocalDateTime twentyFourHoursAgo = LocalDateTime.now().minusHours(24);
        if (complaint.getCreatedAt().isAfter(twentyFourHoursAgo)) {
            throw new RuntimeException("Reminder can only be sent after 24 hours of complaint submission");
        }

        if (complaint.isReminderSent()) {
            throw new RuntimeException("Reminder has already been sent for this complaint");
        }

        complaint.setReminderSent(true);
        return complaintRepository.save(complaint);
    }

    public Complaint addFeedback(String complaintId, String userId, String feedback, Integer rating) {
        Optional<Complaint> complaintOpt = complaintRepository.findById(complaintId);
        if (complaintOpt.isEmpty()) {
            throw new RuntimeException("Complaint not found");
        }

        Complaint complaint = complaintOpt.get();
        
        if (!complaint.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized to add feedback for this complaint");
        }

        if (complaint.getStatus() != Complaint.Status.RESOLVED) {
            throw new RuntimeException("Feedback can only be added for resolved complaints");
        }

        complaint.setFeedback(feedback);
        complaint.setRating(rating);
        
        return complaintRepository.save(complaint);
    }

    public List<Complaint> getComplaintsEligibleForReminder() {
        LocalDateTime twentyFourHoursAgo = LocalDateTime.now().minusHours(24);
        return complaintRepository.findComplaintsEligibleForReminder(
            Complaint.Status.PENDING, twentyFourHoursAgo);
    }

    // Dashboard statistics
    public long getComplaintCountByStatus(Complaint.Status status) {
        if (status == null) {
            return complaintRepository.count();
        }
        return complaintRepository.countByStatus(status);
    }

    public long getComplaintCountByCategory(Complaint.Category category) {
        return complaintRepository.countByCategory(category);
    }

    public long getComplaintCountByVillage(String village) {
        return complaintRepository.countByVillage(village);
    }
}