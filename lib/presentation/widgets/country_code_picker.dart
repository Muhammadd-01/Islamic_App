import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class CountryCode {
  final String name;
  final String code;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.flag,
  });
}

class CountryCodeDropdown extends StatelessWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onSelected;
  final bool isDark;

  const CountryCodeDropdown({
    super.key,
    required this.selectedCountry,
    required this.onSelected,
    this.isDark = true,
  });

  static const List<CountryCode> countries = [
    CountryCode(name: 'Pakistan', code: '+92', flag: '🇵🇰'),
    CountryCode(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦'),
    CountryCode(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪'),
    CountryCode(name: 'United States', code: '+1', flag: '🇺🇸'),
    CountryCode(name: 'United Kingdom', code: '+44', flag: '🇬🇧'),
    CountryCode(name: 'India', code: '+91', flag: '🇮🇳'),
    CountryCode(name: 'Bangladesh', code: '+880', flag: '🇧🇩'),
    CountryCode(name: 'Turkey', code: '+90', flag: '🇹🇷'),
    CountryCode(name: 'Egypt', code: '+20', flag: '🇪🇬'),
    CountryCode(name: 'Malaysia', code: '+60', flag: '🇲🇾'),
    CountryCode(name: 'Indonesia', code: '+62', flag: '🇮🇩'),
    CountryCode(name: 'Canada', code: '+1', flag: '🇨🇦'),
    CountryCode(name: 'Australia', code: '+61', flag: '🇦🇺'),
    CountryCode(name: 'Qatar', code: '+974', flag: '🇶🇦'),
    CountryCode(name: 'Kuwait', code: '+965', flag: '🇰🇼'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryWhite.withValues(alpha: 0.05)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.softIconGray : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryCode>(
          value: countries.firstWhere(
            (c) =>
                c.code == selectedCountry.code &&
                c.name == selectedCountry.name,
            orElse: () => countries[0],
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          menuMaxHeight: 300, // Makes the menu scrollable
          alignment:
              AlignmentDirectional.bottomStart, // Encourage downward opening
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? AppColors.primaryGold : Colors.grey[700],
          ),
          onChanged: (CountryCode? newValue) {
            if (newValue != null) {
              onSelected(newValue);
            }
          },
          items: countries.map<DropdownMenuItem<CountryCode>>((
            CountryCode country,
          ) {
            return DropdownMenuItem<CountryCode>(
              value: country,
              child: Row(
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    country.code,
                    style: TextStyle(
                      color: isDark ? AppColors.primaryGold : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
