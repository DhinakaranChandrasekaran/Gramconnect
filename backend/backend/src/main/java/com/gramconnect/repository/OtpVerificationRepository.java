package com.gramconnect.repository;

import com.gramconnect.model.OtpVerification;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OtpVerificationRepository extends MongoRepository<OtpVerification, String> {
    Optional<OtpVerification> findByIdentifierAndTypeAndVerifiedFalse(String identifier, OtpVerification.OtpType type);
    void deleteByIdentifierAndType(String identifier, OtpVerification.OtpType type);
    long countByIdentifierAndType(String identifier, OtpVerification.OtpType type);
    void deleteAllByIdentifierAndTypeAndVerifiedFalse(String identifier, OtpVerification.OtpType type);
}