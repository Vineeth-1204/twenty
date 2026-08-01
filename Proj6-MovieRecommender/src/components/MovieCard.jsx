import React from 'react';
import { Star, Sparkles, Play, Bookmark, Check, Tv } from 'lucide-react';

export default function MovieCard({ 
  movie, 
  onSelectMovie, 
  isWatchlisted, 
  onToggleWatchlist 
}) {
  const matchScore = movie.matchScore || 88;

  // Determine badge color based on match score
  let matchBadgeBg = 'linear-gradient(135deg, #7c3aed, #ec4899)';
  if (matchScore >= 90) {
    matchBadgeBg = 'linear-gradient(135deg, #059669, #10b981)';
  } else if (matchScore < 80) {
    matchBadgeBg = 'linear-gradient(135deg, #d97706, #f59e0b)';
  }

  return (
    <div 
      className="glass-panel glass-panel-interactive" 
      style={{ 
        display: 'flex', 
        flexDirection: 'column', 
        height: '100%', 
        overflow: 'hidden',
        position: 'relative'
      }}
    >
      {/* Poster Image Container */}
      <div 
        className="poster-container" 
        onClick={() => onSelectMovie(movie)}
        style={{ cursor: 'pointer' }}
      >
        <img 
          src={movie.poster} 
          alt={movie.title} 
          className="poster-img"
          loading="lazy"
          onError={(e) => {
            e.target.src = 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500&auto=format&fit=crop&q=80';
          }}
        />

        {/* Top Badges Overlay */}
        <div style={{
          position: 'absolute',
          top: '12px',
          left: '12px',
          right: '12px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          zIndex: 10
        }}>
          {/* Mood Match Score */}
          <div style={{
            background: matchBadgeBg,
            color: 'white',
            padding: '4px 10px',
            borderRadius: '999px',
            fontSize: '0.78rem',
            fontWeight: 700,
            display: 'flex',
            alignItems: 'center',
            gap: '4px',
            boxShadow: '0 4px 12px rgba(0,0,0,0.5)'
          }}>
            <Sparkles size={12} />
            <span>{matchScore}% Match</span>
          </div>

          {/* Save Watchlist Button */}
          <button
            onClick={(e) => {
              e.stopPropagation();
              onToggleWatchlist(movie);
            }}
            style={{
              background: isWatchlisted ? '#ec4899' : 'rgba(15, 12, 30, 0.8)',
              color: 'white',
              border: '1px solid rgba(255,255,255,0.2)',
              borderRadius: '50%',
              width: '34px',
              height: '34px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: '0 4px 12px rgba(0,0,0,0.4)',
              transition: 'all 0.2s ease'
            }}
            title={isWatchlisted ? "Remove from Watchlist" : "Save to Watchlist"}
          >
            {isWatchlisted ? <Check size={16} /> : <Bookmark size={16} />}
          </button>
        </div>

        {/* Hover Trailer Play Overlay */}
        <div style={{
          position: 'absolute',
          inset: 0,
          background: 'rgba(9, 7, 20, 0.4)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          opacity: 0,
          transition: 'opacity 0.3s ease'
        }} className="poster-overlay">
          <div style={{
            background: 'linear-gradient(135deg, #7c3aed, #db2777)',
            borderRadius: '50%',
            padding: '16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 8px 24px rgba(124, 58, 237, 0.6)'
          }}>
            <Play size={24} color="white" fill="white" style={{ marginLeft: '3px' }} />
          </div>
        </div>

      </div>

      {/* Movie Details Content */}
      <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', flexGrow: 1 }}>
        
        {/* Rating & Year Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '6px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '3px', background: 'rgba(245, 158, 11, 0.15)', padding: '2px 8px', borderRadius: '6px' }}>
              <Star size={13} color="#f59e0b" fill="#f59e0b" />
              <span style={{ fontSize: '0.82rem', fontWeight: 700, color: '#f59e0b' }}>
                {movie.imdbRating}
              </span>
            </div>
            <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>
              ({movie.letterboxdRating}★ Letterboxd)
            </span>
          </div>

          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 500 }}>
            {movie.year}
          </span>
        </div>

        {/* Movie Title */}
        <h3 
          onClick={() => onSelectMovie(movie)}
          style={{ 
            fontSize: '1.15rem', 
            fontWeight: 700, 
            marginBottom: '8px', 
            cursor: 'pointer',
            lineHeight: 1.25
          }}
        >
          {movie.title}
        </h3>

        {/* Genres */}
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px', marginBottom: '12px' }}>
          {movie.genres.slice(0, 3).map((g, idx) => (
            <span key={idx} style={{
              fontSize: '0.72rem',
              background: 'rgba(255,255,255,0.06)',
              color: 'var(--text-muted)',
              padding: '2px 8px',
              borderRadius: '6px'
            }}>
              {g}
            </span>
          ))}
        </div>

        {/* AI Why it matches insight bubble */}
        <div style={{
          background: 'rgba(139, 92, 246, 0.12)',
          borderLeft: '3px solid #8b5cf6',
          padding: '10px 12px',
          borderRadius: '0 8px 8px 0',
          marginBottom: '14px',
          fontSize: '0.8rem',
          color: '#e5e7eb',
          lineHeight: 1.35
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontWeight: 600, color: '#a78bfa', marginBottom: '3px' }}>
            <Sparkles size={12} />
            <span>Why this fits your mood:</span>
          </div>
          {movie.moodExplanation || `Hand-picked for its atmospheric depth and high audience approval.`}
        </div>

        {/* Streaming Providers Footer */}
        <div style={{ marginTop: 'auto', paddingTop: '10px', borderTop: '1px solid var(--border-light)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Tv size={14} color="var(--text-muted)" />
            <span style={{ fontSize: '0.74rem', color: 'var(--text-muted)' }}>
              Watch on:
            </span>
            <span style={{ fontSize: '0.76rem', color: '#38bdf8', fontWeight: 600 }}>
              {movie.streaming ? movie.streaming.slice(0, 2).join(', ') : 'Streaming'}
            </span>
          </div>

          <button
            className="btn-secondary"
            onClick={() => onSelectMovie(movie)}
            style={{ padding: '6px 12px', fontSize: '0.78rem' }}
          >
            View Details
          </button>

        </div>

      </div>
    </div>
  );
}
