package com.gramconnect.repository;

import com.gramconnect.model.Complaint;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComplaintRepository extends MongoRepository<Complaint, String> {
    List<Complaint> findByUserId(String userId);
    List<Complaint> findByStatus(Complaint.Status status);
    List<Complaint> findByDistrictAndPanchayatAndVillage(String district, String panchayat, String village);
    List<Complaint> findByDistrict(String district);
}