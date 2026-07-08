import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/brand_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale padrão
  Intl.defaultLocale = 'pt_BR';

  // Carrega dados de data para pt_BR (e pt como fallback)
  await initializeDateFormatting('pt_BR', null);
  await initializeDateFormatting('pt', null);

  await Supabase.initialize(
    url: 'https://lbxipyezqhjlivvpojjn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxieGlweWV6cWhqbGl2dnBvampuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM1MTgxNDgsImV4cCI6MjA5OTA5NDE0OH0.jjZdg3tFC1qoez310ElbLKC6pWErlfHQjNhrS_XDSmw',
  );

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

      // Habilita strings/datas do Material/Cupertino em pt-BR
      localizationsDelegates: const [
        // Material/Cupertino/Widgets localizations
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],

      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: BrandColors.background,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: BrandColors.magenta,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: BrandColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: BrandColors.magenta, width: 1.4),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          color: BrandColors.card,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: BrandColors.divider),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: BrandColors.divider,
          thickness: 1,
          space: 1,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: BrandColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final hasSession = auth.currentSession != null;
        return hasSession ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
