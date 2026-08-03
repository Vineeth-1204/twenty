package com.urlshortener.dto;

import com.urlshortener.model.ClickAnalytics;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class UrlStatsResponse {

    private String shortCode;
    private String shortUrl;
    private String originalUrl;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private long totalClicks;
    private LocalDateTime lastClickedAt;
    private boolean active;
    private Map<String, Long> refererBreakdown;
    private Map<String, Long> browserBreakdown;
    private Map<String, Long> osBreakdown;
    private List<ClickAnalytics> recentClicks;

    public UrlStatsResponse() {
    }

    public String getShortCode() {
        return shortCode;
    }

    public void setShortCode(String shortCode) {
        this.shortCode = shortCode;
    }

    public String getShortUrl() {
        return shortUrl;
    }

    public void setShortUrl(String shortUrl) {
        this.shortUrl = shortUrl;
    }

    public String getOriginalUrl() {
        return originalUrl;
    }

    public void setOriginalUrl(String originalUrl) {
        this.originalUrl = originalUrl;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public long getTotalClicks() {
        return totalClicks;
    }

    public void setTotalClicks(long totalClicks) {
        this.totalClicks = totalClicks;
    }

    public LocalDateTime getLastClickedAt() {
        return lastClickedAt;
    }

    public void setLastClickedAt(LocalDateTime lastClickedAt) {
        this.lastClickedAt = lastClickedAt;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Map<String, Long> getRefererBreakdown() {
        return refererBreakdown;
    }

    public void setRefererBreakdown(Map<String, Long> refererBreakdown) {
        this.refererBreakdown = refererBreakdown;
    }

    public Map<String, Long> getBrowserBreakdown() {
        return browserBreakdown;
    }

    public void setBrowserBreakdown(Map<String, Long> browserBreakdown) {
        this.browserBreakdown = browserBreakdown;
    }

    public Map<String, Long> getOsBreakdown() {
        return osBreakdown;
    }

    public void setOsBreakdown(Map<String, Long> osBreakdown) {
        this.osBreakdown = osBreakdown;
    }

    public List<ClickAnalytics> getRecentClicks() {
        return recentClicks;
    }

    public void setRecentClicks(List<ClickAnalytics> recentClicks) {
        this.recentClicks = recentClicks;
    }
}
