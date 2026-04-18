import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breast_cancer_app/core/app_settings.dart';

void main() {
  // Reset to light/English before each test to ensure isolation.
  setUp(() {
    AppSettings.instance.setDarkMode(false);
    AppSettings.instance.setLanguage('English');
  });

  group('AppSettings – singleton', () {
    test('instance returns the same object every call', () {
      expect(identical(AppSettings.instance, AppSettings.instance), isTrue);
    });
  });

  group('AppSettings – theme mode', () {
    test('default theme is light', () {
      expect(AppSettings.instance.themeMode.value, ThemeMode.light);
    });

    test('isDarkMode returns false when light', () {
      AppSettings.instance.setDarkMode(false);
      expect(AppSettings.instance.isDarkMode, isFalse);
    });

    test('setDarkMode(true) switches to dark', () {
      AppSettings.instance.setDarkMode(true);
      expect(AppSettings.instance.themeMode.value, ThemeMode.dark);
    });

    test('isDarkMode returns true after setDarkMode(true)', () {
      AppSettings.instance.setDarkMode(true);
      expect(AppSettings.instance.isDarkMode, isTrue);
    });

    test('setDarkMode(false) switches back to light', () {
      AppSettings.instance.setDarkMode(true);
      AppSettings.instance.setDarkMode(false);
      expect(AppSettings.instance.themeMode.value, ThemeMode.light);
    });

    test('themeMode notifier fires listeners on change', () {
      var listenerCalled = false;
      AppSettings.instance.themeMode.addListener(() => listenerCalled = true);

      AppSettings.instance.setDarkMode(true);

      expect(listenerCalled, isTrue);
      AppSettings.instance.themeMode.removeListener(() {});
    });

    test('toggling dark mode twice restores original state', () {
      AppSettings.instance.setDarkMode(true);
      AppSettings.instance.setDarkMode(false);
      expect(AppSettings.instance.isDarkMode, isFalse);
    });
  });

  group('AppSettings – language', () {
    test('default language is English', () {
      expect(AppSettings.instance.language.value, 'English');
    });

    test('setLanguage updates language notifier', () {
      AppSettings.instance.setLanguage('Arabic');
      expect(AppSettings.instance.language.value, 'Arabic');
    });

    test('setLanguage to French updates correctly', () {
      AppSettings.instance.setLanguage('French');
      expect(AppSettings.instance.language.value, 'French');
    });

    test('language notifier fires listeners on change', () {
      var listenerCalled = false;
      AppSettings.instance.language.addListener(() => listenerCalled = true);

      AppSettings.instance.setLanguage('Arabic');

      expect(listenerCalled, isTrue);
    });

    test('switching back to English works', () {
      AppSettings.instance.setLanguage('Arabic');
      AppSettings.instance.setLanguage('English');
      expect(AppSettings.instance.language.value, 'English');
    });
  });

  group('AppSettings – state independence', () {
    test('theme and language are independent', () {
      AppSettings.instance.setDarkMode(true);
      AppSettings.instance.setLanguage('Arabic');

      expect(AppSettings.instance.isDarkMode, isTrue);
      expect(AppSettings.instance.language.value, 'Arabic');
    });
  });
}
