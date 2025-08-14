import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/brand_colors.dart';

void main() {
  runApp(const AtmosApp());
}

class AtmosApp extends StatelessWidget {
  const AtmosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: BrandColors.navy,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'ATMOS Presença',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        // Botões preenchidos (usados no app)
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            // padrão global (pode trocar por magenta/red/yellow)
            backgroundColor: BrandColors.magenta,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: BrandColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
