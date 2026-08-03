document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide icons
    if (window.lucide) {
        lucide.createIcons();
    }

    const domainPrefix = document.getElementById('domain-prefix');
    if (domainPrefix) {
        domainPrefix.textContent = window.location.host + '/';
    }

    // Elements
    const shortenForm = document.getElementById('shorten-form');
    const longUrlInput = document.getElementById('longUrl');
    const customAliasInput = document.getElementById('customAlias');
    const expirationDaysSelect = document.getElementById('expirationDays');
    const shortenBtn = document.getElementById('shorten-btn');
    const toggleOptionsBtn = document.getElementById('toggle-options-btn');
    const advancedOptions = document.getElementById('advanced-options');

    const resultBox = document.getElementById('result-box');
    const shortUrlOutput = document.getElementById('shortUrlOutput');
    const copyResultBtn = document.getElementById('copyResultBtn');
    const testRedirectBtn = document.getElementById('testRedirectBtn');
    const viewQrResultBtn = document.getElementById('viewQrResultBtn');
    const originalUrlPreview = document.getElementById('originalUrlPreview');
    const expirationMeta = document.getElementById('expirationMeta');

    const refreshDashboardBtn = document.getElementById('refresh-dashboard-btn');
    const searchInput = document.getElementById('search-input');
    const linksTableBody = document.getElementById('links-table-body');
    const tableEmptyState = document.getElementById('table-empty-state');

    const statTotalLinks = document.getElementById('stat-total-links');
    const statTotalClicks = document.getElementById('stat-total-clicks');
    const statActiveLinks = document.getElementById('stat-active-links');
    const statExpiredLinks = document.getElementById('stat-expired-links');

    // Modals
    const analyticsModal = document.getElementById('analytics-modal');
    const qrModal = document.getElementById('qr-modal');

    let currentCreatedShortCode = null;

    // Toggle Advanced Options
    toggleOptionsBtn.addEventListener('click', () => {
        advancedOptions.classList.toggle('hidden');
        toggleOptionsBtn.classList.toggle('active');
    });

    // Form Submit Handler
    shortenForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const originalUrl = longUrlInput.value.trim();
        const customAlias = customAliasInput.value.trim() || null;
        const expirationDays = expirationDaysSelect.value ? parseInt(expirationDaysSelect.value) : null;

        if (!originalUrl) {
            showToast('Please enter a valid URL', 'error');
            return;
        }

        setLoading(true);

        try {
            const response = await fetch('/api/urls/shorten', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    originalUrl: originalUrl,
                    customAlias: customAlias,
                    expirationDays: expirationDays
                })
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.message || 'Failed to shorten URL');
            }

            currentCreatedShortCode = data.shortCode;
            displayResult(data);
            showToast('Short URL created successfully!', 'success');
            loadDashboard();
            loadLinks();
        } catch (err) {
            showToast(err.message, 'error');
        } finally {
            setLoading(false);
        }
    });

    function setLoading(isLoading) {
        const btnText = shortenBtn.querySelector('.btn-text');
        const btnIcon = shortenBtn.querySelector('.btn-icon');
        const btnSpinner = shortenBtn.querySelector('.btn-spinner');

        if (isLoading) {
            shortenBtn.disabled = true;
            btnText.textContent = 'Creating...';
            btnIcon.classList.add('hidden');
            btnSpinner.classList.remove('hidden');
        } else {
            shortenBtn.disabled = false;
            btnText.textContent = 'Generate Link';
            btnIcon.classList.remove('hidden');
            btnSpinner.classList.add('hidden');
        }
    }

    function displayResult(data) {
        shortUrlOutput.value = data.shortUrl;
        testRedirectBtn.href = data.shortUrl;
        originalUrlPreview.textContent = data.originalUrl;

        if (data.expiresAt) {
            const expDate = new Date(data.expiresAt);
            expirationMeta.innerHTML = `<i data-lucide="calendar"></i> Expires: ${expDate.toLocaleDateString()} ${expDate.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}`;
        } else {
            expirationMeta.innerHTML = `<i data-lucide="calendar"></i> Expires: Never`;
        }

        resultBox.classList.remove('hidden');
        if (window.lucide) lucide.createIcons();
    }

    // Copy Result Link
    copyResultBtn.addEventListener('click', () => {
        copyToClipboard(shortUrlOutput.value, 'Short URL copied to clipboard!');
    });

    // View QR for result
    viewQrResultBtn.addEventListener('click', () => {
        if (currentCreatedShortCode) {
            openQrModal(currentCreatedShortCode, shortUrlOutput.value);
        }
    });

    // Load Dashboard Statistics
    async function loadDashboard() {
        try {
            const res = await fetch('/api/urls/stats/overview');
            if (res.ok) {
                const data = await res.json();
                statTotalLinks.textContent = data.totalLinks;
                statTotalClicks.textContent = data.totalClicks;
                statActiveLinks.textContent = data.activeLinks;
                statExpiredLinks.textContent = data.expiredLinks;
            }
        } catch (e) {
            console.error('Failed to load dashboard stats', e);
        }
    }

    refreshDashboardBtn.addEventListener('click', () => {
        loadDashboard();
        loadLinks();
        showToast('Dashboard refreshed', 'success');
    });

    // Load Links List
    async function loadLinks(query = '') {
        try {
            const url = query ? `/api/urls?query=${encodeURIComponent(query)}` : '/api/urls';
            const res = await fetch(url);
            if (!res.ok) return;

            const links = await res.json();
            renderLinksTable(links);
        } catch (e) {
            console.error('Failed to fetch links', e);
        }
    }

    let searchTimeout = null;
    searchInput.addEventListener('input', () => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            loadLinks(searchInput.value.trim());
        }, 300);
    });

    function renderLinksTable(links) {
        linksTableBody.innerHTML = '';

        if (!links || links.length === 0) {
            tableEmptyState.classList.remove('hidden');
            return;
        }

        tableEmptyState.classList.add('hidden');

        links.forEach(link => {
            const tr = document.createElement('tr');

            const createdDate = new Date(link.createdAt).toLocaleDateString();
            const expDateStr = link.expiresAt ? new Date(link.expiresAt).toLocaleDateString() : 'Never';
            const statusBadge = link.active
                ? `<span class="badge badge-success">Active</span>`
                : `<span class="badge badge-expired">Expired</span>`;

            tr.innerHTML = `
                <td>
                    <a href="${link.shortUrl}" target="_blank" class="short-url-link">${link.shortUrl}</a>
                    ${link.customAlias ? `<br><small style="color: var(--text-muted);">Alias: ${link.customAlias}</small>` : ''}
                </td>
                <td class="orig-url-cell">
                    <span class="truncate" title="${escapeHtml(link.originalUrl)}">${escapeHtml(link.originalUrl)}</span>
                </td>
                <td><strong>${link.clickCount}</strong></td>
                <td>${createdDate}</td>
                <td>${expDateStr} ${statusBadge}</td>
                <td class="text-right">
                    <div class="action-btns">
                        <button class="btn btn-sm btn-secondary copy-btn" data-url="${link.shortUrl}" title="Copy Link"><i data-lucide="copy"></i></button>
                        <button class="btn btn-sm btn-outline qr-btn" data-code="${link.shortCode}" data-url="${link.shortUrl}" title="QR Code"><i data-lucide="qr-code"></i></button>
                        <button class="btn btn-sm btn-primary stats-btn" data-code="${link.shortCode}" title="Analytics"><i data-lucide="bar-chart-2"></i></button>
                        <button class="btn btn-sm btn-icon-only delete-btn" data-code="${link.shortCode}" title="Delete" style="color: var(--rose);"><i data-lucide="trash-2"></i></button>
                    </div>
                </td>
            `;

            linksTableBody.appendChild(tr);
        });

        if (window.lucide) lucide.createIcons();
        attachTableEvents();
    }

    function attachTableEvents() {
        document.querySelectorAll('.copy-btn').forEach(btn => {
            btn.addEventListener('click', () => copyToClipboard(btn.dataset.url, 'Link copied!'));
        });

        document.querySelectorAll('.qr-btn').forEach(btn => {
            btn.addEventListener('click', () => openQrModal(btn.dataset.code, btn.dataset.url));
        });

        document.querySelectorAll('.stats-btn').forEach(btn => {
            btn.addEventListener('click', () => openAnalyticsModal(btn.dataset.code));
        });

        document.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', () => deleteLink(btn.dataset.code));
        });
    }

    // Modal Close buttons
    document.querySelectorAll('[data-close-modal]').forEach(btn => {
        btn.addEventListener('click', () => {
            const modalId = btn.dataset.closeModal;
            document.getElementById(modalId).classList.add('hidden');
        });
    });

    // Close modal on backdrop click
    [analyticsModal, qrModal].forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.classList.add('hidden');
            }
        });
    });

    // QR Code Modal
    function openQrModal(shortCode, shortUrl) {
        const modalQrImage = document.getElementById('modal-qr-image');
        const modalQrUrl = document.getElementById('modal-qr-url');
        const downloadQrBtn = document.getElementById('download-qr-btn');

        const qrApiUrl = `/api/urls/${shortCode}/qr?size=300`;
        modalQrImage.src = qrApiUrl;
        modalQrUrl.textContent = shortUrl;
        downloadQrBtn.href = qrApiUrl;

        qrModal.classList.remove('hidden');
        if (window.lucide) lucide.createIcons();
    }

    // Analytics Modal
    async function openAnalyticsModal(shortCode) {
        try {
            const res = await fetch(`/api/urls/${shortCode}/stats`);
            if (!res.ok) throw new Error('Failed to load stats');

            const stats = await res.json();
            document.getElementById('modal-short-code').textContent = '/' + stats.shortCode;
            document.getElementById('modal-clicks').textContent = stats.totalClicks;
            
            const origLink = document.getElementById('modal-original-url');
            origLink.href = stats.originalUrl;
            origLink.textContent = stats.originalUrl;

            const lastClicked = document.getElementById('modal-last-clicked');
            if (stats.lastClickedAt) {
                const lcDate = new Date(stats.lastClickedAt);
                lastClicked.textContent = `${lcDate.toLocaleDateString()} ${lcDate.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'})}`;
            } else {
                lastClicked.textContent = 'Never clicked yet';
            }

            // Render Referer breakdown
            const refererList = document.getElementById('referers-breakdown');
            refererList.innerHTML = renderBreakdown(stats.refererBreakdown, stats.totalClicks);

            // Render Browser & OS breakdown
            const browserList = document.getElementById('browsers-breakdown');
            browserList.innerHTML = renderBreakdown(stats.browserBreakdown, stats.totalClicks);

            // Render Click Audit Log
            const clicksLogBody = document.getElementById('clicks-log-body');
            clicksLogBody.innerHTML = '';
            if (stats.recentClicks && stats.recentClicks.length > 0) {
                stats.recentClicks.forEach(c => {
                    const row = document.createElement('tr');
                    const ts = new Date(c.timestamp).toLocaleString();
                    row.innerHTML = `
                        <td>${ts}</td>
                        <td class="truncate" style="max-width: 140px;">${escapeHtml(c.referer || 'Direct')}</td>
                        <td>${escapeHtml(c.browser || 'Unknown')}</td>
                        <td>${escapeHtml(c.operatingSystem || 'Unknown')}</td>
                        <td>${escapeHtml(c.ipAddress || '127.0.0.1')}</td>
                    `;
                    clicksLogBody.appendChild(row);
                });
            } else {
                clicksLogBody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: var(--text-muted);">No clicks recorded yet</td></tr>`;
            }

            analyticsModal.classList.remove('hidden');
            if (window.lucide) lucide.createIcons();
        } catch (e) {
            showToast('Could not load link analytics', 'error');
        }
    }

    function renderBreakdown(map, total) {
        if (!map || Object.keys(map).length === 0) {
            return `<div style="color: var(--text-muted); font-size: 0.85rem;">No data available</div>`;
        }
        return Object.entries(map).map(([key, count]) => {
            const percent = total > 0 ? Math.round((count / total) * 100) : 0;
            return `
                <div class="breakdown-row-wrapper">
                    <div class="breakdown-row">
                        <span>${escapeHtml(key)}</span>
                        <strong>${count} (${percent}%)</strong>
                    </div>
                    <div class="breakdown-bar-bg" style="width: ${percent}%;"></div>
                </div>
            `;
        }).join('');
    }

    // Delete Link
    async function deleteLink(shortCode) {
        if (!confirm(`Are you sure you want to delete short link '/${shortCode}'?`)) return;

        try {
            const res = await fetch(`/api/urls/${shortCode}`, { method: 'DELETE' });
            if (res.ok) {
                showToast(`Short link '/${shortCode}' deleted`, 'success');
                loadDashboard();
                loadLinks();
            } else {
                showToast('Failed to delete link', 'error');
            }
        } catch (e) {
            showToast('Error deleting link', 'error');
        }
    }

    // Helper functions
    function copyToClipboard(text, msg) {
        navigator.clipboard.writeText(text).then(() => {
            showToast(msg, 'success');
        }).catch(() => {
            showToast('Failed to copy to clipboard', 'error');
        });
    }

    function showToast(message, type = 'success') {
        const container = document.getElementById('toast-container');
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        const icon = type === 'success' ? 'check-circle' : 'alert-circle';
        toast.innerHTML = `<i data-lucide="${icon}"></i> <span>${escapeHtml(message)}</span>`;
        container.appendChild(toast);
        if (window.lucide) lucide.createIcons();

        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(10px)';
            toast.style.transition = 'all 0.3s ease';
            setTimeout(() => toast.remove(), 300);
        }, 3500);
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, "&amp;")
                  .replace(/</g, "&lt;")
                  .replace(/>/g, "&gt;")
                  .replace(/"/g, "&quot;")
                  .replace(/'/g, "&#039;");
    }

    // Initial load
    loadDashboard();
    loadLinks();
});
