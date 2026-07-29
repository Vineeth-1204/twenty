enum WeatherType {
  sandstorm,
  extremeHeat,
  monsoonRain,
  spiceDust,
  moonsNight,
  clearSky,
}

class WeatherData {
  final String locationName;
  final String planetName;
  final double temperature; // in Celsius
  final double feelsLike;
  final double humidity; // Percentage (0-100)
  final double windSpeed; // km/h (Coriolis winds)
  final String windDirection;
  final double uvIndex;
  final double atmosphericPressure; // hPa
  final WeatherType condition;
  final String conditionDescription;
  
  // Arrakis & Lore Specific Metrics
  final double spiceBlowActivity; // 0 - 100%
  final double sandwormThreatLevel; // 0 - 10 (Thumper / Vibration score)
  final double windtrapWaterYield; // Liters per hour collected
  final double monsoonSurgeIndex; // 0 - 100% (Atmospheric moisture / monsoon surge)
  final String solarPosition; // Dawn, Zenith, Dusk, Night
  final String moonPhase; // First Moon (Kynes), Second Moon (Muad'Dib), Dark Moon
  final String fremenAdvisory;

  WeatherData({
    required this.locationName,
    required this.planetName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.uvIndex,
    required this.atmosphericPressure,
    required this.condition,
    required this.conditionDescription,
    required this.spiceBlowActivity,
    required this.sandwormThreatLevel,
    required this.windtrapWaterYield,
    required this.monsoonSurgeIndex,
    required this.solarPosition,
    required this.moonPhase,
    required this.fremenAdvisory,
  });

  factory WeatherData.mockArrakis({
    required String locationName,
    required WeatherType condition,
    double temp = 48.0,
    double humidityVal = 4.0,
    double wind = 420.0,
  }) {
    String desc = "Scorching Desert Sun";
    String advisory = "Maintain stillsuit seals tightly. Conserve body moisture.";
    double wormThreat = 3.5;
    double spice = 45.0;
    double yieldVal = 0.4;
    double monsoon = 2.0;

    switch (condition) {
      case WeatherType.sandstorm:
        desc = "Violent Coriolis Sandstorm";
        advisory = "SEEK IMMEDIATE SHELTER IN ROCK CREVICES! Static charges elevated.";
        wormThreat = 9.2;
        spice = 95.0;
        yieldVal = 0.1;
        monsoon = 0.5;
        break;
      case WeatherType.extremeHeat:
        desc = "Severe Solar Flare Extreme Heat";
        advisory = "Do not travel across open desert during daytime. High surface radiation.";
        wormThreat = 5.0;
        spice = 60.0;
        yieldVal = 0.2;
        monsoon = 1.0;
        break;
      case WeatherType.monsoonRain:
        desc = "Atmospheric Water Surge / Caladan Rain Shift";
        advisory = "UNPRECEDENTED MOISTURE ACCUMULATION! Deploy windtraps at max intake.";
        wormThreat = 1.0;
        spice = 10.0;
        yieldVal = 28.5;
        monsoon = 88.0;
        break;
      case WeatherType.spiceDust:
        desc = "Spice Blow Atmospheric Haze";
        advisory = "Precious Melange particulate in atmosphere. Filter masks required.";
        wormThreat = 7.8;
        spice = 90.0;
        yieldVal = 0.5;
        monsoon = 5.0;
        break;
      case WeatherType.moonsNight:
        desc = "Desert Night Cool Under Moons";
        advisory = "Optimal time for night travel without moisture loss.";
        wormThreat = 2.1;
        spice = 30.0;
        yieldVal = 3.8;
        monsoon = 12.0;
        break;
      case WeatherType.clearSky:
        desc = "Clear Desert Horizon";
        advisory = "Sun zenith approaching. Ensure stillsuit catch-tubes are clean.";
        wormThreat = 4.0;
        spice = 50.0;
        yieldVal = 0.6;
        monsoon = 4.0;
        break;
    }

    return WeatherData(
      locationName: locationName,
      planetName: locationName == "Caladan" ? "Caladan" : "Arrakis",
      temperature: temp,
      feelsLike: temp + 4,
      humidity: humidityVal,
      windSpeed: wind,
      windDirection: "NW",
      uvIndex: temp > 40 ? 14.5 : 6.0,
      atmosphericPressure: 1013,
      condition: condition,
      conditionDescription: desc,
      spiceBlowActivity: spice,
      sandwormThreatLevel: wormThreat,
      windtrapWaterYield: yieldVal,
      monsoonSurgeIndex: monsoon,
      solarPosition: "Zenith Sun",
      moonPhase: "Muad'Dib (Second Moon Ascending)",
      fremenAdvisory: advisory,
    );
  }
}
