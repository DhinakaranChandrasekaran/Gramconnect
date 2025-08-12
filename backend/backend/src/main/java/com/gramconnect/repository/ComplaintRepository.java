package com.gramconnect.repository;

import com.gramconnect.model.Complaint;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ComplaintRepository extends MongoRepository<Complaint, String> {
    List<Complaint> findByUserIdOrderByCreatedAtDesc(String userId);
    List<Complaint> findByStatusOrderByCreatedAtDesc(Complaint.Status status);
    List<Complaint> findByVillageOrderByCreatedAtDesc(String village);
    List<Complaint> findByCategoryOrderByCreatedAtDesc(Complaint.Category category);
    
    @Query("{ 'status': ?0, 'createdAt': { $lt: ?1 } }")
    List<Complaint> findPendingComplaintsOlderThan(Complaint.Status status, LocalDateTime dateTime);
    
    @Query("{ 'status': ?0, 'reminderSent': false, 'createdAt': { $lt: ?1 } }")
    List<Complaint> findComplaintsEligibleForReminder(Complaint.Status status, LocalDateTime dateTime);
    
    long countByStatus(Complaint.Status status);
    long countByCategory(Complaint.Category category);
    long countByVillage(String village);
}