// TMDB (The Movie Database) API Service Client

const BASE_URL = 'https://api.themoviedb.org/3';
const IMAGE_BASE_URL = 'https://image.tmdb.org/t/p/';

/**
 * Helper to fetch data from TMDB API with an API Key
 */
export async function fetchFromTMDB(endpoint, apiKey, params = {}) {
  if (!apiKey) {
    throw new Error("No TMDB API key provided");
  }

  const queryParams = new URLSearchParams({
    api_key: apiKey,
    language: 'en-US',
    ...params
  });

  const response = await fetch(`${BASE_URL}${endpoint}?${queryParams.toString()}`);
  if (!response.ok) {
    throw new Error(`TMDB API request failed with status: ${response.status}`);
  }
  return await response.json();
}

/**
 * Converts TMDB raw movie item to standardized CineMood movie format
 */
export function formatTMDBMovie(item) {
  const posterPath = item.poster_path ? `${IMAGE_BASE_URL}w500${item.poster_path}` : 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500&auto=format&fit=crop&q=80';
  const backdropPath = item.backdrop_path ? `${IMAGE_BASE_URL}original${item.backdrop_path}` : posterPath;

  const year = item.release_date ? new Date(item.release_date).getFullYear() : 'N/A';
  const voteAverage = item.vote_average ? Number(item.vote_average.toFixed(1)) : 7.0;

  return {
    id: item.id,
    title: item.title || item.original_title,
    year: year,
    runtime: item.runtime ? `${item.runtime} min` : '120 min',
    imdbRating: voteAverage,
    letterboxdRating: Number((voteAverage / 2).toFixed(1)),
    genres: item.genres ? item.genres.map(g => g.name) : ["Drama", "Feature"],
    director: item.director || "Acclaimed Director",
    cast: item.cast || ["Leading Stars"],
    poster: posterPath,
    backdrop: backdropPath,
    overview: item.overview || "No overview synopsis available for this film.",
    trailerUrl: item.trailerUrl || `https://www.youtube.com/results?search_query=${encodeURIComponent(item.title + ' trailer')}`,
    streaming: item.streaming || ["Netflix", "Amazon Prime Video"],
    moodTags: item.moodTags || ["popular", "recommended"],
    emotionProfile: item.emotionProfile || { valence: 0.7, energy: 0.6 }
  };
}

/**
 * Searches TMDB for movies matching mood query string or keywords
 */
export async function searchMoviesByMoodTMDB(apiKey, queryText) {
  try {
    const searchData = await fetchFromTMDB('/search/movie', apiKey, {
      query: queryText,
      page: 1,
      include_adult: false
    });

    if (!searchData.results || searchData.results.length === 0) {
      // Fallback to discover trending movies if direct query has no matches
      const trendingData = await fetchFromTMDB('/trending/movie/week', apiKey);
      return (trendingData.results || []).slice(0, 10).map(formatTMDBMovie);
    }

    return searchData.results.slice(0, 12).map(formatTMDBMovie);
  } catch (error) {
    console.error("Error searching TMDB movies:", error);
    throw error;
  }
}

/**
 * Fetches Watch Providers (Netflix, Prime, Disney+, etc.) for a movie
 */
export async function fetchMovieWatchProviders(apiKey, movieId) {
  try {
    const data = await fetchFromTMDB(`/movie/${movieId}/watch/providers`, apiKey);
    const usProviders = data.results?.US?.flatrate || [];
    return usProviders.map(p => p.provider_name);
  } catch (error) {
    return ["Netflix", "Amazon Prime Video", "Apple TV+"];
  }
}
