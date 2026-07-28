// WayneTech Audio Synthesizer (Web Audio API)
// Provides realistic tactical sound effects without external file dependencies.

class BatAudioEngine {
    constructor() {
        this.ctx = null;
        this.enabled = true;
    }

    init() {
        if (!this.ctx) {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            if (AudioContext) {
                this.ctx = new AudioContext();
            }
        }
        if (this.ctx && this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
    }

    setMuted(muted) {
        this.enabled = !muted;
    }

    // High-tech tactile click sound
    playClick() {
        if (!this.enabled) return;
        this.init();
        if (!this.ctx) return;

        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(800, this.ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(300, this.ctx.currentTime + 0.04);

        gain.gain.setValueAtTime(0.15, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.04);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start();
        osc.stop(this.ctx.currentTime + 0.04);
    }

    // Swooshing metallic Batarang throw sound
    playBatarangThrow() {
        if (!this.enabled) return;
        this.init();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        
        // Pitch swoosh
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(200, now);
        osc.frequency.exponentialRampToValueAtTime(1400, now + 0.12);
        osc.frequency.exponentialRampToValueAtTime(400, now + 0.25);

        gain.gain.setValueAtTime(0.01, now);
        gain.gain.linearRampToValueAtTime(0.25, now + 0.1);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.28);

        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start(now);
        osc.stop(now + 0.28);

        // Metallic ring at the end
        const pingOsc = this.ctx.createOscillator();
        const pingGain = this.ctx.createGain();
        pingOsc.type = 'sine';
        pingOsc.frequency.setValueAtTime(1850, now + 0.15);
        pingOsc.frequency.exponentialRampToValueAtTime(2200, now + 0.35);

        pingGain.gain.setValueAtTime(0.001, now);
        pingGain.gain.setValueAtTime(0.18, now + 0.15);
        pingGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.4);

        pingOsc.connect(pingGain);
        pingGain.connect(this.ctx.destination);
        pingOsc.start(now + 0.15);
        pingOsc.stop(now + 0.4);
    }

    // High priority mission completion sound
    playSuccess() {
        if (!this.enabled) return;
        this.init();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
        
        notes.forEach((freq, idx) => {
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();
            osc.type = 'sine';
            osc.frequency.value = freq;

            const startTime = now + (idx * 0.07);
            gain.gain.setValueAtTime(0, startTime);
            gain.gain.linearRampToValueAtTime(0.2, startTime + 0.02);
            gain.gain.exponentialRampToValueAtTime(0.001, startTime + 0.3);

            osc.connect(gain);
            gain.connect(this.ctx.destination);
            osc.start(startTime);
            osc.stop(startTime + 0.3);
        });
    }

    // Urgent Bat-Computer warning chime for approaching deadlines
    playAlarm() {
        if (!this.enabled) return;
        this.init();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        [0, 0.18, 0.36].forEach(delay => {
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();
            osc.type = 'sawtooth';
            osc.frequency.setValueAtTime(880, now + delay);
            osc.frequency.exponentialRampToValueAtTime(440, now + delay + 0.12);

            gain.gain.setValueAtTime(0.2, now + delay);
            gain.gain.exponentialRampToValueAtTime(0.001, now + delay + 0.14);

            osc.connect(gain);
            gain.connect(this.ctx.destination);
            osc.start(now + delay);
            osc.stop(now + delay + 0.14);
        });
    }

    // Heroic Level Up fanfare
    playLevelUp() {
        if (!this.enabled) return;
        this.init();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const chord = [220, 277.18, 329.63, 440, 554.37, 659.25, 880]; // A major triumph
        chord.forEach((freq, i) => {
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();
            osc.type = i > 3 ? 'sine' : 'triangle';
            osc.frequency.value = freq;

            const start = now + (i * 0.05);
            gain.gain.setValueAtTime(0.001, start);
            gain.gain.linearRampToValueAtTime(0.2, start + 0.05);
            gain.gain.exponentialRampToValueAtTime(0.001, start + 0.8);

            osc.connect(gain);
            gain.connect(this.ctx.destination);
            osc.start(start);
            osc.stop(start + 0.8);
        });
    }
}

window.batAudio = new BatAudioEngine();
