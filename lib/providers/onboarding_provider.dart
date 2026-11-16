import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController controller = PageController();
  int _page = 0;
  bool _seen = false;

  int get page => _page;
  bool get seen => _seen;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _seen = prefs.getBool('onboardingSeen') ?? false;
    notifyListeners();
  }

  void onPageChanged(int i) {
    _page = i;
    notifyListeners();
  }

  void next() => controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  Future<void> finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);
    _seen = true;
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}