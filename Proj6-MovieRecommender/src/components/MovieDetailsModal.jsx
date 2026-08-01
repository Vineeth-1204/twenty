import React, { useState } from 'react';
import { X, Star, Play, Bookmark, Check, ExternalLink, Tv, Users, Clapperboard, Sparkles } from 'lucide-react';

export default function MovieDetailsModal({ movie, onClose, isWatchlisted, onToggleWatchlist }) {
  const [showTrailer, setShowTrailer] = useState(false);

  if (!movie) return null;

  return (
    <div style={{
      position: 'fixed',
      inset: 0,
      zIndex: 100,
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
          maxWidth: '840px',
          maxHeight: '90vh',
          overflowY: 'auto',
          position: 'relative',
          borderRadius: '24px',
          border: '1px solid var(--border-glow)'
        }}
      >
        {/* Close Button */}
        <button
          onClick={onClose}
          style={{
            position: 'absolute',
            top: '16px',
            right: '16px',
            zIndex: 20,
            background: 'rgba(0,0,0,0.6)',
            color: 'white',
            border: '1px solid rgba(255,255,255,0.2)',
            borderRadius: '50%',
            width: '38px',
            height: '38px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer'
          }}
        >
          <X size={20} />
        </button>

        {/* Hero Backdrop & Trailer Header */}
        <div style={{ position: 'relative', width: '100%', height: '320px', backgroundColor: '#090714' }}>
          
          {showTrailer && movie.trailerUrl ? (
            <iframe
              src={`${movie.trailerUrl}?autoplay=1`}
              title={`${movie.title} Trailer`}
              style={{ width: '100%', height: '100%', border: 'none' }}
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          ) : (
            <>
              <img 
                src={movie.backdrop || movie.poster} 
                alt={movie.title} 
                style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              />
              <div style={{
                position: 'absolute',
                inset: 0,
                background: 'linear-gradient(to top, rgba(16, 13, 35, 1) 0%, rgba(16, 13, 35, 0.4) 60%, rgba(0,0,0,0.6) 100%)'
              }} />

              {/* Play Trailer Button overlay */}
              <div style={{
                position: 'absolute',
                inset: 0,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}>
                <button
                  className="btn-primary"
                  onClick={() => setShowTrailer(true)}
                  style={{ padding: '14px 28px', fontSize: '1rem', boxShadow: '0 8px 32px rgba(124, 58, 237, 0.6)' }}
                >
                  <Play size={20} fill="white" />
                  <span>Watch Trailer</span>
                </button>
              </div>
            </>
          )}

        </div>

        {/* Modal Main Body */}
        <div style={{ padding: '24px 28px' }}>
          
          {/* Header Metadata */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '16px', marginBottom: '16px' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
                <span style={{ background: 'linear-gradient(135deg, #7c3aed, #ec4899)', padding: '2px 10px', borderRadius: '999px', fontSize: '0.78rem', fontWeight: 700 }}>
                  {movie.matchScore || 92}% Mood Match
                </span>
                <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  {movie.year} • {movie.runtime}
                </span>
              </div>
              <h2 style={{ fontSize: '2rem', fontWeight: 800, margin: 0, lineHeight: 1.15 }}>
                {movie.title}
              </h2>
            </div>

            {/* Save Watchlist Button */}
            <button
              className="btn-primary"
              onClick={() => onToggleWatchlist(movie)}
              style={{
                background: isWatchlisted ? 'linear-gradient(135deg, #059669, #10b981)' : 'linear-gradient(135deg, #7c3aed, #db2777)',
                padding: '10px 20px',
                fontSize: '0.9rem'
              }}
            >
              {isWatchlisted ? <Check size={18} /> : <Bookmark size={18} />}
              <span>{isWatchlisted ? 'In Watchlist' : 'Add to Watchlist'}</span>
            </button>
          </div>

          {/* Rating Badges & External Links */}
          <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', marginBottom: '20px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', background: 'rgba(245, 158, 11, 0.15)', border: '1px solid rgba(245, 158, 11, 0.3)', padding: '6px 14px', borderRadius: '10px' }}>
              <Star size={16} color="#f59e0b" fill="#f59e0b" />
              <span style={{ fontSize: '0.9rem', fontWeight: 700, color: '#f59e0b' }}>
                {movie.imdbRating} / 10 IMDb
              </span>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', background: 'rgba(52, 211, 153, 0.15)', border: '1px solid rgba(52, 211, 153, 0.3)', padding: '6px 14px', borderRadius: '10px' }}>
              <span style={{ fontSize: '0.9rem', fontWeight: 700, color: '#34d399' }}>
                {movie.letterboxdRating} ★ Letterboxd
              </span>
            </div>

            <a 
              href={`https://www.imdb.com/find/?q=${encodeURIComponent(movie.title)}`} 
              target="_blank" 
              rel="noopener noreferrer"
              className="btn-secondary"
              style={{ padding: '6px 12px', fontSize: '0.82rem' }}
            >
              <span>IMDb Page</span>
              <ExternalLink size={14} />
            </a>

            <a 
              href={`https://letterboxd.com/search/${encodeURIComponent(movie.title)}/`} 
              target="_blank" 
              rel="noopener noreferrer"
              className="btn-secondary"
              style={{ padding: '6px 12px', fontSize: '0.82rem' }}
            >
              <span>Letterboxd</span>
              <ExternalLink size={14} />
            </a>
          </div>

          {/* AI Mood Explanation Highlight */}
          <div style={{
            background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.15), rgba(236, 72, 153, 0.15))',
            border: '1px solid rgba(139, 92, 246, 0.3)',
            borderRadius: '16px',
            padding: '16px 20px',
            marginBottom: '24px'
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 700, color: '#a78bfa', marginBottom: '6px', fontSize: '0.92rem' }}>
              <Sparkles size={16} />
              <span>AI Mood Analysis & Research</span>
            </div>
            <p style={{ margin: 0, fontSize: '0.92rem', color: '#f3f4f6', lineHeight: 1.5 }}>
              {movie.moodExplanation || "Analyzed against your input prompt. Perfectly aligns with requested emotional valence, pacing, and genre aesthetics."}
            </p>
          </div>

          {/* Synopsis */}
          <div style={{ marginBottom: '24px' }}>
            <h4 style={{ fontSize: '1.05rem', fontWeight: 700, marginBottom: '8px', color: 'var(--text-muted)' }}>
              Overview & Plot
            </h4>
            <p style={{ fontSize: '0.96rem', lineHeight: 1.6, color: '#e5e7eb' }}>
              {movie.overview}
            </p>
          </div>

          {/* Director & Cast */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '24px' }}>
            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '14px 18px', borderRadius: '14px', border: '1px solid var(--border-light)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-muted)', fontSize: '0.82rem', marginBottom: '4px' }}>
                <Clapperboard size={16} />
                <span>Director</span>
              </div>
              <p style={{ margin: 0, fontWeight: 600, fontSize: '0.95rem' }}>
                {movie.director}
              </p>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '14px 18px', borderRadius: '14px', border: '1px solid var(--border-light)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-muted)', fontSize: '0.82rem', marginBottom: '4px' }}>
                <Users size={16} />
                <span>Starring Cast</span>
              </div>
              <p style={{ margin: 0, fontWeight: 600, fontSize: '0.95rem' }}>
                {movie.cast ? movie.cast.join(', ') : 'Leading Actors'}
              </p>
            </div>
          </div>

          {/* Available Streaming Services */}
          <div>
            <h4 style={{ fontSize: '1.05rem', fontWeight: 700, marginBottom: '10px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Tv size={18} color="#06b6d4" />
              <span>Available to Stream On:</span>
            </h4>
            <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
              {(movie.streaming || ["Netflix", "Amazon Prime Video"]).map((service, idx) => (
                <div key={idx} style={{
                  background: 'rgba(6, 182, 212, 0.12)',
                  border: '1px solid rgba(6, 182, 212, 0.3)',
                  color: '#38bdf8',
                  padding: '8px 16px',
                  borderRadius: '12px',
                  fontWeight: 600,
                  fontSize: '0.88rem'
                }}>
                  {service}
                </div>
              ))}
            </div>
          </div>

        </div>

      </div>

    </div>
  );
}
