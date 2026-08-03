package com.urlshortener.repository;

import com.urlshortener.model.UrlMapping;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UrlMappingRepository extends JpaRepository<UrlMapping, Long> {

    Optional<UrlMapping> findByShortCode(String shortCode);

    boolean existsByShortCode(String shortCode);

    List<UrlMapping> findAllByOrderByCreatedAtDesc();

    @Query("SELECT u FROM UrlMapping u WHERE LOWER(u.shortCode) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(u.originalUrl) LIKE LOWER(CONCAT('%', :query, '%')) ORDER BY u.createdAt DESC")
    List<UrlMapping> searchUrls(@Param("query") String query);

    @Query("SELECT COUNT(u) FROM UrlMapping u WHERE u.active = true AND (u.expiresAt IS NULL OR u.expiresAt > CURRENT_TIMESTAMP)")
    long countActiveUrls();

    @Query("SELECT COUNT(u) FROM UrlMapping u WHERE u.expiresAt IS NOT NULL AND u.expiresAt <= CURRENT_TIMESTAMP")
    long countExpiredUrls();

    @Query("SELECT COALESCE(SUM(u.clickCount), 0) FROM UrlMapping u")
    long sumTotalClicks();
}
