// Advanced Natural Language & Emotion Analysis Engine for CineMood

const MOOD_DICTIONARY = {
  cozy: { valence: 0.9, energy: 0.4, tags: ["cozy", "comforting", "wholesome", "nostalgic", "sweet"], weight: 1.2 },
  comfort: { valence: 0.9, energy: 0.4, tags: ["cozy", "comforting", "wholesome", "sweet"], weight: 1.2 },
  relaxed: { valence: 0.85, energy: 0.3, tags: ["cozy", "lighthearted", "wholesome"], weight: 1.0 },
  chill: { valence: 0.8, energy: 0.3, tags: ["cozy", "lighthearted", "wholesome"], weight: 1.0 },
  happy: { valence: 0.95, energy: 0.8, tags: ["fun", "uplifting", "lighthearted", "funny", "vibrant"], weight: 1.1 },
  joyful: { valence: 0.95, energy: 0.85, tags: ["fun", "uplifting", "vibrant"], weight: 1.1 },
  sad: { valence: 0.3, energy: 0.3, tags: ["emotional", "bittersweet", "heartwarming", "melodic"], weight: 1.1 },
  depressed: { valence: 0.2, energy: 0.2, tags: ["comforting", "heartwarming", "uplifting", "wholesome"], weight: 1.2 }, // recommend comforting
  mindbending: { valence: 0.6, energy: 0.85, tags: ["mind-bending", "complex", "thought-provoking", "psychological", "existential"], weight: 1.3 },
  mind: { valence: 0.6, energy: 0.8, tags: ["mind-bending", "complex", "thought-provoking", "smart"], weight: 1.0 },
  thrilling: { valence: 0.5, energy: 0.95, tags: ["adrenaline", "intense", "suspenseful", "action", "thrilling"], weight: 1.2 },
  action: { valence: 0.6, energy: 0.9, tags: ["action", "adrenaline", "epic", "heroic"], weight: 1.1 },
  scary: { valence: 0.2, energy: 0.85, tags: ["scary", "creepy", "horrifying", "chilling", "dark"], weight: 1.3 },
  horror: { valence: 0.2, energy: 0.85, tags: ["scary", "creepy", "horrifying", "dark"], weight: 1.3 },
  romantic: { valence: 0.85, energy: 0.6, tags: ["romantic", "passionate", "sweet", "dreamy", "emotional"], weight: 1.2 },
  love: { valence: 0.85, energy: 0.6, tags: ["romantic", "sweet", "passionate"], weight: 1.1 },
  magic: { valence: 0.9, energy: 0.6, tags: ["magical", "fantasy", "dreamy", "wholesome", "cozy"], weight: 1.2 },
  space: { valence: 0.7, energy: 0.8, tags: ["space", "epic", "existential", "awe-inspiring", "sci-fi"], weight: 1.3 },
  nostalgic: { valence: 0.8, energy: 0.5, tags: ["nostalgic", "classic", "cozy", "wholesome"], weight: 1.2 },
  inspiring: { valence: 0.9, energy: 0.75, tags: ["inspiring", "heartwarming", "heroic", "uplifting"], weight: 1.2 },
  dark: { valence: 0.2, energy: 0.7, tags: ["dark", "gritty", "psychological", "cynical"], weight: 1.1 },
};

/**
 * Parses freeform user text and extracts target emotion vectors and keywords.
 */
export function analyzeUserMoodText(userText) {
  const textLower = userText.toLowerCase().trim();
  if (!textLower) {
    return {
      valence: 0.7,
      energy: 0.6,
      targetTags: ["popular", "acclaimed"],
      detectedKeywords: ["trending"]
    };
  }

  let totalValence = 0;
  let totalEnergy = 0;
  let matchesCount = 0;
  const detectedKeywords = [];
  const targetTagsSet = new Set();

  Object.entries(MOOD_DICTIONARY).forEach(([keyword, config]) => {
    if (textLower.includes(keyword)) {
      totalValence += config.valence;
      totalEnergy += config.energy;
      matchesCount += 1;
      detectedKeywords.push(keyword);
      config.tags.forEach(tag => targetTagsSet.add(tag));
    }
  });

  // Default neutral/positive if no dictionary match
  const targetValence = matchesCount > 0 ? totalValence / matchesCount : 0.7;
  const targetEnergy = matchesCount > 0 ? totalEnergy / matchesCount : 0.6;

  // Add individual words from prompt as secondary keywords
  const words = textLower.replace(/[^a-z0-9\s]/g, '').split(/\s+/);
  words.forEach(w => {
    if (w.length > 3 && !['want', 'like', 'movie', 'film', 'something', 'with', 'about', 'really', 'feel', 'feeling'].includes(w)) {
      targetTagsSet.add(w);
    }
  });

  return {
    valence: targetValence,
    energy: targetEnergy,
    targetTags: Array.from(targetTagsSet),
    detectedKeywords: detectedKeywords.length > 0 ? detectedKeywords : ["general vibe"]
  };
}

