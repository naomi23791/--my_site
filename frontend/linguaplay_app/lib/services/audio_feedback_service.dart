import 'package:flutter/services.dart';

class AudioFeedbackService {
  AudioFeedbackService._internal();
  static final AudioFeedbackService instance = AudioFeedbackService._internal();

  Future<void> playCorrectSound() async {
    await SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  Future<void> playErrorSound() async {
    await SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();
  }

  Future<void> playAmbientCue() async {
    await SystemSound.play(SystemSoundType.click);
  }
}

