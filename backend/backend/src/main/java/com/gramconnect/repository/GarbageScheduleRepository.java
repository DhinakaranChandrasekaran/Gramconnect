package com.gramconnect.repository;

import com.gramconnect.model.GarbageSchedule;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GarbageScheduleRepository extends MongoRepository<GarbageSchedule, String> {

    // For Flutter frontend - search by panchayat (village)
    List<GarbageSchedule> findByPanchayatAndIsActiveTrue(String panchayat);
    
    // For Flutter frontend - search by panchayat and ward
    List<GarbageSchedule> findByPanchayatAndWardAndIsActiveTrue(String panchayat, String ward);

    // Legacy methods for backward compatibility
    List<GarbageSchedule> findByDistrictAndPanchayatAndIsActiveTrue(String district, String panchayat);
    List<GarbageSchedule> findByDistrictAndPanchayatAndWardAndIsActiveTrue(String district, String panchayat, String ward);

    // Optional - useful for existence check or update
    Optional<GarbageSchedule> findByDistrictAndPanchayatAndWard(String district, String panchayat, String ward);
    Optional<GarbageSchedule> findByPanchayatAndWard(String panchayat, String ward);
}