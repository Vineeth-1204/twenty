// ==========================================================================
// WAYNETECH BAT-COMPUTER APPLICATION LOGIC & GAMIFICATION ENGINE
// ==========================================================================

const RANKS = [
    { title: "Vigilante", minPoints: 0 },
    { title: "Caped Crusader", minPoints: 50 },
    { title: "Gotham Defender", minPoints: 150 },
    { title: "Master Detective", minPoints: 300 },
    { title: "Dark Knight", minPoints: 600 }
];

const BADGES = [
    { id: "first_blood", name: "First Arrest", icon: "🦇", desc: "Completed your first mission" },
    { id: "speedy_justice", name: "Speedy Justice", icon: "⚡", desc: "Completed a mission before deadline" },
    { id: "high_threat", name: "Arkham Hunter", icon: "🃏", desc: "Cleared an Alpha-Threat mission" },
    { id: "batarang_hoarder", name: "Batarang Collector", icon: "🎯", desc: "Earned 100+ Batarangs" },
    { id: "detective_master", name: "Master Detective", icon: "🔍", desc: "Completed 5 subtask checklists" },
    { id: "clean_sweep", name: "Gotham Secured", icon: "🛡️", desc: "Cleared all active directives" }
];

const PRESETS = [
    { title: "Patrol Crime Alley for rogue activity", threat: "ALPHA", category: "Gotham Patrol" },
    { title: "Review Arkham Asylum security logs", threat: "BETA", category: "Arkham Cases" },
    { title: "Perform Batmobile engine diagnostic", threat: "GAMMA", category: "Batcave" },
    { title: "Audit Wayne Enterprises quarterly R&D budget", threat: "BETA", category: "Wayne Corp" }
];

class BatComputerApp {
    constructor() {
        this.missions = [];
        this.batarangs = 0;
        this.unlockedBadges = [];
        this.activeFilter = 'all';
        this.searchQuery = '';
        this.soundEnabled = true;

        this.init();
    }

    init() {
        this.loadState();
        this.setupClock();
        this.setupCanvas();
        this.bindEvents();
        this.renderAll();
        
        // Start live deadline checker loop (every 10 seconds)
        setInterval(() => this.checkDeadlines(), 10000);
        this.checkDeadlines();

        // Request browser notification permission if available
        if ("Notification" in window && Notification.permission === "default") {
            Notification.requestPermission();
        }
    }

    loadState() {
        const saved = localStorage.getItem('waynetech_bat_computer_data');
        if (saved) {
            try {
                const data = JSON.parse(saved);
                this.missions = data.missions || [];
                this.batarangs = data.batarangs || 0;
                this.unlockedBadges = data.unlockedBadges || [];
                this.soundEnabled = data.soundEnabled !== undefined ? data.soundEnabled : true;
            } catch (e) {
                console.error('Failed to parse saved state:', e);
                this.loadDefaultMissions();
            }
        } else {
            this.loadDefaultMissions();
        }
        window.batAudio.setMuted(!this.soundEnabled);
    }

    loadDefaultMissions() {
        const now = new Date();
        const future15 = new Date(now.getTime() + 15 * 60000); // 15 mins from now
        const future2h = new Date(now.getTime() + 2 * 3600000); // 2 hours from now

        this.missions = [
            {
                id: 'm1',
                title: 'Intercept Joker Jammer in Industrial District',
                threat: 'ALPHA',
                category: 'Arkham Cases',
                deadline: future15.toISOString().slice(0, 16),
                bounty: 30,
                subtasks: [
                    { id: 's1', title: 'Trace frequency signal using Bat-Scanner', completed: true },
                    { id: 's2', title: 'Disable jammer power node', completed: false },
                    { id: 's3', title: 'Apprehend henchmen', completed: false }
                ],
                completed: false,
                createdAt: new Date().toISOString()
            },
            {
                id: 'm2',
                title: 'Wayne Enterprises Cyber Security Inspection',
                threat: 'BETA',
                category: 'Wayne Corp',
                deadline: future2h.toISOString().slice(0, 16),
                bounty: 20,
                subtasks: [
                    { id: 's4', title: 'Verify satellite encryption protocols', completed: false },
                    { id: 's5', title: 'Patch Batcave mainframe firewall', completed: false }
                ],
                completed: false,
                createdAt: new Date().toISOString()
            }
        ];
        this.batarangs = 35;
        this.unlockedBadges = ['first_blood'];
        this.saveState();
    }

