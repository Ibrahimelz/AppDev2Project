import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Employeetutorial extends StatefulWidget {
  const Employeetutorial({super.key});

  @override
  State<Employeetutorial> createState() => _EmployeetutorialState();
}

class _EmployeetutorialState extends State<Employeetutorial> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        'https://youtu.be/gq2U84Wt9co?si=Ve9i72-AdQvUPitJ', // Replace with your actual link
      )!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Titan Fitness",
          style: TextStyle(fontFamily: 'MyFont'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Please watch this video to familiarize yourself with BeastFit",
                style: TextStyle(fontFamily: 'MyFont', fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
