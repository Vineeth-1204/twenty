import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../models/calendar_day.dart';
import '../models/dune_quote.dart';
import 'quote_service.dart';

class LocationOption {
  final String name;
  final String planet;
  final double lat;
  final double lon;
  final bool isArrakisTerritory;

  LocationOption({
    required this.name,
    required this.planet,
    required this.lat,
    required this.lon,
    this.isArrakisTerritory = false,
  });
}

class WeatherService {
  static final List<LocationOption> locations = [
    // Arrakis Locations
    LocationOption(
      name: "Sietch Tabr",
      planet: "Arrakis",
      lat: 25.0,
      lon: 55.0,
      isArrakisTerritory: true,
    ),
    LocationOption(
      name: "Arrakeen Capital",
      planet: "Arrakis",
      lat: 26.0,
      lon: 56.0,
      isArrakisTerritory: true,
    ),
    LocationOption(
      name: "Carthage Sietch",
      planet: "Arrakis",
      lat: 24.5,
      lon: 54.2,
      isArrakisTerritory: true,
    ),
    LocationOption(
      name: "Shield Wall Ridge",
      planet: "Arrakis",
      lat: 27.1,
      lon: 55.8,
      isArrakisTerritory: true,
    ),
    LocationOption(
      name: "Deep Desert (Erg)",
      planet: "Arrakis",
      lat: 20.0,
      lon: 50.0,
      isArrakisTerritory: true,
    ),
    LocationOption(
      name: "Caladan (Homeworld)",
      planet: "Caladan",
      lat: 47.5,
      lon: -122.3,
      isArrakisTerritory: true,
    ),

    // Real World Earth Cities (Styled in Dune Fashion)
    LocationOption(name: "Dubai", planet: "Earth", lat: 25.2048, lon: 55.2708),
    LocationOption(name: "Cairo", planet: "Earth", lat: 30.0444, lon: 31.2357),
    LocationOption(name: "Tokyo", planet: "Earth", lat: 35.6762, lon: 139.6503),
    LocationOption(name: "Mumbai", planet: "Earth", lat: 19.0760, lon: 72.8777),
    LocationOption(name: "London", planet: "Earth", lat: 51.5074, lon: -0.1278),
    LocationOption(name: "New York", planet: "Earth", lat: 40.7128, lon: -74.0060),
  ];

  static Future<WeatherData> fetchWeather(LocationOption loc) async {
    if (loc.isArrakisTerritory) {
      return _generateArrakisData(loc);
    }

    try {
      final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=${loc.lat}&longitude=${loc.lon}&current_weather=true&hourly=relativehumidity_2m,surface_pressure",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        final double temp = (current['temperature'] as num).toDouble();
        final double wind = (current['windspeed'] as num).toDouble();
        final int code = (current['weathercode'] as num).toInt();

        WeatherType condition = _mapWmoCodeToWeatherType(code, temp);
        double humidity = 45.0;
        if (data['hourly'] != null && data['hourly']['relativehumidity_2m'] != null) {
          humidity = (data['hourly']['relativehumidity_2m'][0] as num).toDouble();
        }

        return WeatherData(
          locationName: loc.name,
          planetName: "Earth (Dune Grid)",
          temperature: temp,
          feelsLike: temp + 2.0,
          humidity: humidity,
          windSpeed: wind,
          windDirection: "SW",
          uvIndex: temp > 30 ? 9.5 : 4.0,
          atmosphericPressure: 1014.0,
          condition: condition,
          conditionDescription: _getConditionDescription(condition, code),
          spiceBlowActivity: (temp * 1.5).clamp(10.0, 95.0),
          sandwormThreatLevel: (wind / 10.0).clamp(1.0, 9.8),
          windtrapWaterYield: (humidity * 0.25).clamp(0.2, 18.0),
          monsoonSurgeIndex: humidity > 65 ? 85.0 : humidity,
          solarPosition: DateTime.now().hour > 18 || DateTime.now().hour < 6 ? "Night Moons" : "Sun Zenith",
          moonPhase: "Muad'Dib Second Moon",
          fremenAdvisory: humidity > 50
              ? "High atmospheric humidity detected! Engage windtraps to harvest atmospheric water."
              : "Dry solar conditions. Secure stillsuit valves.",
        );
      }
    } catch (_) {
      // Fallback on network delay or offline
    }

