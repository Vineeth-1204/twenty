import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../services/sound_service.dart';
import '../theme/dune_colors.dart';
import '../widgets/sand_background.dart';
import '../widgets/quote_banner.dart';
import '../widgets/weather_hero_card.dart';
import '../widgets/time_sun_orbit.dart';
import '../widgets/monsoon_tracker_card.dart';
import '../widgets/dune_calendar_widget.dart';
import '../widgets/stillsuit_calculator.dart';
import '../widgets/sandworm_radar.dart';
import '../widgets/location_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  LocationOption _currentLocation = WeatherService.locations.first;
  late Future<WeatherData> _weatherFuture;
  bool _soundOn = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  void _fetchWeatherData() {
    setState(() {
      _weatherFuture = WeatherService.fetchWeather(_currentLocation);
    });
  }

  void _onLocationSelected(LocationOption loc) {
    setState(() {
      _currentLocation = loc;
      _fetchWeatherData();
    });
  }

  void _toggleAudio() {
    setState(() {
      SoundService.toggleSound();
      _soundOn = SoundService.isPlaying;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: DuneColors.cardBackground,
        content: Text(
          _soundOn
              ? "🔊 Playing Ambient Track: ${SoundService.activeTrack}"
              : "🔇 Ambient Audio Muted",
          style: GoogleFonts.rajdhani(color: DuneColors.duneGold, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DuneColors.darkBackground.withOpacity(0.9),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.wb_sunny_outlined, color: DuneColors.spiceOrange, size: 24),
            const SizedBox(width: 10),
            Text(
              "D U N E",
              style: GoogleFonts.cinzel(
                color: DuneColors.duneGold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "WEATHER & ORACLE",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _soundOn ? Icons.volume_up : Icons.volume_off,
              color: _soundOn ? DuneColors.fremenBlue : Colors.white54,
            ),
            tooltip: "Toggle Desert Ambience",
            onPressed: _toggleAudio,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: DuneColors.spiceOrange),
            tooltip: "Refresh Weather Telemetry",
            onPressed: _fetchWeatherData,
          ),
        ],
      ),
      body: SandBackground(
        child: SafeArea(
          child: Column(
            children: [
              LocationSelector(
                selectedLocation: _currentLocation,
                onLocationChanged: _onLocationSelected,
              ),
              Expanded(
                child: FutureBuilder<WeatherData>(
                  future: _weatherFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: DuneColors.spiceOrange),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Text(
                          "Telemetry Error. Check Sietch Transmitters.",
                          style: GoogleFonts.rajdhani(color: DuneColors.stormRed, fontSize: 16),
                        ),
                      );
                    }

                    final weather = snapshot.data!;

                    return IndexedStack(
                      index: _currentTabIndex,
                      children: [
                        // Tab 0: Weather Overview Dashboard
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            children: [
                              QuoteBanner(weatherType: weather.condition),
                              WeatherHeroCard(data: weather),
                              TimeSunOrbit(weather: weather),
                              MonsoonTrackerCard(weather: weather),
                            ],
                          ),
                        ),

                        // Tab 1: Dune Calendar Feature
                        const SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 24),
                          child: DuneCalendarWidget(),
                        ),

                        // Tab 2: Monsoon & Moisture Detailed Intelligence
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            children: [
                              MonsoonTrackerCard(weather: weather),
                              StillsuitCalculator(
                                ambientTemp: weather.temperature,
                                humidity: weather.humidity,
                              ),
                            ],
                          ),
                        ),

                        // Tab 3: Fremen Addons (Stillsuit & Sandworm Radar)
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            children: [
                              StillsuitCalculator(
                                ambientTemp: weather.temperature,
                                humidity: weather.humidity,
                              ),
                              SandwormRadar(threatLevel: weather.sandwormThreatLevel),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: DuneColors.darkBackground,
          border: Border(top: BorderSide(color: DuneColors.glassBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: DuneColors.spiceOrange,
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.rajdhani(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny),
              label: "Telemetry",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Calendar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop),
              label: "Monsoon",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield),
              label: "Addons",
            ),
          ],
        ),
      ),
    );
  }
}
