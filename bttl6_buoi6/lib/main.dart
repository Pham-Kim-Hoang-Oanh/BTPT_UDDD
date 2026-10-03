import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const SimpleAudioPlayer());
}

class SimpleAudioPlayer extends StatelessWidget {
  const SimpleAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Audio Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AudioPlayerHome(),
    );
  }
}

class AudioPlayerHome extends StatefulWidget {
  const AudioPlayerHome({super.key});

  @override
  State<AudioPlayerHome> createState() =>
      _AudioPlayerHomeState();
}

class _AudioPlayerHomeState
    extends State<AudioPlayerHome> {
  // Đối tượng phát nhạc
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Vị trí bài hát hiện tại
  int _currentSongIndex = 0;

  // Trạng thái đang phát
  bool _isPlaying = false;

  // Danh sách file audio
  final List<String> _songs = [
    'assets/audios/sample1.mp3',
    'assets/audios/sample2.mp3',
    'assets/audios/sample3.mp3',
  ];

  // Tên bài hát hiển thị
  final List<String> _songTitles = [
    'Sample 1',
    'Sample 2',
    'Sample 3',
  ];

  @override
  void initState() {
    super.initState();

    // Theo dõi trạng thái phát nhạc
    _audioPlayer.onPlayerStateChanged.listen(
      (PlayerState state) {
        if (!mounted) return;

        setState(() {
          _isPlaying =
              state == PlayerState.playing;
        });
      },
    );

    // Khi bài hát kết thúc
    _audioPlayer.onPlayerComplete.listen((event) {
      _nextSong();
    });
  }

  // ==============================
  // PLAY
  // ==============================

  Future<void> _playSong() async {
    await _audioPlayer.play(
      AssetSource(
        _songs[_currentSongIndex]
            .replaceFirst('assets/', ''),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isPlaying = true;
    });
  }

  // ==============================
  // PAUSE
  // ==============================

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });
  }

  // ==============================
  // STOP
  // ==============================

  Future<void> _stopSong() async {
    await _audioPlayer.stop();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });
  }

  // ==============================
  // NEXT
  // ==============================

  Future<void> _nextSong() async {
    if (_currentSongIndex <
        _songs.length - 1) {
      _currentSongIndex++;
    } else {
      _currentSongIndex = 0;
    }

    await _audioPlayer.stop();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });

    await _playSong();
  }

  // ==============================
  // PREVIOUS
  // ==============================

  Future<void> _previousSong() async {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
    } else {
      _currentSongIndex =
          _songs.length - 1;
    }

    await _audioPlayer.stop();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });

    await _playSong();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Simple Audio Player',
        ),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            // ==========================
            // ICON MUSIC
            // ==========================

            const CircleAvatar(
              radius: 70,
              child: Icon(
                Icons.music_note,
                size: 70,
              ),
            ),

            const SizedBox(height: 30),

            // ==========================
            // TÊN BÀI HÁT
            // ==========================

            Text(
              _songTitles[
                  _currentSongIndex],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Bài ${_currentSongIndex + 1} / ${_songs.length}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // ==========================
            // CÁC NÚT ĐIỀU KHIỂN
            // ==========================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                // Previous
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    size: 45,
                  ),
                  onPressed: _previousSong,
                ),

                const SizedBox(width: 10),

                // Play / Pause
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    size: 65,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _pauseSong();
                    } else {
                      _playSong();
                    }
                  },
                ),

                const SizedBox(width: 10),

                // Stop
                IconButton(
                  icon: const Icon(
                    Icons.stop_circle,
                    size: 55,
                  ),
                  onPressed: _stopSong,
                ),

                const SizedBox(width: 10),

                // Next
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    size: 45,
                  ),
                  onPressed: _nextSong,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ==========================
            // HIỂN THỊ TRẠNG THÁI
            // ==========================

            Text(
              _isPlaying
                  ? 'Đang phát nhạc'
                  : 'Đang tạm dừng',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}