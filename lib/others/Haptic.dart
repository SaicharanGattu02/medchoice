import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:audioplayers/audioplayers.dart'; // For sound playback

class HapticAndSoundButton extends StatefulWidget {
  @override
  _HapticAndSoundButtonState createState() => _HapticAndSoundButtonState();
}

class _HapticAndSoundButtonState extends State<HapticAndSoundButton> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Method to play the click sound
  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('assets/sounds/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Haptic & Sound Feedback Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Trigger haptic feedback
            HapticFeedback.lightImpact();

            // Play click sound
            await _playSound();
          },
          child: Text('Click Me'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

void main() => runApp(MaterialApp(home: HapticAndSoundButton()));
