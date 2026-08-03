package com.urlshortener.controller;

import com.urlshortener.dto.*;
import com.urlshortener.service.UrlShortenerService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/urls")
@CrossOrigin(origins = "*")
public class UrlApiController {

    private final UrlShortenerService urlShortenerService;

    public UrlApiController(UrlShortenerService urlShortenerService) {
        this.urlShortenerService = urlShortenerService;
    }

    @PostMapping("/shorten")
    public ResponseEntity<ShortenResponse> shortenUrl(@Valid @RequestBody ShortenRequest request, HttpServletRequest servletRequest) {
        String baseUrl = getBaseUrl(servletRequest);
        ShortenResponse response = urlShortenerService.shortenUrl(request, baseUrl);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<ShortenResponse>> getAllUrls(
            @RequestParam(value = "query", required = false) String query,
            HttpServletRequest servletRequest) {
        String baseUrl = getBaseUrl(servletRequest);
        List<ShortenResponse> urls = urlShortenerService.getAllUrls(query, baseUrl);
        return ResponseEntity.ok(urls);
    }

    @GetMapping("/stats/overview")
    public ResponseEntity<DashboardOverviewResponse> getDashboardOverview() {
        DashboardOverviewResponse overview = urlShortenerService.getDashboardOverview();
        return ResponseEntity.ok(overview);
    }

    @GetMapping("/{shortCode}/stats")
    public ResponseEntity<UrlStatsResponse> getUrlStats(@PathVariable("shortCode") String shortCode, HttpServletRequest servletRequest) {
        String baseUrl = getBaseUrl(servletRequest);
        UrlStatsResponse stats = urlShortenerService.getUrlStats(shortCode, baseUrl);
        return ResponseEntity.ok(stats);
    }

    @GetMapping(value = "/{shortCode}/qr", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<byte[]> getQrCodeImage(
            @PathVariable("shortCode") String shortCode,
            @RequestParam(value = "size", defaultValue = "300") int size,
            HttpServletRequest servletRequest) {
        String baseUrl = getBaseUrl(servletRequest);
        byte[] qrBytes = urlShortenerService.getQrCodePng(shortCode, baseUrl, size, size);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + shortCode + "-qr.png\"")
                .body(qrBytes);
    }

    @DeleteMapping("/{shortCode}")
    public ResponseEntity<Void> deleteUrl(@PathVariable("shortCode") String shortCode) {
        urlShortenerService.deleteUrl(shortCode);
        return ResponseEntity.noContent().build();
    }

    private String getBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        StringBuilder sb = new StringBuilder();
        sb.append(scheme).append("://").append(serverName);
        if (("http".equals(scheme) && serverPort != 80) || ("https".equals(scheme) && serverPort != 443)) {
            sb.append(":").append(serverPort);
        }
        sb.append(contextPath);
        return sb.toString();
    }
}
