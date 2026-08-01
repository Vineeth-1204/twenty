import React, { useState, useEffect, useMemo } from 'react';
import Header from './components/Header';
import MoodInput from './components/MoodInput';
import FiltersBar from './components/FiltersBar';
import MovieCard from './components/MovieCard';
import MovieDetailsModal from './components/MovieDetailsModal';
import Watchlist from './components/Watchlist';
import ApiKeyModal from './components/ApiKeyModal';

import { fallbackMovies } from './data/fallbackMovies';
import { analyzeUserMoodText, calculateMovieMatchScore, generateMoodExplanation } from './services/moodEngine';
import { searchMoviesByMoodTMDB, fetchMovieWatchProviders } from './services/tmdbApi';
import { Sparkles, Film, Compass, RefreshCw } from 'lucide-react';

export default function App() {
  // State Initialization
  const [apiKey, setApiKey] = useState(() => localStorage.getItem('cinemood_tmdb_key') || '');
  const [currentPrompt, setCurrentPrompt] = useState('I feel tired after work and want a cozy, uplifting movie with magic');
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  
  const [movieResults, setMovieResults] = useState([]);
  const [selectedService, setSelectedService] = useState('all');
  const [minRating, setMinRating] = useState(6.0);
  
  const [selectedMovie, setSelectedMovie] = useState(null);
  const [watchlist, setWatchlist] = useState(() => {
    try {
      const saved = localStorage.getItem('cinemood_watchlist');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  const [isWatchlistOpen, setIsWatchlistOpen] = useState(false);
  const [isApiKeyModalOpen, setIsApiKeyModalOpen] = useState(false);
  const [isMobileFrame, setIsMobileFrame] = useState(false);

  // Persist Watchlist
  useEffect(() => {
    localStorage.setItem('cinemood_watchlist', JSON.stringify(watchlist));
  }, [watchlist]);

  // Persist API Key
  const handleSaveApiKey = (key) => {
    setApiKey(key);
    if (key) {
      localStorage.setItem('cinemood_tmdb_key', key);
    } else {
      localStorage.removeItem('cinemood_tmdb_key');
    }
  };

  // Main Mood Analysis & Recommendation Trigger
  const handleAnalyzeMood = async (userPromptText) => {
    setIsAnalyzing(true);

    try {
      // 1. Run NLP Sentiment Engine on text
      const moodAnalysis = analyzeUserMoodText(userPromptText);

      let poolMovies = [];

      // 2. Fetch live movies if TMDB key exists, otherwise use rich fallback dataset
      if (apiKey.trim()) {
        try {
          const tmdbResults = await searchMoviesByMoodTMDB(apiKey, moodAnalysis.detectedKeywords.join(' ') || userPromptText);
          poolMovies = tmdbResults;
        } catch (err) {
          console.warn("Live TMDB query failed, using built-in movie dataset fallback:", err);
          poolMovies = fallbackMovies;
        }
      } else {
        poolMovies = fallbackMovies;
      }

      // 3. Compute match score & generate AI insight explanation for each movie
      const ranked = poolMovies.map(movie => {
        const matchScore = calculateMovieMatchScore(movie, moodAnalysis);
        const moodExplanation = generateMoodExplanation(movie, moodAnalysis, userPromptText);
        return {
          ...movie,
          matchScore,
          moodExplanation
        };
      });

      // Sort by Match Score descending
      ranked.sort((a, b) => b.matchScore - a.matchScore);
      setMovieResults(ranked);

    } catch (error) {
      console.error("Error analyzing mood:", error);
    } finally {
      setIsAnalyzing(false);
    }
  };

  // Initial recommendation run on mount
  useEffect(() => {
    handleAnalyzeMood(currentPrompt);
  }, []);

  // Filter recommendations by selected streaming service & minimum IMDb rating score
  const filteredRecommendations = useMemo(() => {
    return movieResults.filter(movie => {
      // Rating filter
      if (movie.imdbRating < minRating) return false;

      // Streaming provider filter
      if (selectedService !== 'all') {
        const providers = movie.streaming || [];
        const hasService = providers.some(p => p.toLowerCase().includes(selectedService.toLowerCase()));
        if (!hasService) return false;
      }

      return true;
    });
  }, [movieResults, selectedService, minRating]);

  // Watchlist Toggle
  const handleToggleWatchlist = (movie) => {
    setWatchlist(prev => {
      const exists = prev.some(m => m.id === movie.id);
      if (exists) {
        return prev.filter(m => m.id !== movie.id);
      } else {
        return [...prev, movie];
      }
    });
  };

  return (
    <div className={`view-wrapper ${isMobileFrame ? 'mobile-frame' : ''}`}>
      <div className="app-container">
        
        {/* Navigation Header */}
        <Header 
          watchlistCount={watchlist.length}
          onOpenWatchlist={() => setIsWatchlistOpen(true)}
          onOpenApiKeyModal={() => setIsApiKeyModalOpen(true)}
          apiKeySet={!!apiKey.trim()}
          isMobileFrame={isMobileFrame}
          onToggleMobileFrame={() => setIsMobileFrame(!isMobileFrame)}
        />

        {/* Mood Prompt Form & Presets */}
        <MoodInput 
          onAnalyzeMood={handleAnalyzeMood}
          isAnalyzing={isAnalyzing}
          currentPrompt={currentPrompt}
          setCurrentPrompt={setCurrentPrompt}
        />

        {/* Filters Bar (Streaming Provider & IMDb rating slider) */}
        <FiltersBar 
          selectedService={selectedService}
          setSelectedService={setSelectedService}
          minRating={minRating}
          setMinRating={setMinRating}
        />

        {/* Recommendations Section */}
        <main>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '18px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Sparkles size={20} color="#ec4899" />
              <h3 style={{ fontSize: '1.25rem', fontWeight: 800, margin: 0 }}>
                Matched Movie Recommendations
              </h3>
            </div>
            <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
              Showing {filteredRecommendations.length} movies
            </span>
          </div>

          {/* Loading Skeleton */}
          {isAnalyzing ? (
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
              gap: '20px'
            }}>
              {[1, 2, 3, 4].map(n => (
                <div key={n} className="glass-panel" style={{ height: '420px', padding: '16px' }}>
                  <div className="skeleton" style={{ width: '100%', height: '240px', borderRadius: '12px', marginBottom: '14px' }} />
                  <div className="skeleton" style={{ width: '60%', height: '18px', borderRadius: '4px', marginBottom: '10px' }} />
                  <div className="skeleton" style={{ width: '80%', height: '14px', borderRadius: '4px', marginBottom: '8px' }} />
                  <div className="skeleton" style={{ width: '100%', height: '40px', borderRadius: '8px' }} />
                </div>
              ))}
            </div>
          ) : filteredRecommendations.length === 0 ? (
            <div className="glass-panel" style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
              <Film size={48} style={{ opacity: 0.3, marginBottom: '16px' }} />
              <h4 style={{ fontSize: '1.2rem', fontWeight: 700, marginBottom: '6px' }}>No movies found matching these filters</h4>
              <p style={{ fontSize: '0.9rem', maxWidth: '400px', margin: '0 auto 16px auto' }}>
                Try lowering the IMDb score slider or selecting 'All Services' to view all matched recommendations.
              </p>
              <button 
                className="btn-secondary"
                onClick={() => {
                  setSelectedService('all');
                  setMinRating(5.0);
                }}
              >
                Reset Filters
              </button>
            </div>
          ) : (
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
              gap: '22px'
            }}>
              {filteredRecommendations.map(movie => (
                <MovieCard 
                  key={movie.id}
                  movie={movie}
                  onSelectMovie={(m) => setSelectedMovie(m)}
                  isWatchlisted={watchlist.some(w => w.id === movie.id)}
                  onToggleWatchlist={handleToggleWatchlist}
                />
              ))}
            </div>
          )}
        </main>

        {/* Full Details & Trailer Modal */}
        {selectedMovie && (
          <MovieDetailsModal 
            movie={selectedMovie}
            onClose={() => setSelectedMovie(null)}
            isWatchlisted={watchlist.some(w => w.id === selectedMovie.id)}
            onToggleWatchlist={handleToggleWatchlist}
          />
        )}

        {/* Saved Watchlist Drawer */}
        {isWatchlistOpen && (
          <Watchlist 
            watchlist={watchlist}
            onClose={() => setIsWatchlistOpen(false)}
            onRemoveMovie={(id) => setWatchlist(prev => prev.filter(m => m.id !== id))}
            onSelectMovie={(m) => {
              setSelectedMovie(m);
              setIsWatchlistOpen(false);
            }}
          />
        )}

        {/* TMDB API Key Modal */}
        {isApiKeyModalOpen && (
          <ApiKeyModal 
            apiKey={apiKey}
            onSaveApiKey={handleSaveApiKey}
            onClose={() => setIsApiKeyModalOpen(false)}
          />
        )}

      </div>
    </div>
  );
}
