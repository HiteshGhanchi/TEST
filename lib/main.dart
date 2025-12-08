import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:myapp/router.dart';
import 'package:myapp/I10n/app_localizations.dart';
import 'package:myapp/providers/locale_provider.dart';

final Color _primaryGreen = Colors.green.shade700;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const CropicApp(),
    ),
  );
}

class CropicApp extends StatelessWidget {
  const CropicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp.router(
      routerConfig: router,
      title: 'CROPIC',
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
      ],
      theme: ThemeData(
        // Use a standard green primary color theme
        primarySwatch: Colors.green,
        primaryColor: _primaryGreen,
        scaffoldBackgroundColor: Colors.grey.shade100,
        // Define a consistent look for input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}