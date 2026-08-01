import React from 'react';
import { Filter, Star, Tv } from 'lucide-react';

const STREAMING_PLATFORMS = [
  { id: 'all', name: 'All Services' },
  { id: 'Netflix', name: 'Netflix', color: '#E50914' },
  { id: 'Amazon Prime Video', name: 'Prime Video', color: '#00A8E1' },
  { id: 'Disney+', name: 'Disney+', color: '#113CCF' },
  { id: 'Apple TV+', name: 'Apple TV+', color: '#A3A3A3' },
  { id: 'HBO Max', name: 'HBO Max', color: '#993399' }
];

export default function FiltersBar({ 
  selectedService, 
  setSelectedService, 
  minRating, 
  setMinRating,
  selectedGenre,
  setSelectedGenre,
  availableGenres
}) {
  return (
    <div className="glass-panel" style={{ padding: '16px 20px', marginBottom: '24px' }}>
      
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '16px', flexWrap: 'wrap' }}>
        
        {/* Streaming Service Selector */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', overflowX: 'auto', paddingBottom: '4px' }}>
          <Tv size={16} color="var(--accent-purple)" />
          <span style={{ fontSize: '0.82rem', fontWeight: 600, color: 'var(--text-muted)', whiteSpace: 'nowrap' }}>
            Streaming:
          </span>
          <div style={{ display: 'flex', gap: '6px' }}>
            {STREAMING_PLATFORMS.map(platform => (
              <button
                key={platform.id}
                onClick={() => setSelectedService(platform.id)}
                style={{
                  background: selectedService === platform.id 
                    ? (platform.color ? `${platform.color}33` : 'rgba(139, 92, 246, 0.3)') 
                    : 'rgba(255,255,255,0.04)',
                  border: `1px solid ${selectedService === platform.id ? (platform.color || '#8b5cf6') : 'rgba(255,255,255,0.08)'}`,
                  color: selectedService === platform.id ? '#ffffff' : 'var(--text-muted)',
                  padding: '6px 12px',
                  borderRadius: '12px',
                  fontSize: '0.8rem',
                  fontWeight: selectedService === platform.id ? 600 : 400,
                  cursor: 'pointer',
                  whiteSpace: 'nowrap',
                  transition: 'all 0.2s ease'
                }}
              >
                {platform.name}
              </button>
            ))}
          </div>
        </div>

        {/* Minimum IMDb Rating Slider */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
            <Star size={15} color="#f59e0b" fill="#f59e0b" />
            <span style={{ fontSize: '0.82rem', fontWeight: 600, color: 'var(--text-muted)' }}>
              IMDb Score: <strong style={{ color: '#f59e0b' }}>{minRating.toFixed(1)}+</strong>
            </span>
          </div>
          <input
            type="range"
            min="5.0"
            max="9.0"
            step="0.5"
            value={minRating}
            onChange={(e) => setMinRating(parseFloat(e.target.value))}
            style={{
              accentColor: '#f59e0b',
              cursor: 'pointer',
              width: '100px'
            }}
          />
        </div>

      </div>

    </div>
  );
}
