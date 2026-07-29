import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/calendar_day.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../theme/dune_colors.dart';

class DuneCalendarWidget extends StatefulWidget {
  const DuneCalendarWidget({super.key});

  @override
  State<DuneCalendarWidget> createState() => _DuneCalendarWidgetState();
}

class _DuneCalendarWidgetState extends State<DuneCalendarWidget> {
  DateTime _displayedMonth = DateTime.now();
  late List<CalendarDay> _monthDays;

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  void _loadCalendar() {
    setState(() {
      _monthDays = WeatherService.getDuneCalendarForMonth(_displayedMonth.year, _displayedMonth.month);
    });
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
      _loadCalendar();
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
      _loadCalendar();
    });
  }

  IconData _getIconForWeather(WeatherType type) {
    switch (type) {
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

  void _showDayDetails(CalendarDay day) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: DuneColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: DuneColors.spiceOrange, width: 1.5),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMMM yyyy').format(day.date).toUpperCase(),
                style: GoogleFonts.cinzel(
                  color: DuneColors.duneGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(_getIconForWeather(day.expectedWeather), color: DuneColors.spiceOrange),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DuneColors.sandBase,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _detailStat("Max Temp", "${day.maxTemp.toStringAsFixed(0)}°C"),
                      _detailStat("Min Temp", "${day.minTemp.toStringAsFixed(0)}°C"),
                      _detailStat("Humidity", "${day.humidity.toStringAsFixed(0)}%"),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Threat & Monsoon status
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: day.isStormWarning
                              ? DuneColors.stormRed.withOpacity(0.2)
                              : DuneColors.sandBase,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: day.isStormWarning ? DuneColors.stormRed : DuneColors.glassBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Worm Sign Risk",
                              style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 10),
                            ),
                            Text(
                              "${day.wormSignRisk.toStringAsFixed(1)} / 10",
                              style: GoogleFonts.rajdhani(
                                color: day.isStormWarning ? DuneColors.stormRed : DuneColors.duneGold,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: day.isMonsoonHighlight
                              ? DuneColors.fremenBlue.withOpacity(0.2)
                              : DuneColors.sandBase,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: day.isMonsoonHighlight ? DuneColors.fremenBlue : DuneColors.glassBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Monsoon Chance",
                              style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 10),
                            ),
                            Text(
                              "${day.monsoonChance.toStringAsFixed(0)}%",
                              style: GoogleFonts.rajdhani(
                                color: day.isMonsoonHighlight ? DuneColors.fremenBlue : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Text(
                  "ORACLE QUOTE OF THE DAY",
                  style: GoogleFonts.rajdhani(
                    color: DuneColors.fremenBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\"${day.quoteOfDay.text}\"",
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  "— ${day.quoteOfDay.author}",
                  style: GoogleFonts.montserrat(
                    color: DuneColors.spiceOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),
                Text(
                  "FREMEN ADVISORY",
                  style: GoogleFonts.rajdhani(
                    color: DuneColors.duneGold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.fremenTip,
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "CLOSE REGISTRY",
                style: GoogleFonts.rajdhani(
                  color: DuneColors.spiceOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailStat(String label, String val) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 9)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthHeader = DateFormat('MMMM yyyy').format(_displayedMonth).toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuneColors.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DuneColors.glassBorder),
      ),
      child: Column(
        children: [
          // Header Month Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: DuneColors.spiceOrange, size: 18),
                onPressed: _previousMonth,
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: DuneColors.duneGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "ARRAKIS CALENDAR • $monthHeader",
                    style: GoogleFonts.cinzel(
                      color: DuneColors.duneGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: DuneColors.spiceOrange, size: 18),
                onPressed: _nextMonth,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Days of week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                .map((d) => SizedBox(
                      width: 38,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          color: DuneColors.fremenBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _monthDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.95,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final day = _monthDays[index];
              final isToday = day.date.day == DateTime.now().day &&
                  day.date.month == DateTime.now().month &&
                  day.date.year == DateTime.now().year;

              Color tileBorder = DuneColors.glassBorder;
              Color tileBg = DuneColors.sandBase.withOpacity(0.5);

              if (day.isStormWarning) {
                tileBorder = DuneColors.stormRed.withOpacity(0.6);
                tileBg = DuneColors.stormRed.withOpacity(0.15);
              } else if (day.isMonsoonHighlight) {
                tileBorder = DuneColors.fremenBlue.withOpacity(0.6);
                tileBg = DuneColors.fremenBlue.withOpacity(0.15);
              }

              if (isToday) {
                tileBorder = DuneColors.spiceOrange;
              }

              return InkWell(
                onTap: () => _showDayDetails(day),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: tileBorder, width: isToday ? 2.0 : 1.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${day.date.day}",
                        style: GoogleFonts.rajdhani(
                          color: isToday ? DuneColors.spiceOrange : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        _getIconForWeather(day.expectedWeather),
                        size: 14,
                        color: day.isMonsoonHighlight
                            ? DuneColors.fremenBlue
                            : day.isStormWarning
                                ? DuneColors.stormRed
                                : DuneColors.duneGold,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