    saveState() {
        const data = {
            missions: this.missions,
            batarangs: this.batarangs,
            unlockedBadges: this.unlockedBadges,
            soundEnabled: this.soundEnabled
        };
        localStorage.setItem('waynetech_bat_computer_data', JSON.stringify(data));
    }

    setupClock() {
        const timeEl = document.getElementById('gothamClockTime');
        const updateClock = () => {
            const now = new Date();
            if (timeEl) {
                timeEl.innerText = now.toLocaleTimeString('en-US', { hour12: false });
            }
        };
        updateClock();
        setInterval(updateClock, 1000);
    }

    setupCanvas() {
        const canvas = document.getElementById('batSignalCanvas');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');

        let width = canvas.width = window.innerWidth;
        let height = canvas.height = window.innerHeight;

        window.addEventListener('resize', () => {
            width = canvas.width = window.innerWidth;
            height = canvas.height = window.innerHeight;
        });

        let angle = 0;
        const render = () => {
            ctx.clearRect(0, 0, width, height);
            
            // Draw glowing Bat-Signal spotlight beam moving smoothly
            angle += 0.005;
            const beamX = width * 0.5 + Math.sin(angle) * (width * 0.25);
            const beamY = height * 0.25 + Math.cos(angle * 0.7) * 40;

            // Light beam gradient
            const grad = ctx.createRadialGradient(beamX, beamY, 10, beamX, beamY, 220);
            grad.addColorStop(0, 'rgba(255, 204, 0, 0.18)');
            grad.addColorStop(0.5, 'rgba(255, 204, 0, 0.05)');
            grad.addColorStop(1, 'rgba(0, 0, 0, 0)');

            ctx.fillStyle = grad;
            ctx.beginPath();
            ctx.arc(beamX, beamY, 220, 0, Math.PI * 2);
            ctx.fill();

            requestAnimationFrame(render);
        };
        render();
    }

