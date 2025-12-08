import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/locale_provider.dart';
import 'package:myapp/I10n/app_localizations.dart';

final Color _primaryGreen = Colors.green.shade700;

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  // Logic to determine initial selection could be added here
  
  void _updateLanguage(String languageCode) {
    Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale(languageCode));
  }

  Widget _buildLanguageOption(String language, String regional, String code) {
    final currentLocale = Provider.of<LocaleProvider>(context).locale;
    final bool isSelected = currentLocale.languageCode == code;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _updateLanguage(code);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: _primaryGreen, width: 2)
                : Border.all(color: Colors.grey.shade200),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _primaryGreen.withAlpha(25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: ListTile(
            title: Text(
              '$language / $regional',
              style: TextStyle(
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected
                    ? _primaryGreen
                    : Colors.black,
              ),
            ),
            trailing: isSelected
              ? Icon(Icons.radio_button_checked, color: _primaryGreen)
              : const Icon(Icons.radio_button_unchecked),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.green,
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: const NetworkImage(
                'https://images.unsplash.com/photo-1542282332-1b112310350d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              ), 
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              fadeInDuration: const Duration(milliseconds: 300),
              imageErrorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('language_select_title'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('language_select_subtitle'),
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.translate('search_language'),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Language Options
                  Expanded(
                    child: ListView(
                      children: [
                        _buildLanguageOption('English', 'English', 'en'),
                        _buildLanguageOption('Hindi', 'हिन्दी', 'hi'),
                        // Add more as needed, ensuring they are in AppLocalizations
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        l10n.translate('continue_btn'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}