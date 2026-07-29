import 'weather_data.dart';

class DuneQuote {
  final String text;
  final String author;
  final String source;
  final WeatherType triggerWeather;
  final String loreTag;

  DuneQuote({
    required this.text,
    required this.author,
    required this.source,
    required this.triggerWeather,
    required this.loreTag,
  });
}