    bindEvents() {
        // Form submit
        const form = document.getElementById('missionForm');
        if (form) {
            form.addEventListener('submit', (e) => {
                e.preventDefault();
                this.deployMissionFromForm();
            });
        }

        // Smart suggest button
        const smartBtn = document.getElementById('btnSmartSuggest');
        if (smartBtn) {
            smartBtn.addEventListener('click', () => this.runSmartAssistant());
        }

        // Sound toggle
        const soundBtn = document.getElementById('btnSoundToggle');
        if (soundBtn) {
            soundBtn.addEventListener('click', () => {
                this.soundEnabled = !this.soundEnabled;
                window.batAudio.setMuted(!this.soundEnabled);
                soundBtn.innerHTML = this.soundEnabled ? '🔊' : '🔇';
                this.saveState();
                if (this.soundEnabled) window.batAudio.playClick();
            });
        }

        // Filter tabs
        document.querySelectorAll('.filter-tab').forEach(tab => {
            tab.addEventListener('click', (e) => {
                document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
                e.target.classList.add('active');
                this.activeFilter = e.target.dataset.filter;
                window.batAudio.playClick();
                this.renderMissions();
            });
        });

        // Search box input
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                this.searchQuery = e.target.value.toLowerCase();
                this.renderMissions();
            });
        }

        // Quick presets
        document.querySelectorAll('.preset-pill').forEach(pill => {
            pill.addEventListener('click', () => {
                const idx = parseInt(pill.dataset.presetIdx);
                if (PRESETS[idx]) {
                    document.getElementById('missionTitle').value = PRESETS[idx].title;
                    document.getElementById('threatSelect').value = PRESETS[idx].threat;
                    document.getElementById('categorySelect').value = PRESETS[idx].category;
                    this.runSmartAssistant();
                    window.batAudio.playClick();
                }
            });
        });
    }

    // Bat-Computer Smart Assistant logic
    runSmartAssistant() {
        const titleInput = document.getElementById('missionTitle');
        const text = titleInput.value.trim().toLowerCase();
        if (!text) return;

        let threat = 'BETA';
        let category = 'Batcave';
        let subtasks = [];

        if (text.includes('joker') || text.includes('arkham') || text.includes('breach') || text.includes('bomb') || text.includes('urgent')) {
            threat = 'ALPHA';
            category = 'Arkham Cases';
        } else if (text.includes('patrol') || text.includes('alley') || text.includes('crime')) {
            threat = 'BETA';
            category = 'Gotham Patrol';
        } else if (text.includes('wayne') || text.includes('audit') || text.includes('budget') || text.includes('meeting')) {
            threat = 'BETA';
            category = 'Wayne Corp';
        }

        // Generate smart subtasks
        if (text.includes('investigate') || text.includes('search')) {
            subtasks = ['Analyze evidence with Bat-Computer', 'Interview witnesses', 'Secure perimeter'];
        } else if (text.includes('patrol') || text.includes('alley')) {
            subtasks = ['Deploy Bat-Drone aerial sweep', 'Check vantage points', 'Clear area'];
        } else if (text.includes('fix') || text.includes('repair') || text.includes('batmobile')) {
            subtasks = ['Run system diagnostics', 'Replace damaged parts', 'Calibrate sensors'];
        } else {
            subtasks = ['Review mission directives', 'Execute tactical steps', 'Confirm resolution'];
        }

        document.getElementById('threatSelect').value = threat;
        document.getElementById('categorySelect').value = category;

        // Auto populate subtasks text area if available
        const subtasksInput = document.getElementById('subtasksInput');
        if (subtasksInput) {
            subtasksInput.value = subtasks.join('\n');
        }

        window.batAudio.playClick();
    }

    deployMissionFromForm() {
        const title = document.getElementById('missionTitle').value.trim();
        const threat = document.getElementById('threatSelect').value;
        const category = document.getElementById('categorySelect').value;
        const deadline = document.getElementById('deadlineInput').value;
        const subtasksRaw = document.getElementById('subtasksInput').value;

        if (!title) return;

        const bounty = threat === 'ALPHA' ? 30 : threat === 'BETA' ? 20 : 10;
        const subtasks = subtasksRaw.split('\n').filter(s => s.trim() !== '').map((st, i) => ({
            id: 'st_' + Date.now() + '_' + i,
            title: st.trim(),
            completed: false
        }));

        const newMission = {
            id: 'm_' + Date.now(),
            title,
            threat,
            category,
            deadline: deadline || null,
            bounty,
            subtasks,
            completed: false,
            createdAt: new Date().toISOString()
        };

        this.missions.unshift(newMission);
        this.saveState();

        // Reset form
        document.getElementById('missionForm').reset();
        window.batAudio.playClick();
        this.renderAll();
    }

    toggleMissionComplete(id, targetEl) {
        const mission = this.missions.find(m => m.id === id);
        if (!mission) return;

        mission.completed = !mission.completed;

        if (mission.completed) {
            mission.completedAt = new Date().toISOString();
            
            // Calculate points & early completion bonus
            let pointsEarned = mission.bounty;
            let isEarly = false;
            if (mission.deadline) {
                const now = new Date();
                const dl = new Date(mission.deadline);
                if (now < dl) {
                    pointsEarned += 10; // +10 Bonus for early completion
                    isEarly = true;
                }
            }

            this.batarangs += pointsEarned;
            
            // Trigger Audio & Projectile Animation
            window.batAudio.playBatarangThrow();
            setTimeout(() => window.batAudio.playSuccess(), 250);

            if (targetEl) {
                this.triggerBatarangFlyAnimation(targetEl);
            }

            // Check badges
            this.checkBadgeUnlocks(mission, isEarly);
        } else {
            this.batarangs = Math.max(0, this.batarangs - mission.bounty);
        }

        this.saveState();
        this.renderAll();
    }

    toggleSubtaskComplete(missionId, subtaskId) {
        const mission = this.missions.find(m => m.id === missionId);
        if (!mission) return;
        const st = mission.subtasks.find(s => s.id === subtaskId);
        if (st) {
            st.completed = !st.completed;
            window.batAudio.playClick();
            this.saveState();
            this.renderMissions();
        }
    }

    deleteMission(id) {
        this.missions = this.missions.filter(m => m.id !== id);
        window.batAudio.playClick();
        this.saveState();
        this.renderAll();
    }

    triggerBatarangFlyAnimation(sourceEl) {
        const rect = sourceEl.getBoundingClientRect();
        const scoreEl = document.getElementById('batarangCountDisplay');
        const destRect = scoreEl ? scoreEl.getBoundingClientRect() : { left: window.innerWidth - 100, top: 40 };

        const overlay = document.getElementById('batarangOverlay');
        if (!overlay) return;

        const bat = document.createElement('div');
        bat.className = 'flying-batarang';
        bat.style.setProperty('--startX', `${rect.left}px`);
        bat.style.setProperty('--startY', `${rect.top}px`);
        bat.style.setProperty('--endX', `${destRect.left}px`);
        bat.style.setProperty('--endY', `${destRect.top}px`);

        bat.innerHTML = `<svg viewBox="0 0 100 100"><path d="M50,15 C65,15 85,25 98,35 C88,48 70,52 50,42 C30,52 12,48 2,35 C15,25 35,15 50,15 Z M50,42 C60,58 75,70 95,78 C80,88 62,82 50,68 C38,82 20,88 5,78 C25,70 40,58 50,42 Z"/></svg>`;

        overlay.appendChild(bat);

        setTimeout(() => {
            bat.remove();
            // Pulse score display
            if (scoreEl) {
                scoreEl.style.transform = 'scale(1.3)';
                scoreEl.style.color = '#ffcc00';
                setTimeout(() => {
                    scoreEl.style.transform = 'scale(1)';
                    scoreEl.style.color = '#ffffff';
                }, 300);
            }
        }, 750);
    }

    checkBadgeUnlocks(mission, isEarly) {
        const newUnlocks = [];

        if (!this.unlockedBadges.includes('first_blood')) {
            newUnlocks.push('first_blood');
        }
        if (isEarly && !this.unlockedBadges.includes('speedy_justice')) {
            newUnlocks.push('speedy_justice');
        }
        if (mission.threat === 'ALPHA' && !this.unlockedBadges.includes('high_threat')) {
            newUnlocks.push('high_threat');
        }
        if (this.batarangs >= 100 && !this.unlockedBadges.includes('batarang_hoarder')) {
            newUnlocks.push('batarang_hoarder');
        }
        
        const completedWithSubtasks = this.missions.filter(m => m.completed && m.subtasks.length > 0).length;
        if (completedWithSubtasks >= 5 && !this.unlockedBadges.includes('detective_master')) {
            newUnlocks.push('detective_master');
        }

        const activeCount = this.missions.filter(m => !m.completed).length;
        if (activeCount === 0 && this.missions.length > 0 && !this.unlockedBadges.includes('clean_sweep')) {
            newUnlocks.push('clean_sweep');
        }

        if (newUnlocks.length > 0) {
            this.unlockedBadges.push(...newUnlocks);
            window.batAudio.playLevelUp();
        }
    }

    checkDeadlines() {
        const feed = document.getElementById('reminderFeed');
        if (!feed) return;

        const now = new Date();
        const urgent = [];

        this.missions.forEach(m => {
            if (m.completed || !m.deadline) return;

            const dl = new Date(m.deadline);
            const diffMs = dl - now;
            const diffMins = Math.floor(diffMs / 60000);

            if (diffMins <= 30 && diffMins > -120) {
                urgent.push({ mission: m, diffMins });

                // If less than 15 mins and sound enabled, trigger audio alarm ping once in a while
                if (diffMins <= 15 && diffMins > 0 && Math.random() < 0.3) {
                    window.batAudio.playAlarm();
                }

                // Trigger browser notification
                if (diffMins === 15 || diffMins === 5) {
                    this.triggerBrowserNotification(m, diffMins);
                }
            }
        });

        // Render Alfred's Radar alert feed
        if (urgent.length === 0) {
            feed.innerHTML = `<div style="font-size:12px; color:var(--text-muted); text-align:center; padding:10px;">All Gotham Sectors Clear. No Urgent Deadlines.</div>`;
        } else {
            feed.innerHTML = urgent.map(u => {
                const isCritical = u.diffMins <= 10;
                const timeText = u.diffMins < 0 ? `OVERDUE (${Math.abs(u.diffMins)}m ago)` : `${u.diffMins}m REMAINING`;
                return `
                    <div class="reminder-alert-card ${isCritical ? '' : 'warning'}">
                        <div>
                            <div class="alert-text">${u.mission.title}</div>
                            <div style="font-size:10px; color:var(--text-secondary);">${u.mission.category}</div>
                        </div>
                        <div class="alert-timer">${timeText}</div>
                    </div>
                `;
            }).join('');
        }

        // Re-render deadline badges on cards
        this.renderMissions();
    }

    triggerBrowserNotification(mission, minsLeft) {
        if ("Notification" in window && Notification.permission === "granted") {
            new Notification(`🦇 WAYNETECH ALERT: ${mission.title}`, {
                body: `Deadline approaching! Only ${minsLeft} minutes remaining to complete mission.`,
                icon: './assets/bat_signal_banner.png'
            });
        }
    }

    renderAll() {
        this.renderScoreAndRank();
        this.renderBadges();
        this.renderMissions();
    }

    renderScoreAndRank() {
        const countDisplay = document.getElementById('batarangCountDisplay');
        if (countDisplay) countDisplay.innerText = this.batarangs;

        // Current Rank Calculation
        let currentRank = RANKS[0];
        let nextRank = RANKS[1];

        for (let i = 0; i < RANKS.length; i++) {
            if (this.batarangs >= RANKS[i].minPoints) {
                currentRank = RANKS[i];
                nextRank = RANKS[i + 1] || null;
            }
        }

        const rankTitleEl = document.getElementById('currentRankTitle');
        if (rankTitleEl) rankTitleEl.innerText = `RANK: ${currentRank.title.toUpperCase()}`;

        const progressFill = document.getElementById('rankProgressFill');
        const rankSubtext = document.getElementById('rankSubtext');

        if (nextRank) {
            const range = nextRank.minPoints - currentRank.minPoints;
            const progress = this.batarangs - currentRank.minPoints;
            const pct = Math.min(100, Math.max(0, Math.floor((progress / range) * 100)));
            if (progressFill) progressFill.style.width = `${pct}%`;
            if (rankSubtext) rankSubtext.innerText = `${this.batarangs} / ${nextRank.minPoints} XP to ${nextRank.title}`;
        } else {
            if (progressFill) progressFill.style.width = `100%`;
            if (rankSubtext) rankSubtext.innerText = `MAX RANK ACHIEVED (${this.batarangs} XP)`;
        }
    }

    renderBadges() {
        const grid = document.getElementById('badgesGrid');
        if (!grid) return;

        grid.innerHTML = BADGES.map(b => {
            const isUnlocked = this.unlockedBadges.includes(b.id);
            return `
                <div class="badge-item ${isUnlocked ? 'unlocked' : ''}" title="${b.desc}">
                    <div class="badge-icon">${b.icon}</div>
                    <div class="badge-name">${b.name}</div>
                </div>
            `;
        }).join('');
    }

    renderMissions() {
        const list = document.getElementById('missionsList');
        if (!list) return;

        const filtered = this.missions.filter(m => {
            // Filter tab
            if (this.activeFilter === 'active' && m.completed) return false;
            if (this.activeFilter === 'completed' && !m.completed) return false;
            if (this.activeFilter === 'critical' && (m.threat !== 'ALPHA' || m.completed)) return false;
            if (this.activeFilter === 'arkham' && m.category !== 'Arkham Cases') return false;

            // Search query
            if (this.searchQuery) {
                const matchTitle = m.title.toLowerCase().includes(this.searchQuery);
                const matchCat = m.category.toLowerCase().includes(this.searchQuery);
                return matchTitle || matchCat;
            }
            return true;
        });

        if (filtered.length === 0) {
            list.innerHTML = `
                <div class="empty-state">
                    <div class="empty-state-icon">🦇</div>
                    <h3>NO DIRECTIVES MATCH FILTER</h3>
                    <p style="font-size:12px; margin-top:6px;">Deploy a new mission above or clear search filters.</p>
                </div>
            `;
            return;
        }

        const now = new Date();

        list.innerHTML = filtered.map(m => {
            let deadlineHtml = '';
            if (m.deadline) {
                const dl = new Date(m.deadline);
                const diffMs = dl - now;
                const diffMins = Math.floor(diffMs / 60000);

                let badgeClass = 'normal';
                let text = dl.toLocaleString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });

                if (!m.completed) {
                    if (diffMins < 0) {
                        badgeClass = 'critical';
                        text = `⚠️ OVERDUE (${Math.abs(diffMins)}m ago)`;
                    } else if (diffMins <= 30) {
                        badgeClass = 'critical';
                        text = `🚨 URGENT: ${diffMins}m remaining`;
                    } else if (diffMins <= 120) {
                        badgeClass = 'warning';
                        text = `⏳ ${Math.floor(diffMins/60)}h ${diffMins%60}m remaining`;
                    }
                }

                deadlineHtml = `<div class="deadline-pill ${badgeClass}">${text}</div>`;
            }

            const subtasksHtml = m.subtasks && m.subtasks.length > 0 ? `
                <div class="subtasks-container">
                    ${m.subtasks.map(st => `
                        <div class="subtask-item ${st.completed ? 'completed' : ''}">
                            <input type="checkbox" class="subtask-checkbox" ${st.completed ? 'checked' : ''} 
                                onchange="window.batApp.toggleSubtaskComplete('${m.id}', '${st.id}')">
                            <span>${st.title}</span>
                        </div>
                    `).join('')}
                </div>
            ` : '';

            return `
                <div class="mission-card threat-${m.threat} ${m.completed ? 'completed' : ''}">
                    <div class="mission-header-row">
                        <div class="mission-main-info">
                            <input type="checkbox" class="mission-checkbox" ${m.completed ? 'checked' : ''} 
                                onchange="window.batApp.toggleMissionComplete('${m.id}', this)">
                            <div>
                                <div class="mission-title">${m.title}</div>
                                <div class="mission-badges">
                                    <span class="badge-pill badge-threat-${m.threat}">THREAT: ${m.threat}</span>
                                    <span class="badge-pill badge-category">${m.category}</span>
                                    <span class="badge-pill badge-bounty">🦇 +${m.bounty} XP</span>
                                    ${deadlineHtml}
                                </div>
                            </div>
                        </div>
                        <div class="mission-actions">
                            <button class="btn-icon-action" title="Delete Mission" onclick="window.batApp.deleteMission('${m.id}')">🗑️</button>
                        </div>
                    </div>
                    ${subtasksHtml}
                </div>
            `;
        }).join('');
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.batApp = new BatComputerApp();
});
