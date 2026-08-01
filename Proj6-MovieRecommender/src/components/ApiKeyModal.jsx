import React, { useState } from 'react';
import { X, Key, CheckCircle2, AlertCircle, ExternalLink } from 'lucide-react';

export default function ApiKeyModal({ apiKey, onSaveApiKey, onClose }) {
  const [inputKey, setInputKey] = useState(apiKey || '');
  const [statusMessage, setStatusMessage] = useState(null);

  const handleSave = () => {
    if (inputKey.trim().length > 10) {
      onSaveApiKey(inputKey.trim());
      setStatusMessage({ type: 'success', text: 'TMDB API Key saved successfully! Live database connected.' });
      setTimeout(() => onClose(), 1200);
    } else if (!inputKey.trim()) {
      onSaveApiKey('');
      setStatusMessage({ type: 'info', text: 'Reset to built-in offline movie database.' });
      setTimeout(() => onClose(), 1200);
    } else {
      setStatusMessage({ type: 'error', text: 'Key appears too short. Please check your TMDB v3 API Key.' });
    }
  };

  return (
    <div style={{
      position: 'fixed',
      inset: 0,
      zIndex: 110,
      background: 'rgba(5, 4, 12, 0.85)',
      backdropFilter: 'blur(12px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px'
    }}>
      <div 
        className="glass-panel" 
        style={{
          width: '100%',
          maxWidth: '520px',
          padding: '28px',
          position: 'relative'
        }}
      >
        <button
          onClick={onClose}
          style={{
            position: 'absolute',
            top: '16px',
            right: '16px',
            background: 'rgba(255,255,255,0.06)',
            color: 'white',
            border: 'none',
            borderRadius: '50%',
            width: '34px',
            height: '34px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer'
          }}
        >
          <X size={18} />
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
          <div style={{ background: 'rgba(139, 92, 246, 0.2)', padding: '10px', borderRadius: '12px' }}>
            <Key size={24} color="#a78bfa" />
          </div>
          <div>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 800, margin: 0 }}>
              TMDB API Key Settings
            </h3>
            <p style={{ fontSize: '0.82rem', color: 'var(--text-muted)', margin: 0 }}>
              Connect live movie database & real-time streaming availability
            </p>
          </div>
        </div>

        <p style={{ fontSize: '0.88rem', color: '#d1d5db', lineHeight: 1.5, marginBottom: '16px' }}>
          CineMood includes a rich built-in dataset out of the box. You can optionally insert your free <strong>TMDB (The Movie Database) API v3 key</strong> to unlock live search across 800,000+ films!
        </p>

        <div style={{ marginBottom: '20px' }}>
          <label style={{ display: 'block', fontSize: '0.8rem', fontWeight: 600, color: 'var(--text-muted)', marginBottom: '6px' }}>
            YOUR TMDB API KEY:
          </label>
          <input
            type="password"
            value={inputKey}
            onChange={(e) => setInputKey(e.target.value)}
            placeholder="e.g. 1a2b3c4d5e6f7g8h9i0j..."
            style={{
              width: '100%',
              background: 'rgba(10, 8, 24, 0.9)',
              border: '1px solid var(--border-glow)',
              borderRadius: '12px',
              padding: '12px 16px',
              color: 'white',
              fontSize: '0.95rem',
              outline: 'none'
            }}
          />
        </div>

        {statusMessage && (
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '10px 14px',
            borderRadius: '10px',
            marginBottom: '18px',
            fontSize: '0.85rem',
            background: statusMessage.type === 'success' ? 'rgba(52, 211, 153, 0.15)' : 'rgba(239, 68, 68, 0.15)',
            color: statusMessage.type === 'success' ? '#34d399' : '#ef4444'
          }}>
            {statusMessage.type === 'success' ? <CheckCircle2 size={16} /> : <AlertCircle size={16} />}
            <span>{statusMessage.text}</span>
          </div>
        )}

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '12px' }}>
          <a
            href="https://www.themoviedb.org/settings/api"
            target="_blank"
            rel="noopener noreferrer"
            style={{ fontSize: '0.82rem', color: '#38bdf8', textDecoration: 'none', display: 'inline-flex', alignItems: 'center', gap: '4px' }}
          >
            <span>Get a free TMDB API Key</span>
            <ExternalLink size={13} />
          </a>

          <div style={{ display: 'flex', gap: '10px' }}>
            <button
              className="btn-secondary"
              onClick={() => {
                setInputKey('');
                onSaveApiKey('');
              }}
              style={{ padding: '8px 16px', fontSize: '0.85rem' }}
            >
              Use Built-In
            </button>
            <button
              className="btn-primary"
              onClick={handleSave}
              style={{ padding: '8px 20px', fontSize: '0.85rem' }}
            >
              Save Key
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}
