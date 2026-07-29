import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';
import '../theme/dune_colors.dart';

class LocationSelector extends StatelessWidget {
  final LocationOption selectedLocation;
  final ValueChanged<LocationOption> onLocationChanged;

  const LocationSelector({
    super.key,
    required this.selectedLocation,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: WeatherService.locations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final loc = WeatherService.locations[index];
          final isSelected = loc.name == selectedLocation.name;

          return InkWell(
            onTap: () => onLocationChanged(loc),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (loc.isArrakisTerritory ? DuneColors.spiceOrange : DuneColors.fremenBlue)
                    : DuneColors.sandBase.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : (loc.isArrakisTerritory ? DuneColors.glassBorder : DuneColors.fremenBlue.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    loc.isArrakisTerritory ? Icons.terrain : Icons.public,
                    color: isSelected ? Colors.black : Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    loc.name,
                    style: GoogleFonts.rajdhani(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
