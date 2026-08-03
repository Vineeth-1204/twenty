package com.urlshortener.repository;

import com.urlshortener.model.ClickAnalytics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClickAnalyticsRepository extends JpaRepository<ClickAnalytics, Long> {

    List<ClickAnalytics> findByShortCodeOrderByTimestampDesc(String shortCode);

    long countByShortCode(String shortCode);

    @Query("SELECT c.referer AS referer, COUNT(c) AS count FROM ClickAnalytics c WHERE c.shortCode = :shortCode GROUP BY c.referer ORDER BY count DESC")
    List<Object[]> findRefererStatsByShortCode(@Param("shortCode") String shortCode);

    @Query("SELECT c.browser AS browser, COUNT(c) AS count FROM ClickAnalytics c WHERE c.shortCode = :shortCode GROUP BY c.browser ORDER BY count DESC")
    List<Object[]> findBrowserStatsByShortCode(@Param("shortCode") String shortCode);

    @Query("SELECT c.operatingSystem AS os, COUNT(c) AS count FROM ClickAnalytics c WHERE c.shortCode = :shortCode GROUP BY c.operatingSystem ORDER BY count DESC")
    List<Object[]> findOsStatsByShortCode(@Param("shortCode") String shortCode);
}
