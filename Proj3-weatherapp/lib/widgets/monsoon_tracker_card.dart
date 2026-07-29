import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_data.dart';
import '../theme/dune_colors.dart';

class MonsoonTrackerCard extends StatelessWidget {
  final WeatherData weather;
  const MonsoonTrackerCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final bool isMonsoonActive = weather.monsoonSurgeIndex > 50.0 || weather.humidity > 40.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DuneColors.cardBackground.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMonsoonActive ? DuneColors.fremenBlue : DuneColors.glassBorder,
          width: isMonsoonActive ? 1.5 : 1.0,
        ),
        boxShadow: isMonsoonActive
            ? [
                BoxShadow(
                  color: DuneColors.fremenBlue.withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop, color: DuneColors.fremenBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "MONSOON & MOISTURE INTELLIGENCE",
                    style: GoogleFonts.rajdhani(
                      color: DuneColors.fremenBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isMonsoonActive
                      ? DuneColors.fremenBlue.withOpacity(0.2)
                      : DuneColors.sandBase,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isMonsoonActive ? DuneColors.fremenBlue : DuneColors.glassBorder,
                  ),
                ),
                child: Text(
                  isMonsoonActive ? "MONSOON SURGE ACTIVE" : "ARRAKIS DRY CYCLE",
                  style: GoogleFonts.rajdhani(
                    color: isMonsoonActive ? DuneColors.fremenBlue : Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Gauge / Progress indicator for Monsoon Index
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: weather.monsoonSurgeIndex / 100.0,
                            strokeWidth: 8,
                            backgroundColor: DuneColors.sandBase,
                            valueColor: const AlwaysStoppedAnimation<Color>(DuneColors.fremenBlue),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${weather.monsoonSurgeIndex.toStringAsFixed(0)}%",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "SURGE",
                              style: GoogleFonts.montserrat(
                                color: Colors.white54,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Metrics detail
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow("Atmospheric Humidity", "${weather.humidity.toStringAsFixed(1)}%"),
                    const SizedBox(height: 6),
                    _buildStatRow("Windtrap Yield", "${weather.windtrapWaterYield.toStringAsFixed(1)} L/hr"),
                    const SizedBox(height: 6),
                    _buildStatRow("Caladan Front Shift", isMonsoonActive ? "High Potential" : "Low"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Fremen Water Advisory
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DuneColors.sandBase.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DuneColors.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: DuneColors.duneGold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather.fremenAdvisory,
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        Text(
          val,
          style: GoogleFonts.rajdhani(
            color: DuneColors.duneGold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
