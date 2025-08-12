package com.gramconnect.repository;

import com.gramconnect.model.MissedPickup;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MissedPickupRepository extends MongoRepository<MissedPickup, String> {
    List<MissedPickup> findByUserIdOrderByReportedAtDesc(String userId);
    List<MissedPickup> findByVillageOrderByReportedAtDesc(String village);
    List<MissedPickup> findByStatusOrderByReportedAtDesc(MissedPickup.Status status);
    long countByStatus(MissedPickup.Status status);
}