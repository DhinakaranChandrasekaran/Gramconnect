package com.gramconnect.service;

import com.gramconnect.model.MissedPickup;
import com.gramconnect.model.User;
import com.gramconnect.repository.MissedPickupRepository;
import com.gramconnect.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MissedPickupService {

    @Autowired
    private MissedPickupRepository missedPickupRepository;

    @Autowired
    private UserRepository userRepository;

    public MissedPickup reportMissedPickup(String userId, LocalDateTime scheduledDate, String reason, String description) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Ensure the constructor arguments match your MissedPickup model
        MissedPickup missedPickup = new MissedPickup(
                userId,
                user.getDistrict(),  // district
                user.getPanchayat(),   // panchayat
                user.getWard(),      // ward
                scheduledDate,
                reason,
                description
        );

        missedPickup.setUser(user);
        return missedPickupRepository.save(missedPickup);
    }

    public List<MissedPickup> getUserMissedPickups(String userId) {
        return missedPickupRepository.findByUserIdOrderByReportedAtDesc(userId);
    }

    public List<MissedPickup> getAllMissedPickups() {
        return missedPickupRepository.findAll();
    }

    public List<MissedPickup> getMissedPickupsByVillage(String village) {
        return missedPickupRepository.findByVillageOrderByReportedAtDesc(village);
    }

    public List<MissedPickup> getMissedPickupsByStatus(MissedPickup.Status status) {
        return missedPickupRepository.findByStatusOrderByReportedAtDesc(status);
    }

    public MissedPickup updateMissedPickupStatus(String id, MissedPickup.Status status, String adminResponse) {
        MissedPickup missedPickup = missedPickupRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Missed pickup report not found"));

        missedPickup.setStatus(status);

        if (adminResponse != null && !adminResponse.trim().isEmpty()) {
            missedPickup.setAdminResponse(adminResponse);
        }

        if (status == MissedPickup.Status.RESOLVED) {
            missedPickup.setResolvedAt(LocalDateTime.now());
        }

        return missedPickupRepository.save(missedPickup);
    }

    public long getMissedPickupCountByStatus(MissedPickup.Status status) {
        if (status == null) {
            return missedPickupRepository.count();
        }
        return missedPickupRepository.countByStatus(status);
    }
}
