package com.gramconnect.repository;

import com.gramconnect.model.GarbageSchedule;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GarbageScheduleRepository extends MongoRepository<GarbageSchedule, String> {
    List<GarbageSchedule> findByDistrictAndPanchayatAndVillage(String district, String panchayat, String village);
    List<GarbageSchedule> findByDistrictAndPanchayatAndVillageAndWard(String district, String panchayat, String village, String ward);
    List<GarbageSchedule> findByCreatedByAdminId(String adminId);
}