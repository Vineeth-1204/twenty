import React from 'react';
import { Film, Bookmark, Key, Smartphone, Monitor } from 'lucide-react';

export default function Header({ 
  watchlistCount, 
  onOpenWatchlist, 
  onOpenApiKeyModal, 
  apiKeySet,
  isMobileFrame,
  onToggleMobileFrame
}) {
  return (
    <header className="glass-panel" style={{ padding: '14px 20px', marginBottom: '24px', position: 'sticky', top: '12px', zIndex: 40 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        
        {/* Logo */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
          <div style={{
            background: 'linear-gradient(135deg, #7c3aed, #db2777)',
            padding: '10px',
            borderRadius: '14px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 4px 16px rgba(124, 58, 237, 0.4)'
          }}>
            <Film size={22} color="#ffffff" />
          </div>
          <div>
            <h1 style={{ fontSize: '1.35rem', fontWeight: 800, margin: 0, lineHeight: 1.1 }}>
              Cine<span className="gradient-text">Mood</span>
            </h1>
            <p style={{ fontSize: '0.72rem', color: 'var(--text-muted)', margin: 0 }}>
              AI Recommender & Streaming Guide
            </p>
          </div>
        </div>

        {/* Action Buttons */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          
          {/* Mobile Frame Toggle */}
          <button 
            className="btn-secondary" 
            onClick={onToggleMobileFrame}
            title={isMobileFrame ? "Switch to Full Desktop Layout" : "Preview in Mobile Phone View"}
            style={{ padding: '8px 12px', fontSize: '0.8rem' }}
          >
            {isMobileFrame ? <Monitor size={16} /> : <Smartphone size={16} />}
            <span className="hide-on-mobile">{isMobileFrame ? "Full Width" : "Mobile App"}</span>
          </button>

          {/* TMDB API Key Settings */}
          <button 
            className="btn-secondary"
            onClick={onOpenApiKeyModal}
            style={{ 
              padding: '8px 12px', 
              fontSize: '0.8rem',
              borderColor: apiKeySet ? 'rgba(52, 211, 153, 0.4)' : 'var(--border-light)',
              background: apiKeySet ? 'rgba(52, 211, 153, 0.1)' : 'rgba(255,255,255,0.05)'
            }}
          >
            <Key size={16} color={apiKeySet ? "#34d399" : "#9ca3af"} />
            <span className="hide-on-mobile">{apiKeySet ? "TMDB Live" : "API Key"}</span>
          </button>

          {/* Saved Watchlist Button */}
          <button 
            className="btn-primary" 
            onClick={onOpenWatchlist}
            style={{ padding: '8px 16px', fontSize: '0.85rem' }}
          >
            <Bookmark size={16} />
            <span>Watchlist</span>
            {watchlistCount > 0 && (
              <span style={{
                background: 'white',
                color: '#7c3aed',
                borderRadius: '999px',
                padding: '2px 8px',
                fontSize: '0.75rem',
                fontWeight: 700,
                marginLeft: '4px'
              }}>
                {watchlistCount}
              </span>
            )}
          </button>

        </div>

      </div>
    </header>
  );
}