    return _generateArrakisData(loc);
  }

  static WeatherData _generateArrakisData(LocationOption loc) {
    if (loc.name == "Caladan (Homeworld)") {
      return WeatherData.mockArrakis(
        locationName: loc.name,
        condition: WeatherType.monsoonRain,
        temp: 21.0,
        humidityVal: 82.0,
        wind: 32.0,
      );
    }

    final hour = DateTime.now().hour;
    WeatherType type = WeatherType.extremeHeat;

    if (hour >= 21 || hour < 5) {
      type = WeatherType.moonsNight;
    } else if (hour >= 12 && hour <= 14) {
      type = WeatherType.sandstorm;
    } else if (hour % 3 == 0) {
      type = WeatherType.spiceDust;
    } else if (hour % 4 == 0) {
      type = WeatherType.clearSky;
    }

    return WeatherData.mockArrakis(
      locationName: loc.name,
      condition: type,
      temp: type == WeatherType.moonsNight ? 18.0 : 49.5,
      humidityVal: type == WeatherType.monsoonRain ? 75.0 : 5.2,
      wind: type == WeatherType.sandstorm ? 680.0 : 45.0,
    );
  }

  static WeatherType _mapWmoCodeToWeatherType(int code, double temp) {
    if (code >= 51 && code <= 99) return WeatherType.monsoonRain;
    if (code >= 1 && code <= 3 && temp > 35) return WeatherType.extremeHeat;
    if (code >= 45 && code <= 48) return WeatherType.spiceDust;
    return WeatherType.clearSky;
  }

  static String _getConditionDescription(WeatherType type, int wmoCode) {
    switch (type) {
      case WeatherType.monsoonRain:
        return "Monsoon Rain & Water Accumulation (WMO $wmoCode)";
      case WeatherType.extremeHeat:
        return "Solar Heat Zenith (WMO $wmoCode)";
      case WeatherType.sandstorm:
        return "Desert Wind Haze & Dust";
      case WeatherType.spiceDust:
        return "Atmospheric Spice Haze";
      case WeatherType.moonsNight:
        return "Clear Night Skies";
      case WeatherType.clearSky:
        return "Clear Sun & Sand Horizon";
    }
  }

  // Generates 30 days of Dune Calendar data for any year & month
  static List<CalendarDay> getDuneCalendarForMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<CalendarDay> list = [];

    final weatherPool = [
      WeatherType.clearSky,
      WeatherType.extremeHeat,
      WeatherType.sandstorm,
      WeatherType.spiceDust,
      WeatherType.moonsNight,
      WeatherType.monsoonRain,
    ];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final weather = weatherPool[(day * 3 + month) % weatherPool.length];

      bool isMonsoon = weather == WeatherType.monsoonRain || day % 9 == 0;
      bool isStorm = weather == WeatherType.sandstorm || day % 7 == 0;

      double maxT = isMonsoon ? 26.0 : (42.0 + (day % 10));
      double minT = isMonsoon ? 18.0 : (16.0 + (day % 6));
      double hum = isMonsoon ? 78.0 : (4.0 + (day % 8));
      double wormRisk = isStorm ? 9.5 : (2.0 + (day % 7));
      double monsoonChance = isMonsoon ? 92.0 : (day % 12 * 5.0);

      String moonPhase = (day % 4 == 0)
          ? "Muad'Dib Full Moon"
          : (day % 4 == 1)
              ? "First Moon (Kynes)"
              : "Waning Moon";

      DuneQuote quote = QuoteService.getQuoteForWeather(weather);

      String tip = isStorm
          ? "Coriolis storm predicted. Secure sietch seals and stay off dunes."
          : isMonsoon
              ? "Monsoon water surge expected! Maximize windtraps intake."
              : "Maintain stillsuit catches and walk with un-rhythmed steps.";

      list.add(CalendarDay(
        date: date,
        expectedWeather: weather,
        maxTemp: maxT,
        minTemp: minT,
        humidity: hum,
        wormSignRisk: wormRisk,
        monsoonChance: monsoonChance,
        moonPhase: moonPhase,
        quoteOfDay: quote,
        fremenTip: tip,
        isMonsoonHighlight: isMonsoon,
        isStormWarning: isStorm,
      ));
    }

    return list;
  }
}
