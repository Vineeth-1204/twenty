import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/dune_colors.dart';

class StillsuitCalculator extends StatefulWidget {
  final double ambientTemp;
  final double humidity;
  const StillsuitCalculator({
    super.key,
    required this.ambientTemp,
    required this.humidity,
  });

  @override
  State<StillsuitCalculator> createState() => _StillsuitCalculatorState();
}

class _StillsuitCalculatorState extends State<StillsuitCalculator> {
  double _activityLevel = 2.0; // 1 = Resting in Sietch, 2 = Dune Sandwalking, 3 = Worm Riding / Battle
  double _stillsuitQuality = 95.0; // Efficiency rating %

  @override
  Widget build(BuildContext context) {
    // Math formulas for Fremen Moisture Reclamation
    double sweatRateLitersPerHour = 0.5 + (_activityLevel * 0.4) + ((widget.ambientTemp - 30.0).clamp(0, 30) * 0.03);
    double reclaimedLitersPerHour = sweatRateLitersPerHour * (_stillsuitQuality / 100.0);
    double waterLostLitersPerHour = sweatRateLitersPerHour - reclaimedLitersPerHour;
    double maxSurvivalHours = (2.0 / (waterLostLitersPerHour + 0.05)).clamp(1.0, 96.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DuneColors.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DuneColors.fremenBlue.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: DuneColors.fremenBlue.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: DuneColors.fremenBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "FREMEN STILLSUIT RECLAMATION",
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
                  color: DuneColors.fremenBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${_stillsuitQuality.toStringAsFixed(0)}% EFFICIENCY",
                  style: GoogleFonts.rajdhani(
                    color: DuneColors.fremenBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Activity Level Slider
          Text(
            "ACTIVITY INTENSITY: ${_getActivityLabel(_activityLevel)}",
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12),
          ),
          Slider(
            value: _activityLevel,
            min: 1.0,
            max: 3.0,
            divisions: 2,
            activeColor: DuneColors.spiceOrange,
            inactiveColor: DuneColors.sandBase,
            onChanged: (val) {
              setState(() {
                _activityLevel = val;
              });
            },
          ),

          // Suit Quality Slider
          Text(
            "STILLSUIT SEAL INTEGRITY: ${_stillsuitQuality.toStringAsFixed(0)}%",
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12),
          ),
          Slider(
            value: _stillsuitQuality,
            min: 60.0,
            max: 99.0,
            divisions: 39,
            activeColor: DuneColors.fremenBlue,
            inactiveColor: DuneColors.sandBase,
            onChanged: (val) {
              setState(() {
                _stillsuitQuality = val;
              });
            },
          ),

          const SizedBox(height: 10),

          // Results display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DuneColors.sandBase.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _calcMetric("Sweat Loss", "${sweatRateLitersPerHour.toStringAsFixed(2)} L/h", Colors.white),
                _calcMetric("Reclaimed", "${reclaimedLitersPerHour.toStringAsFixed(2)} L/h", DuneColors.fremenBlue),
                _calcMetric("Net Loss", "${waterLostLitersPerHour.toStringAsFixed(2)} L/h", DuneColors.spiceOrange),
                _calcMetric("Survival Time", "${maxSurvivalHours.toStringAsFixed(0)} hrs", DuneColors.duneGold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityLabel(double level) {
    if (level <= 1.0) return "Sietch Resting";
    if (level <= 2.0) return "Sandwalking";
    return "Worm Riding / Combat";
  }

  Widget _calcMetric(String title, String val, Color color) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.rajdhani(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(title, style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 9)),
      ],
    );
  }
}
