package com.gramconnect.repository;

import com.gramconnect.model.OtpLog;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface OtpLogRepository extends MongoRepository<OtpLog, String> {
    Optional<OtpLog> findByIdentifierAndTypeOrderByCreatedAtDesc(String identifier, OtpLog.Type type);
    Optional<OtpLog> findFirstByIdentifierAndTypeAndExpiresAtAfterOrderByCreatedAtDesc(
            String identifier, OtpLog.Type type, LocalDateTime now);
    void deleteByExpiresAtBefore(LocalDateTime now);
}