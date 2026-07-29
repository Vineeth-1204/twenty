import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dune_quote.dart';
import '../models/weather_data.dart';
import '../services/quote_service.dart';
import '../theme/dune_colors.dart';

class QuoteBanner extends StatefulWidget {
  final WeatherType weatherType;
  const QuoteBanner({super.key, required this.weatherType});

  @override
  State<QuoteBanner> createState() => _QuoteBannerState();
}

class _QuoteBannerState extends State<QuoteBanner> {
  late DuneQuote _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = QuoteService.getQuoteForWeather(widget.weatherType);
  }

  @override
  void didUpdateWidget(covariant QuoteBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherType != widget.weatherType) {
      setState(() {
        _currentQuote = QuoteService.getQuoteForWeather(widget.weatherType);
      });
    }
  }

  void _nextQuote() {
    final all = QuoteService.getAllQuotes();
    final nextIndex = (all.indexOf(_currentQuote) + 1) % all.length;
    setState(() {
      _currentQuote = all[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DuneColors.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DuneColors.spiceOrange.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: DuneColors.spiceOrange.withOpacity(0.15),
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
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: DuneColors.fremenBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DuneColors.fremenBlue,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "DESERT ORACLE • ${_currentQuote.loreTag.toUpperCase()}",
                    style: GoogleFonts.rajdhani(
                      color: DuneColors.fremenBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: DuneColors.duneGold, size: 20),
                tooltip: "Cycle Quote",
                onPressed: _nextQuote,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "\"${_currentQuote.text}\"",
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "— ${_currentQuote.author}",
                style: GoogleFonts.montserrat(
                  color: DuneColors.spiceOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DuneColors.sandBase,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DuneColors.glassBorder),
                ),
                child: Text(
                  _currentQuote.source,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
