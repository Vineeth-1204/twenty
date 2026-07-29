import '../models/dune_quote.dart';
import '../models/weather_data.dart';

class QuoteService {
  static final List<DuneQuote> _allQuotes = [
    // --- SANDSTORM / CORIOLIS STORM ---
    DuneQuote(
      text: "The mystery of life isn't a problem to solve, but a reality to experience. A process cannot be understood by stopping it.",
      author: "Jamis / Paul Atreides",
      source: "Dune",
      triggerWeather: WeatherType.sandstorm,
      loreTag: "Coriolis Storm Wisdom",
    ),
    DuneQuote(
      text: "Coriolis storms on Arrakis slice through flesh and steel alike. When the sand wind blows, only the mountain endures.",
      author: "Stilgar",
      source: "Fremen Manual",
      triggerWeather: WeatherType.sandstorm,
      loreTag: "Desert Survival",
    ),
    DuneQuote(
      text: "Bless the Maker and His water. Bless the coming and going of Him. May His passage cleanse the world.",
      author: "Fremen Prayer",
      source: "Sietch Liturgy",
      triggerWeather: WeatherType.sandstorm,
      loreTag: "Shai-Hulud Invocation",
    ),

    // --- EXTREME HEAT / SOLAR FLARE ---
    DuneQuote(
      text: "I must not fear. Fear is the mind-killer. Fear is the little-death that brings total obliteration.",
      author: "Bene Gesserit Litany",
      source: "Ritual of the Mother",
      triggerWeather: WeatherType.extremeHeat,
      loreTag: "Litany Against Fear",
    ),
    DuneQuote(
      text: "A stillsuit is a sustained-survival system. Processed perspiration, urine, and body heat yield pure drinkable water.",
      author: "Dr. Liet-Kynes",
      source: "Imperial Planetology Report",
      triggerWeather: WeatherType.extremeHeat,
      loreTag: "Stillsuit Mechanics",
    ),
    DuneQuote(
      text: "The sun of Arrakis does not merely shine; it judges. Those who waste water belong to the sand.",
      author: "Chani",
      source: "Tales of Sietch Tabr",
      triggerWeather: WeatherType.extremeHeat,
      loreTag: "Fremen Wisdom",
    ),

    // --- MONSOON / RAIN / MOISTURE ---
    DuneQuote(
      text: "On Caladan, we had a different concept of water. There, it fell from the sky in torrents. Here on Arrakis, water is life's blood.",
      author: "Duke Leto Atreides",
      source: "Journal entry",
      triggerWeather: WeatherType.monsoonRain,
      loreTag: "Caladan Memory",
    ),
    DuneQuote(
      text: "Water is the ultimate currency of the cosmos. A single monsoon storm on Arrakis could awaken a sleeping continent.",
      author: "Paul Muad'Dib",
      source: "The Arrakis Transformation",
      triggerWeather: WeatherType.monsoonRain,
      loreTag: "Ecological Prophecy",
    ),
    DuneQuote(
      text: "Listen to the moisture collectors in the morning mist. Each drop is a gift from the heavens.",
      author: "Harah",
      source: "Sietch Sayyadina",
      triggerWeather: WeatherType.monsoonRain,
      loreTag: "Windtrap Lore",
    ),

    // --- SPICE DUST / MELANGE HAZE ---
    DuneQuote(
      text: "The spice extends life. The spice expands consciousness. The spice must flow.",
      author: "Guild Navigator",
      source: "Spacing Guild Codex",
      triggerWeather: WeatherType.spiceDust,
      loreTag: "The Melange Imperative",
    ),
    DuneQuote(
      text: "He who controls the spice controls the universe.",
      author: "Baron Vladimir Harkonnen",
      source: "Giedi Prime Records",
      triggerWeather: WeatherType.spiceDust,
      loreTag: "Imperial Politics",
    ),
    DuneQuote(
      text: "A red haze fills the desert horizon. The sand blows rich with Melange. The worms are awakening.",
      author: "Gurney Halleck",
      source: "Atreides Smuggler Log",
      triggerWeather: WeatherType.spiceDust,
      loreTag: "Spice Blow Warning",
    ),

    // --- MOONS NIGHT / COOL DESERT NIGHT ---
    DuneQuote(
      text: "Deep in the human unconscious is a pervasive need for a logical universe that makes sense. But the real universe is always one step beyond logic.",
      author: "Princess Irulan",
      source: "Manual of Muad'Dib",
      triggerWeather: WeatherType.moonsNight,
      loreTag: "Imperial Chronicles",
    ),
    DuneQuote(
      text: "The two moons of Arrakis gaze down upon the dunes: First Moon Kynes and Second Moon Muad'Dib.",
      author: "Fremen Legend",
      source: "Celestial Records",
      triggerWeather: WeatherType.moonsNight,
      loreTag: "Arrakis Moons",
    ),
    DuneQuote(
      text: "In the cool night of the desert, step without rhythm, and you shall not attract the worm.",
      author: "Stilgar",
      source: "Sandwalking Guide",
      triggerWeather: WeatherType.moonsNight,
      loreTag: "Sandwalk Wisdom",
    ),

    // --- CLEAR SKY / SUN ZENITH ---
    DuneQuote(
      text: "Arrakis teaches the attitude of the knife — chopping off what's incomplete and saying: 'Now it's complete because it's ended here.'",
      author: "Paul Atreides",
      source: "Dune",
      triggerWeather: WeatherType.clearSky,
      loreTag: "Attitude of the Knife",
    ),
    DuneQuote(
      text: "Look upon the endless sands. Under the clear sky of Arrakis, there are no secrets, only survival.",
      author: "Lady Jessica",
      source: "Bene Gesserit Journal",
      triggerWeather: WeatherType.clearSky,
      loreTag: "Desert Clarity",
    ),
  ];

  static DuneQuote getQuoteForWeather(WeatherType type) {
    final matches = _allQuotes.where((q) => q.triggerWeather == type).toList();
    if (matches.isEmpty) {
      return _allQuotes.first;
    }
    // Return quote based on current time or random element
    final index = DateTime.now().second % matches.length;
    return matches[index];
  }

  static List<DuneQuote> getAllQuotes() => _allQuotes;
}
