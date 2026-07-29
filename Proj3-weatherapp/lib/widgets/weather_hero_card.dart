import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_data.dart';
import '../theme/dune_colors.dart';

class WeatherHeroCard extends StatelessWidget {
  final WeatherData data;
  const WeatherHeroCard({super.key, required this.data});

  IconData _getWeatherIcon(WeatherType condition) {
    switch (condition) {
      case WeatherType.sandstorm:
        return Icons.air;
      case WeatherType.extremeHeat:
        return Icons.wb_sunny;
      case WeatherType.monsoonRain:
        return Icons.water_drop;
      case WeatherType.spiceDust:
        return Icons.blur_on;
      case WeatherType.moonsNight:
        return Icons.nights_stay;
      case WeatherType.clearSky:
        return Icons.wb_twilight;
    }
  }

  Color _getThreatColor(double threat) {
    if (threat > 7.5) return DuneColors.stormRed;
    if (threat > 4.5) return DuneColors.warningYellow;
    return DuneColors.calmGreen;
  }

  @override
  Widget build(BuildContext context) {
    final threatColor = _getThreatColor(data.sandwormThreatLevel);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DuneColors.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DuneColors.glassBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Location & Planet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.locationName.toUpperCase(),
                    style: GoogleFonts.cinzel(
                      color: DuneColors.duneGold,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.public, color: DuneColors.fremenBlue, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "${data.planetName} Sector",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: threatColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: threatColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: threatColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "WORM SIGN ${data.sandwormThreatLevel.toStringAsFixed(1)}/10",
                      style: GoogleFonts.rajdhani(
                        color: threatColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Temperature Hero Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.temperature.toStringAsFixed(0),
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    "°C",
                    style: GoogleFonts.cinzel(
                      color: DuneColors.spiceOrange,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    _getWeatherIcon(data.condition),
                    color: DuneColors.spiceOrange,
                    size: 44,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.conditionDescription,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.rajdhani(
                      color: DuneColors.duneGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Grid Metrics (Wind, UV, Spice, Pressure)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DuneColors.sandBase.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(Icons.air, "Coriolis Wind", "${data.windSpeed.toStringAsFixed(0)} km/h"),
                _buildMetricItem(Icons.wb_sunny_outlined, "UV Rating", data.uvIndex.toStringAsFixed(1)),
                _buildMetricItem(Icons.auto_awesome, "Spice Blow", "${data.spiceBlowActivity.toStringAsFixed(0)}%"),
                _buildMetricItem(Icons.compress, "Pressure", "${data.atmosphericPressure.toStringAsFixed(0)} hPa"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: DuneColors.fremenBlue, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
