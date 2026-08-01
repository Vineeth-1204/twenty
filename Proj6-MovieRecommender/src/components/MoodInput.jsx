import React, { useState } from 'react';
import { Sparkles, Mic, RefreshCw, Compass } from 'lucide-react';

const QUICK_MOOD_PRESETS = [
  { label: "☕ Cozy & Comfort", prompt: "I had a long day and want a cozy, uplifting, wholesome movie with magic or warm vibes" },
  { label: "🤯 Mind-Bending", prompt: "Feeling curious, want a complex mind-bending sci-fi thriller with plot twists like Inception" },
  { label: "🚀 Epic Space", prompt: "Want an awe-inspiring, epic space adventure with emotional depth and grandeur" },
  { label: "😱 Late Night Horror", prompt: "Craving intense scary thrills, chilling psychological atmosphere and horror" },
  { label: "❤️ Romantic Vibe", prompt: "Looking for a dreamy, emotional romance movie with great chemistry and music" },
  { label: "🥳 Fun & Feel-Good", prompt: "Want something super funny, lighthearted, energetic and entertaining to cheer me up" }
];

export default function MoodInput({ onAnalyzeMood, isAnalyzing, currentPrompt, setCurrentPrompt }) {
  const [activeChipIndex, setActiveChipIndex] = useState(null);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (currentPrompt.trim()) {
      onAnalyzeMood(currentPrompt);
    }
  };

  const handleChipClick = (preset, index) => {
    setActiveChipIndex(index);
    setCurrentPrompt(preset.prompt);
    onAnalyzeMood(preset.prompt);
  };

  const handleRandomPrompt = () => {
    const randomIndex = Math.floor(Math.random() * QUICK_MOOD_PRESETS.length);
    handleChipClick(QUICK_MOOD_PRESETS[randomIndex], randomIndex);
  };

  return (
    <section className="glass-panel" style={{ padding: '24px', marginBottom: '24px' }}>
      
      {/* Title & Tagline */}
      <div style={{ textAlign: 'center', marginBottom: '20px' }}>
        <h2 style={{ fontSize: '1.75rem', fontWeight: 800, marginBottom: '8px' }}>
          How are you feeling <span className="gradient-text">tonight?</span>
        </h2>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.92rem', maxWidth: '540px', margin: '0 auto' }}>
          Describe your mood, emotional vibe, or story preferences in your own words. Our AI recommendation engine will research and match the perfect films.
        </p>
      </div>

      {/* Main Text Form */}
      <form onSubmit={handleSubmit} style={{ position: 'relative', marginBottom: '18px' }}>
        <textarea
          value={currentPrompt}
          onChange={(e) => {
            setCurrentPrompt(e.target.value);
            setActiveChipIndex(null);
          }}
          placeholder="e.g. 'I feel exhausted after work, want something nostalgic, funny, and cozy that isn't too heavy...' or 'Need an intense psychological thriller that will keep me guessing...'"
          rows={3}
          style={{
            width: '100%',
            background: 'rgba(10, 8, 24, 0.8)',
            border: '1.5px solid var(--border-glow)',
            borderRadius: '16px',
            color: 'white',
            padding: '16px 18px',
            fontSize: '0.98rem',
            fontFamily: 'var(--font-body)',
            resize: 'none',
            outline: 'none',
            boxShadow: 'inset 0 2px 8px rgba(0,0,0,0.4)',
            transition: 'border-color 0.3s ease'
          }}
        />

        {/* Action Controls in Text Area */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: '10px', gap: '10px', flexWrap: 'wrap' }}>
          
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              type="button"
              className="btn-secondary"
              onClick={handleRandomPrompt}
              style={{ padding: '8px 14px', fontSize: '0.82rem' }}
              title="Surprise me with a random mood prompt"
            >
              <Compass size={15} color="#ec4899" />
              <span>Surprise Me</span>
            </button>

            <button
              type="button"
              className="btn-secondary"
              onClick={() => {
                const sampleText = "Feeling adventurous and want an epic sci-fi space journey!";
                setCurrentPrompt(sampleText);
              }}
              style={{ padding: '8px 14px', fontSize: '0.82rem' }}
              title="Voice Input Simulation"
            >
              <Mic size={15} color="#8b5cf6" />
              <span className="hide-on-mobile">Voice Input</span>
            </button>
          </div>

          <button
            type="submit"
            className="btn-primary pulse-glow"
            disabled={isAnalyzing || !currentPrompt.trim()}
            style={{ 
              opacity: (isAnalyzing || !currentPrompt.trim()) ? 0.6 : 1,
              cursor: (isAnalyzing || !currentPrompt.trim()) ? 'not-allowed' : 'pointer',
              padding: '10px 22px',
              fontSize: '0.92rem'
            }}
          >
            {isAnalyzing ? (
              <>
                <RefreshCw size={18} className="spin" style={{ animation: 'spin 1s linear infinite' }} />
                <span>Researching Mood...</span>
              </>
            ) : (
              <>
                <Sparkles size={18} />
                <span>Get AI Recommendations</span>
              </>
            )}
          </button>

        </div>
      </form>

      {/* Quick Mood Preset Chips */}
      <div>
        <p style={{ fontSize: '0.78rem', textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--text-dim)', marginBottom: '10px', fontWeight: 600 }}>
          Or Pick a Quick Mood Preset:
        </p>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
          {QUICK_MOOD_PRESETS.map((preset, idx) => (
            <button
              key={idx}
              type="button"
              className={`mood-chip ${activeChipIndex === idx ? 'active' : ''}`}
              onClick={() => handleChipClick(preset, idx)}
            >
              {preset.label}
            </button>
          ))}
        </div>
      </div>

    </section>
  );
}
