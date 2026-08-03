package com.urlshortener;

import com.urlshortener.dto.ShortenRequest;
import com.urlshortener.dto.ShortenResponse;
import com.urlshortener.dto.UrlStatsResponse;
import com.urlshortener.exception.AliasAlreadyExistsException;
import com.urlshortener.exception.InvalidUrlException;
import com.urlshortener.exception.UrlExpiredException;
import com.urlshortener.exception.UrlNotFoundException;
import com.urlshortener.service.UrlShortenerService;
import com.urlshortener.util.Base62Encoder;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.DirtiesContext;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.BEFORE_EACH_TEST_METHOD)
class UrlShortenerApplicationTests {

    @Autowired
    private UrlShortenerService urlShortenerService;

    @Test
    void contextLoads() {
        assertNotNull(urlShortenerService);
    }

    @Test
    @DisplayName("Base62Encoder should generate valid characters")
    void testBase62Encoder() {
        String code = Base62Encoder.generateRandomCode(6);
        assertEquals(6, code.length());
        assertTrue(code.matches("^[0-9a-zA-Z]+$"));
    }

    @Test
    @DisplayName("Should successfully shorten a valid URL")
    void testShortenValidUrl() {
        ShortenRequest request = new ShortenRequest("https://github.com/vineethp/20-projects-20-days", null, null);
        ShortenResponse response = urlShortenerService.shortenUrl(request, "http://localhost:8080");

        assertNotNull(response);
        assertNotNull(response.getShortCode());
        assertEquals("https://github.com/vineethp/20-projects-20-days", response.getOriginalUrl());
        assertEquals("http://localhost:8080/" + response.getShortCode(), response.getShortUrl());
        assertNotNull(response.getQrCodeBase64());
        assertTrue(response.isActive());
    }

    @Test
    @DisplayName("Should shorten URL with custom alias")
    void testShortenWithCustomAlias() {
        ShortenRequest request = new ShortenRequest("https://youtube.com/watch?v=dQw4w9WgXcQ", "rickroll", null);
        ShortenResponse response = urlShortenerService.shortenUrl(request, "http://localhost:8080");

        assertEquals("rickroll", response.getShortCode());
        assertEquals("http://localhost:8080/rickroll", response.getShortUrl());
    }

    @Test
    @DisplayName("Should throw AliasAlreadyExistsException for duplicate custom alias")
    void testDuplicateCustomAlias() {
        ShortenRequest req1 = new ShortenRequest("https://google.com", "myalias", null);
        urlShortenerService.shortenUrl(req1, "http://localhost:8080");

        ShortenRequest req2 = new ShortenRequest("https://bing.com", "myalias", null);
        assertThrows(AliasAlreadyExistsException.class, () -> urlShortenerService.shortenUrl(req2, "http://localhost:8080"));
    }

    @Test
    @DisplayName("Should throw InvalidUrlException for malformed URLs")
    void testInvalidUrlRejection() {
        ShortenRequest req1 = new ShortenRequest("invalid_url_without_domain", null, null);
        assertThrows(InvalidUrlException.class, () -> urlShortenerService.shortenUrl(req1, "http://localhost:8080"));
    }

    @Test
    @DisplayName("Should normalize URLs missing scheme prefix")
    void testUrlNormalization() {
        ShortenRequest req = new ShortenRequest("google.com", null, null);
        ShortenResponse res = urlShortenerService.shortenUrl(req, "http://localhost:8080");
        assertEquals("https://google.com", res.getOriginalUrl());
    }

    @Test
    @DisplayName("Should resolve original URL and log click stats")
    void testRedirectAndClickLogging() {
        ShortenRequest request = new ShortenRequest("https://spring.io", "springio", null);
        urlShortenerService.shortenUrl(request, "http://localhost:8080");

        String original = urlShortenerService.getOriginalUrlAndLogClick("springio", "https://google.com", "Mozilla/5.0 Chrome", "127.0.0.1");
        assertEquals("https://spring.io", original);

        UrlStatsResponse stats = urlShortenerService.getUrlStats("springio", "http://localhost:8080");
        assertEquals(1, stats.getTotalClicks());
        assertTrue(stats.getRefererBreakdown().containsKey("https://google.com"));
        assertTrue(stats.getBrowserBreakdown().containsKey("Google Chrome"));
    }

    @Test
    @DisplayName("Should throw UrlNotFoundException for non-existent short code")
    void testNotFoundCode() {
        assertThrows(UrlNotFoundException.class, () -> urlShortenerService.getOriginalUrlAndLogClick("nonexistent99", null, null, null));
    }
}
