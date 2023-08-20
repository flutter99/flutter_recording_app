import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _hasRecording = false;
  bool _isRecordingInitialized = false;
  String? _path;
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializedRecorder();
  }

  /// recorder initialized
  _initializedRecorder() async {
    try {
      await _recorder!.openRecorder();
      await _player!.openPlayer();
      await _player!.setVolume(1.0);
      setState(() {
        _isRecordingInitialized = true;
      });
    } catch (e) {
      print("Error Happen : $e");
    }
  }

  /// start recording
  Future<void> _startRecording() async {
    if (!_isRecordingInitialized) {
      print('Recorder not initialized');
      return;
    }

    final status = await Permission.microphone.request();

    if (status.isGranted) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/myAudio.aac';
        await _recorder!.startRecorder(toFile: path);
        setState(() {
          _isRecording = true;
          _path = path;
        });
      } catch (e) {
        print('Error on Start Recording $e');
      }
    } else {
      print('Permission not Granted');
    }
  }

  /// play recording
  Future<void> _playRecording() async {
    if (_path != null) {
      await _player!.startPlayer(
        fromURI: _path!,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );

      setState(() {
        _isPlaying = true;
      });
    }
  }

  /// stop recording
  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _hasRecording = true;
    });
  }

  /// pause the player
  Future<void> _pausePlayer() async {
    await _player!.pausePlayer();
    setState(() {
      _isPaused = true;
    });
  }

  /// resume player
  Future<void> _resumePlayer() async {
    await _player!.resumePlayer();
    setState(() {
      _isPaused = false;
    });
  }

  /// stop player
  Future<void> _stopPlayer() async {
    await _player!.stopPlayer();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _recorder!.closeRecorder();
    _player!.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Mini Recording App',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording)
              ElevatedButton(
                onPressed: _stopRecording,
                child: const Text('Stop Recording'),
              )
            else
              ElevatedButton(
                onPressed: _startRecording,
                child: const Text('Start Recording'),
              ),
            if (_hasRecording && !_isPlaying)
              ElevatedButton(
                onPressed: _playRecording,
                child: const Text('Play Recording'),
              ),
            if (_isPlaying && !_isPaused)
              ElevatedButton(
                onPressed: _pausePlayer,
                child: const Text('Pause'),
              ),
            if (_isPlaying && _isPaused)
              ElevatedButton(
                onPressed: _resumePlayer,
                child: const Text('Resume'),
              ),
            if (_isPlaying)
              ElevatedButton(
                onPressed: _stopPlayer,
                child: const Text('Stop Player'),
              ),
          ],
        ),
      ),
    );
  }
}
