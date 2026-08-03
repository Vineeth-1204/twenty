package com.urlshortener.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "click_analytics", indexes = {
    @Index(name = "idx_analytics_short_code", columnList = "shortCode")
})
public class ClickAnalytics {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 64)
    private String shortCode;

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @Column(length = 512)
    private String referer;

    @Column(length = 512)
    private String userAgent;

    @Column(length = 128)
    private String ipAddress;

    @Column(length = 64)
    private String browser;

    @Column(length = 64)
    private String operatingSystem;

    public ClickAnalytics() {
    }

    public ClickAnalytics(String shortCode, LocalDateTime timestamp, String referer, String userAgent, String ipAddress) {
        this.shortCode = shortCode;
        this.timestamp = timestamp;
        this.referer = referer != null ? referer : "Direct / Bookmark";
        this.userAgent = userAgent != null ? userAgent : "Unknown";
        this.ipAddress = ipAddress != null ? ipAddress : "127.0.0.1";
        this.browser = parseBrowser(this.userAgent);
        this.operatingSystem = parseOS(this.userAgent);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getShortCode() {
        return shortCode;
    }

    public void setShortCode(String shortCode) {
        this.shortCode = shortCode;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public String getReferer() {
        return referer;
    }

    public void setReferer(String referer) {
        this.referer = referer;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getBrowser() {
        return browser;
    }

    public void setBrowser(String browser) {
        this.browser = browser;
    }

    public String getOperatingSystem() {
        return operatingSystem;
    }

    public void setOperatingSystem(String operatingSystem) {
        this.operatingSystem = operatingSystem;
    }

    private String parseBrowser(String ua) {
        if (ua == null) return "Unknown";
        String lower = ua.toLowerCase();
        if (lower.contains("edg/") || lower.contains("edge")) return "Microsoft Edge";
        if (lower.contains("chrome")) return "Google Chrome";
        if (lower.contains("firefox")) return "Mozilla Firefox";
        if (lower.contains("safari") && !lower.contains("chrome")) return "Apple Safari";
        if (lower.contains("postman")) return "Postman";
        if (lower.contains("curl")) return "cURL";
        return "Other Browser";
    }

    private String parseOS(String ua) {
        if (ua == null) return "Unknown";
        String lower = ua.toLowerCase();
        if (lower.contains("windows")) return "Windows";
        if (lower.contains("mac os") || lower.contains("macintosh")) return "macOS";
        if (lower.contains("linux")) return "Linux";
        if (lower.contains("android")) return "Android";
        if (lower.contains("iphone") || lower.contains("ipad")) return "iOS";
        return "Other OS";
    }
}
