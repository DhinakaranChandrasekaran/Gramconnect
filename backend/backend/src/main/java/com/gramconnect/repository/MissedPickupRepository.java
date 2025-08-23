package com.gramconnect.repository;

import com.gramconnect.model.MissedPickup;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MissedPickupRepository extends MongoRepository<MissedPickup, String> {
    List<MissedPickup> findByUserId(String userId);
    List<MissedPickup> findByStatus(MissedPickup.Status status);
    List<MissedPickup> findByVillage(String village);
}