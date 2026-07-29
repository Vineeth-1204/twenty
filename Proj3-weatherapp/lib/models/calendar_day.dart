import 'weather_data.dart';
import 'dune_quote.dart';

class CalendarDay {
  final DateTime date;
  final WeatherType expectedWeather;
  final double maxTemp;
  final double minTemp;
  final double humidity;
  final double wormSignRisk; // 0 - 10
  final double monsoonChance; // 0 - 100%
  final String moonPhase;
  final DuneQuote quoteOfDay;
  final String fremenTip;
  final bool isMonsoonHighlight;
  final bool isStormWarning;

  CalendarDay({
    required this.date,
    required this.expectedWeather,
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
    required this.wormSignRisk,
    required this.monsoonChance,
    required this.moonPhase,
    required this.quoteOfDay,
    required this.fremenTip,
    this.isMonsoonHighlight = false,
    this.isStormWarning = false,
  });
}
