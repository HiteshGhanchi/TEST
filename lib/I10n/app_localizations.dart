import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'language_select_title': 'Select Your Language',
      'language_select_subtitle': 'Choose the language you are most comfortable with.',
      'continue_btn': 'Continue',
      'search_language': 'Search for a language',
      
      'welcome_cropic': 'Welcome to Cropic',
      'phone_label': 'Phone Number (+91...)',
      'get_otp': 'Get OTP',
      'enter_otp_label': 'Enter OTP',
      'verify_login': 'Verify & Login',
      'change_phone': 'Change Phone Number',
      'invalid_phone': 'Enter valid phone number',
      'otp_sent': 'OTP Sent! Check your device.',
      
      'verify_otp_title': 'Verify OTP',
      'enter_otp_sent_to': 'Enter the OTP sent to',
      'verify_btn': 'Verify',
      
      'welcome_back': 'Welcome back,',
      'my_farms': 'My Farms',
      'add_new': 'Add New',
      'smart_farming': 'Smart Farming',
      'todays_weather': "Today's Weather",
      'sunny': 'Sunny',
      'no_farms': "No farms yet. Click 'Add New' to start.",
      'advisory': 'Advisory',
      'ask_agribot': 'Ask AgriBot',
      'community': 'Community',
      'discussion': 'Discussion',
      'finance': 'Finance',
      'ledger': 'Ledger & Sales',
      'profile': 'Profile',
      'bank_land': 'Bank & Land',
      'active': 'Active',
    },
    'hi': {
      'language_select_title': 'अपनी भाषा चुनें',
      'language_select_subtitle': 'वह भाषा चुनें जिसमें आप सबसे अधिक सहज हों।',
      'continue_btn': 'आगे बढ़ें',
      'search_language': 'भाषा खोजें',
      
      'welcome_cropic': 'क्रॉपिक में आपका स्वागत है',
      'phone_label': 'फ़ोन नंबर (+91...)',
      'get_otp': 'ओटीपी प्राप्त करें',
      'enter_otp_label': 'ओटीपी दर्ज करें',
      'verify_login': 'सत्यापित करें और लॉगिन करें',
      'change_phone': 'फ़ोन नंबर बदलें',
      'invalid_phone': 'मान्य फ़ोन नंबर दर्ज करें',
      'otp_sent': 'ओटीपी भेजा गया! अपना डिवाइस चेक करें।',
      
      'verify_otp_title': 'ओटीपी सत्यापित करें',
      'enter_otp_sent_to': 'भेजा गया ओटीपी दर्ज करें',
      'verify_btn': 'सत्यापित करें',
      
      'welcome_back': 'वापसी पर स्वागत है,',
      'my_farms': 'मेरे खेत',
      'add_new': 'नया जोड़ें',
      'smart_farming': 'स्मार्ट खेती',
      'todays_weather': 'आज का मौसम',
      'sunny': 'धूप',
      'no_farms': "अभी तक कोई खेत नहीं। शुरू करने के लिए 'नया जोड़ें' पर क्लिक करें।",
      'advisory': 'सलाहकार',
      'ask_agribot': 'एग्रीबॉट से पूछें',
      'community': 'समुदाय',
      'discussion': 'चर्चा',
      'finance': 'वित्त',
      'ledger': 'खाता और बिक्री',
      'profile': 'प्रोफ़ाइल',
      'bank_land': 'बैंक और ज़मीन',
      'active': 'सक्रिय',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}