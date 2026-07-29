import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import '../theme/dune_colors.dart';

class TimeSunOrbit extends StatefulWidget {
  final WeatherData weather;
  const TimeSunOrbit({super.key, required this.weather});

  @override
  State<TimeSunOrbit> createState() => _TimeSunOrbitState();
}

class _TimeSunOrbitState extends State<TimeSunOrbit> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(_currentTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuneColors.cardBackground.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DuneColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: DuneColors.spiceOrange, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "CHRONOMETER",
                        style: GoogleFonts.rajdhani(
                          color: DuneColors.spiceOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: GoogleFonts.montserrat(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              Container(
                width: 1,
                height: 50,
                color: DuneColors.glassBorder,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        "CELESTIAL MOONS",
                        style: GoogleFonts.rajdhani(
                          color: DuneColors.fremenBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.brightness_3, color: DuneColors.fremenBlue, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.weather.moonPhase,
                    style: GoogleFonts.rajdhani(
                      color: DuneColors.duneGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.weather.solarPosition,
                    style: GoogleFonts.montserrat(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