/**
 * Calculates a match score (0-100%) between user mood profile and a movie.
 */
export function calculateMovieMatchScore(movie, moodAnalysis) {
  let score = 50; // base score

  const { valence, energy, targetTags } = moodAnalysis;
  const movieTags = movie.moodTags || [];
  const movieGenres = (movie.genres || []).map(g => g.toLowerCase());
  const synopsisLower = (movie.overview || "").toLowerCase();

  // 1. Tag Overlaps (high weight)
  let tagMatches = 0;
  targetTags.forEach(tag => {
    const t = tag.toLowerCase();
    if (movieTags.some(mt => mt.toLowerCase().includes(t))) {
      tagMatches += 2.5;
    } else if (movieGenres.some(mg => mg.includes(t))) {
      tagMatches += 2.0;
    } else if (synopsisLower.includes(t)) {
      tagMatches += 1.0;
    }
  });
  score += Math.min(tagMatches * 8, 35);

  // 2. Emotion Vector Distance (Valence & Energy)
  if (movie.emotionProfile) {
    const valenceDiff = Math.abs(movie.emotionProfile.valence - valence);
    const energyDiff = Math.abs(movie.emotionProfile.energy - energy);
    const vectorDist = Math.sqrt(valenceDiff * valenceDiff + energyDiff * energyDiff);
    // closer distance = higher score bonus (up to 15 points)
    const vectorBonus = Math.max(0, 15 * (1 - vectorDist));
    score += vectorBonus;
  } else {
    score += 8;
  }

  // 3. IMDb Quality multiplier bonus (up to 10 points)
  const imdbScore = movie.imdbRating || 7.5;
  score += Math.min((imdbScore - 6.0) * 3, 10);

  const finalScore = Math.min(Math.max(Math.round(score), 65), 99);
  return finalScore;
}

/**
 * Generates natural language AI insight explaining why this movie matches the user's prompt.
 */
export function generateMoodExplanation(movie, moodAnalysis, userPrompt) {
  const matchedTags = movie.moodTags ? movie.moodTags.filter(tag => 
    moodAnalysis.targetTags.some(tt => tag.toLowerCase().includes(tt.toLowerCase()))
  ) : [];

  if (matchedTags.length > 0) {
    return `Matches your wish for ${matchedTags.slice(0, 3).join(', ')} vibes with an impressive ${movie.imdbRating} IMDb rating.`;
  }

  if (moodAnalysis.detectedKeywords.includes("cozy") || moodAnalysis.detectedKeywords.includes("comfort")) {
    return `Perfect comfort watch with a warm atmosphere, rich storytelling, and high rewatchability.`;
  }

  if (moodAnalysis.detectedKeywords.includes("mindbending") || moodAnalysis.detectedKeywords.includes("mind")) {
    return `Delivers the exact mind-twisting plot, high stakes, and atmospheric mystery you're craving.`;
  }

  if (moodAnalysis.detectedKeywords.includes("scary") || moodAnalysis.detectedKeywords.includes("horror")) {
    return `Delivers deep atmospheric tension, suspenseful thrills, and psychological dread.`;
  }

  if (userPrompt && userPrompt.trim()) {
    return `Recommended based on your input "${userPrompt.slice(0, 40)}${userPrompt.length > 40 ? '...' : ''}" for its thematic alignment and stellar audience reviews.`;
  }

  return `Highly acclaimed cinematic experience with a ${movie.imdbRating}/10 audience score matching your current mood profile.`;
}
