import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _init();
  }

  void _init() {
    final box = Hive.box(AppConstants.settingsBox);
    state = box.get(AppConstants.onboardingCompleteKey, defaultValue: false);
  }

  Future<void> completeOnboarding() async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(AppConstants.onboardingCompleteKey, true);
    state = true;
  }
}
