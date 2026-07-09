import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTextScale { small, medium, large }

extension AppTextScaleValue on AppTextScale {
  double get scaleFactor {
    switch (this) {
      case AppTextScale.small:
        return 0.9;
      case AppTextScale.medium:
        return 1.0;
      case AppTextScale.large:
        return 1.15;
    }
  }

  String get label {
    switch (this) {
      case AppTextScale.small:
        return 'Small';
      case AppTextScale.medium:
        return 'Medium';
      case AppTextScale.large:
        return 'Large';
    }
  }
}

class TextScaleNotifier extends Notifier<AppTextScale> {
  @override
  AppTextScale build() => AppTextScale.medium;

  void setScale(AppTextScale scale) {
    state = scale;
  }
}

final textScaleProvider = NotifierProvider<TextScaleNotifier, AppTextScale>(
  TextScaleNotifier.new,
);
