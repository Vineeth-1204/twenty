import React, { useState } from 'react';
import { X, Bookmark, Trash2, CheckCircle2, Star, Play } from 'lucide-react';

export default function Watchlist({ watchlist, onClose, onRemoveMovie, onSelectMovie }) {
  const [filterTab, setFilterTab] = useState('all'); // 'all', 'unwatched', 'watched'
  const [watchedIds, setWatchedIds] = useState(new Set());

  const toggleWatched = (id) => {
    const next = new Set(watchedIds);
    if (next.has(id)) {
      next.delete(id);
    } else {
      next.add(id);
    }
    setWatchedIds(next);
  };

  const filteredMovies = watchlist.filter(m => {
    if (filterTab === 'watched') return watchedIds.has(m.id);
    if (filterTab === 'unwatched') return !watchedIds.has(m.id);
    return true;
  });

  return (
    <div style={{
      position: 'fixed',
      inset: 0,
      zIndex: 90,
      background: 'rgba(5, 4, 12, 0.8)',
      backdropFilter: 'blur(10px)',
      display: 'flex',
      justifyContent: 'flex-end'
    }}>
      
      <div 
        className="glass-panel" 
        style={{
          width: '100%',
          maxWidth: '460px',
          height: '100vh',
          borderRadius: 0,
          borderLeft: '1px solid var(--border-glow)',
          display: 'flex',
          flexDirection: 'column',
          padding: '24px'
        }}
      >
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Bookmark size={22} color="#ec4899" />
            <h2 style={{ fontSize: '1.4rem', fontWeight: 800, margin: 0 }}>
              Your Watchlist ({watchlist.length})
            </h2>
          </div>

          <button
            onClick={onClose}
            style={{
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
        </div>

        {/* Filter Tabs */}
        <div style={{ display: 'flex', gap: '8px', marginBottom: '20px' }}>
          {[
            { id: 'all', label: 'All Saved' },
            { id: 'unwatched', label: 'Plan to Watch' },
            { id: 'watched', label: 'Watched' }
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setFilterTab(tab.id)}
              style={{
                flex: 1,
                padding: '8px',
                borderRadius: '10px',
                fontSize: '0.8rem',
                fontWeight: 600,
                border: 'none',
                cursor: 'pointer',
                background: filterTab === tab.id ? 'linear-gradient(135deg, #7c3aed, #ec4899)' : 'rgba(255,255,255,0.05)',
                color: 'white',
                transition: 'all 0.2s ease'
              }}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* Movie Items List */}
        <div style={{ flexGrow: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {filteredMovies.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
              <Bookmark size={40} style={{ opacity: 0.3, marginBottom: '12px' }} />
              <p style={{ fontWeight: 600, marginBottom: '4px' }}>No movies in this list yet</p>
              <p style={{ fontSize: '0.82rem' }}>Save movies from your mood recommendations to watch later.</p>
            </div>
          ) : (
            filteredMovies.map(movie => {
              const isWatched = watchedIds.has(movie.id);

              return (
                <div 
                  key={movie.id}
                  style={{
                    display: 'flex',
                    gap: '12px',
                    background: 'rgba(255,255,255,0.03)',
                    border: '1px solid var(--border-light)',
                    borderRadius: '14px',
                    padding: '10px',
                    alignItems: 'center'
                  }}
                >
                  <img 
                    src={movie.poster} 
                    alt={movie.title}
                    onClick={() => onSelectMovie(movie)}
                    style={{ width: '56px', height: '80px', objectFit: 'cover', borderRadius: '8px', cursor: 'pointer' }}
                  />

                  <div style={{ flexGrow: 1, overflow: 'hidden' }}>
                    <h4 
                      onClick={() => onSelectMovie(movie)}
                      style={{ 
                        fontSize: '0.95rem', 
                        fontWeight: 700, 
                        margin: 0, 
                        marginBottom: '4px',
                        cursor: 'pointer',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        textDecoration: isWatched ? 'line-through' : 'none',
                        opacity: isWatched ? 0.6 : 1
                      }}
                    >
                      {movie.title}
                    </h4>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                      <span style={{ color: '#f59e0b', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '2px' }}>
                        <Star size={12} fill="#f59e0b" /> {movie.imdbRating}
                      </span>
                      <span>• {movie.year}</span>
                    </div>

                    <p style={{ fontSize: '0.74rem', color: '#38bdf8', margin: 0, marginTop: '4px' }}>
                      {movie.streaming ? movie.streaming[0] : 'Streaming'}
                    </p>
                  </div>

                  <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                    <button
                      onClick={() => toggleWatched(movie.id)}
                      style={{
                        background: isWatched ? 'rgba(52, 211, 153, 0.2)' : 'rgba(255,255,255,0.06)',
                        color: isWatched ? '#34d399' : 'white',
                        border: 'none',
                        borderRadius: '8px',
                        padding: '6px',
                        cursor: 'pointer'
                      }}
                      title={isWatched ? "Mark as Unwatched" : "Mark as Watched"}
                    >
                      <CheckCircle2 size={16} />
                    </button>

                    <button
                      onClick={() => onRemoveMovie(movie.id)}
                      style={{
                        background: 'rgba(239, 68, 68, 0.15)',
                        color: '#ef4444',
                        border: 'none',
                        borderRadius: '8px',
                        padding: '6px',
                        cursor: 'pointer'
                      }}
                      title="Remove from Watchlist"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              );
            })
          )}
        </div>

      </div>

    </div>
  );
}
