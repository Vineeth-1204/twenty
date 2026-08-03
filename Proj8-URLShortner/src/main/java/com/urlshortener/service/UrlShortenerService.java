package com.urlshortener.service;

import com.urlshortener.dto.*;
import com.urlshortener.exception.*;
import com.urlshortener.model.ClickAnalytics;
import com.urlshortener.model.UrlMapping;
import com.urlshortener.repository.ClickAnalyticsRepository;
import com.urlshortener.repository.UrlMappingRepository;
import com.urlshortener.util.Base62Encoder;
import com.urlshortener.util.QrCodeGenerator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.net.URI;
import java.net.URISyntaxException;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class UrlShortenerService {

    private final UrlMappingRepository urlMappingRepository;
    private final ClickAnalyticsRepository clickAnalyticsRepository;

    @Value("${app.default-code-length:6}")
    private int defaultCodeLength;

    public UrlShortenerService(UrlMappingRepository urlMappingRepository, ClickAnalyticsRepository clickAnalyticsRepository) {
        this.urlMappingRepository = urlMappingRepository;
        this.clickAnalyticsRepository = clickAnalyticsRepository;
    }

    @Transactional
    public ShortenResponse shortenUrl(ShortenRequest request, String baseUrl) {
        String originalUrl = request.getOriginalUrl().trim();
        originalUrl = normalizeAndValidateUrl(originalUrl);

        String shortCode;
        String customAlias = request.getCustomAlias();

        if (customAlias != null && !customAlias.trim().isEmpty()) {
            customAlias = customAlias.trim();
            if (urlMappingRepository.existsByShortCode(customAlias)) {
                throw new AliasAlreadyExistsException("Custom alias '" + customAlias + "' is already in use. Please choose another one.");
            }
            shortCode = customAlias;
        } else {
            customAlias = null;
            shortCode = generateUniqueShortCode();
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = null;
        if (request.getExpirationDays() != null && request.getExpirationDays() > 0) {
            expiresAt = now.plusDays(request.getExpirationDays());
        }

        UrlMapping mapping = new UrlMapping(shortCode, originalUrl, customAlias, now, expiresAt);
        mapping = urlMappingRepository.save(mapping);

        String fullShortUrl = buildFullShortUrl(baseUrl, shortCode);
        String qrCodeBase64 = QrCodeGenerator.generateQrCodeBase64(fullShortUrl, 250, 250);

        return mapToResponse(mapping, fullShortUrl, qrCodeBase64);
    }

    @Transactional
    public String getOriginalUrlAndLogClick(String shortCode, String referer, String userAgent, String ipAddress) {
        UrlMapping mapping = urlMappingRepository.findByShortCode(shortCode)
                .orElseThrow(() -> new UrlNotFoundException("Short URL '/" + shortCode + "' not found."));

        if (!mapping.isActive()) {
            throw new UrlNotFoundException("Short URL '/" + shortCode + "' is inactive.");
        }

        if (mapping.isExpired()) {
            throw new UrlExpiredException("Short URL '/" + shortCode + "' has expired.");
        }

        // Increment click stats
        mapping.incrementClickCount();
        urlMappingRepository.save(mapping);

        // Record granular analytics
        ClickAnalytics click = new ClickAnalytics(shortCode, LocalDateTime.now(), referer, userAgent, ipAddress);
        clickAnalyticsRepository.save(click);

        return mapping.getOriginalUrl();
    }

    @Transactional(readOnly = true)
    public UrlStatsResponse getUrlStats(String shortCode, String baseUrl) {
        UrlMapping mapping = urlMappingRepository.findByShortCode(shortCode)
                .orElseThrow(() -> new UrlNotFoundException("Short URL '/" + shortCode + "' not found."));

        UrlStatsResponse stats = new UrlStatsResponse();
        stats.setShortCode(mapping.getShortCode());
        stats.setShortUrl(buildFullShortUrl(baseUrl, mapping.getShortCode()));
        stats.setOriginalUrl(mapping.getOriginalUrl());
        stats.setCreatedAt(mapping.getCreatedAt());
        stats.setExpiresAt(mapping.getExpiresAt());
        stats.setTotalClicks(mapping.getClickCount());
        stats.setLastClickedAt(mapping.getLastClickedAt());
        stats.setActive(mapping.isActive());

        // Aggregate referers
        List<Object[]> refererData = clickAnalyticsRepository.findRefererStatsByShortCode(shortCode);
        Map<String, Long> refererMap = new LinkedHashMap<>();
        for (Object[] row : refererData) {
            refererMap.put((String) row[0], (Long) row[1]);
        }
        stats.setRefererBreakdown(refererMap);

        // Aggregate browsers
        List<Object[]> browserData = clickAnalyticsRepository.findBrowserStatsByShortCode(shortCode);
        Map<String, Long> browserMap = new LinkedHashMap<>();
        for (Object[] row : browserData) {
            browserMap.put((String) row[0], (Long) row[1]);
        }
        stats.setBrowserBreakdown(browserMap);

        // Aggregate OS
        List<Object[]> osData = clickAnalyticsRepository.findOsStatsByShortCode(shortCode);
        Map<String, Long> osMap = new LinkedHashMap<>();
        for (Object[] row : osData) {
            osMap.put((String) row[0], (Long) row[1]);
        }
        stats.setOsBreakdown(osMap);

        // Recent clicks
        List<ClickAnalytics> recentClicks = clickAnalyticsRepository.findByShortCodeOrderByTimestampDesc(shortCode);
        if (recentClicks.size() > 20) {
            recentClicks = recentClicks.subList(0, 20);
        }
        stats.setRecentClicks(recentClicks);

        return stats;
    }

    @Transactional(readOnly = true)
    public List<ShortenResponse> getAllUrls(String query, String baseUrl) {
        List<UrlMapping> mappings;
        if (query != null && !query.trim().isEmpty()) {
            mappings = urlMappingRepository.searchUrls(query.trim());
        } else {
            mappings = urlMappingRepository.findAllByOrderByCreatedAtDesc();
        }

        return mappings.stream().map(mapping -> {
            String fullShortUrl = buildFullShortUrl(baseUrl, mapping.getShortCode());
            String qrBase64 = QrCodeGenerator.generateQrCodeBase64(fullShortUrl, 150, 150);
            return mapToResponse(mapping, fullShortUrl, qrBase64);
        }).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public DashboardOverviewResponse getDashboardOverview() {
        long totalLinks = urlMappingRepository.count();
        long totalClicks = urlMappingRepository.sumTotalClicks();
        long activeLinks = urlMappingRepository.countActiveUrls();
        long expiredLinks = urlMappingRepository.countExpiredUrls();

        return new DashboardOverviewResponse(totalLinks, totalClicks, activeLinks, expiredLinks);
    }

    @Transactional
    public void deleteUrl(String shortCode) {
        UrlMapping mapping = urlMappingRepository.findByShortCode(shortCode)
                .orElseThrow(() -> new UrlNotFoundException("Short URL '/" + shortCode + "' not found."));
        urlMappingRepository.delete(mapping);
    }

    public byte[] getQrCodePng(String shortCode, String baseUrl, int width, int height) {
        UrlMapping mapping = urlMappingRepository.findByShortCode(shortCode)
                .orElseThrow(() -> new UrlNotFoundException("Short URL '/" + shortCode + "' not found."));
        String fullShortUrl = buildFullShortUrl(baseUrl, mapping.getShortCode());
        try {
            return QrCodeGenerator.generateQrCodeImageBytes(fullShortUrl, width, height);
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate PNG QR Code", e);
        }
    }

    private String generateUniqueShortCode() {
        String code;
        int maxAttempts = 10;
        int attempts = 0;
        do {
            code = Base62Encoder.generateRandomCode(defaultCodeLength);
            attempts++;
            if (attempts > maxAttempts) {
                defaultCodeLength++;
            }
        } while (urlMappingRepository.existsByShortCode(code));
        return code;
    }

    private String normalizeAndValidateUrl(String inputUrl) {
        if (inputUrl == null || inputUrl.trim().isEmpty()) {
            throw new InvalidUrlException("URL cannot be empty.");
        }
        String url = inputUrl.trim();
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
            url = "https://" + url;
        }

        try {
            URI uri = new URI(url);
            if (uri.getHost() == null || uri.getHost().isEmpty()) {
                throw new InvalidUrlException("Invalid URL: Hostname is missing. Example: https://google.com");
            }
            if (!uri.getHost().contains(".")) {
                throw new InvalidUrlException("Invalid URL: Must be a valid web domain name. Example: https://github.com");
            }
        } catch (URISyntaxException e) {
            throw new InvalidUrlException("Invalid URL format: " + e.getMessage());
        }

        return url;
    }

    private String buildFullShortUrl(String baseUrl, String shortCode) {
        if (baseUrl.endsWith("/")) {
            return baseUrl + shortCode;
        }
        return baseUrl + "/" + shortCode;
    }

    private ShortenResponse mapToResponse(UrlMapping mapping, String fullShortUrl, String qrCodeBase64) {
        return new ShortenResponse(
                mapping.getShortCode(),
                fullShortUrl,
                mapping.getOriginalUrl(),
                mapping.getCustomAlias(),
                mapping.getCreatedAt(),
                mapping.getExpiresAt(),
                mapping.getClickCount(),
                qrCodeBase64,
                mapping.isActive() && !mapping.isExpired()
        );
    }
}
