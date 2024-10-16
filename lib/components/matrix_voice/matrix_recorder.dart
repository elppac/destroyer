import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:http/http.dart' as http;

/*
 * This is an example showing how to record to a Dart Stream.
 * It writes all the recorded data from a Stream to a File, which is completely stupid:
 * if an App wants to record something to a File, it must not use Streams.
 *
 * The real interest of recording to a Stream is for example to feed a
 * Speech-to-Text engine, or for processing the Live data in Dart in real time.
 *
 */

///
typedef _Fn = void Function();

/* This does not work. on Android we must have the Manifest.permission.CAPTURE_AUDIO_OUTPUT permission.
 * But this permission is _is reserved for use by system components and is not available to third-party applications._
 * Pleaser look to [this](https://developer.android.com/reference/android/media/MediaRecorder.AudioSource#VOICE_UPLINK)
 *
 * I think that the problem is because it is illegal to record a communication in many countries.
 * Probably this stands also on iOS.
 * Actually I am unable to record DOWNLINK on my Xiaomi Chinese phone.
 *
 */
//const theSource = AudioSource.voiceUpLink;
//const theSource = AudioSource.voiceDownlink;

const theSource = AudioSource.microphone;

class MatrixRecorder extends StatefulWidget {
  const MatrixRecorder(
      {super.key,
      this.onChanged,
      this.initialValue,
      this.minDuration = 3.0,
      this.maxDuration = 15.0});

  final ValueChanged<dynamic>? onChanged;
  final List<dynamic>? initialValue;
  // final bool multiple;
  final double minDuration;
  final double maxDuration;

  @override
  State<MatrixRecorder> createState() => _MatrixRecorderState();
}

class _MatrixRecorderState extends State<MatrixRecorder> {
  Codec _codec = Codec.aacMP4;
  String _recordPath = 'voice.mp4';
  FlutterSoundPlayer? _player = FlutterSoundPlayer();
  FlutterSoundRecorder? _recorder = FlutterSoundRecorder();
  bool _playerIsReady = false;
  bool _recorderIsReady = false;
  bool _recordingCompleted = false;
  StreamSubscription? _recorderSubscription;
  double _voiceDuration = -1.0;
  StreamSubscription? _playerSubscription;
  double _voicePlayProgress = 0;
  late List<dynamic>? data = null;

  @override
  void initState() {
    data = widget.initialValue ?? [];
    _player!.openPlayer().then((value) {
      setState(() {
        _playerIsReady = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _recorderIsReady = true;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(MatrixRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果initialValue发生变化，则更新value
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        data = widget.initialValue;
        _recordingCompleted = false;
        if (data != null && data!.isNotEmpty) {
          _recordingCompleted = true;
          _voiceDuration = data![0]['size'];
        }
      });
    }
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
  }

  @override
  void dispose() {
    _player!.closePlayer();
    _player = null;

    _recorder!.closeRecorder();
    _recorder = null;

    cancelRecorderSubscriptions();
    cancelPlayerSubscriptions();

    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _recorder!.openRecorder();

    if (!await _recorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _recordPath = 'voice.webm';
      if (!await _recorder!.isEncoderSupported(_codec) && kIsWeb) {
        _recorderIsReady = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _recorderIsReady = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  void record() async {
    await _recorder?.setSubscriptionDuration(const Duration(milliseconds: 100));

    await _recorder!.startRecorder(
      toFile: _recordPath,
      codec: _codec,
      audioSource: theSource,
    );

    _recorderSubscription = _recorder?.onProgress!.listen((e) {
      _recorder!.logger.i(
          'progress ${e.decibels} ${e.duration.inMilliseconds} ${e.duration.inMilliseconds.toDouble() / 1000} ${widget.maxDuration}');
      setState(() {
        _voiceDuration = e.duration.inMilliseconds.toDouble() / 1000;
        if (_voiceDuration >= widget.maxDuration) {
          getRecorderFn()!();
        }
      });
    });

    // _recorder?.dispositionStream()
    /// rerender
    setState(() {});
  }

  Future<void> _upload(String filePath) async {
    final dio = Dio();

    String fileName = _recordPath; // 通过 XFile 获取文件名
    var generateResponse =
        await dio.post('http://127.0.0.1:7001/generatePresignedUrl',
            data: jsonEncode({'fileName': fileName}),
            options: Options(headers: {
              HttpHeaders.contentTypeHeader: "application/json",
            }));
    var generateResponseData = generateResponse.data;

    // 读取文件为字节流
    // MultipartFile file;
    String contentType = 'audio/mp4';
    Uint8List fileBytes;

    if (kIsWeb) {
      final response = await http.get(Uri.parse(filePath));
      // file = MultipartFile.fromBytes(response.bodyBytes, filename: fileName);
      contentType = response.headers['content-type']!;
      fileBytes = response.bodyBytes;
    } else {
      // file = MultipartFile.fromFileSync(filePath);
      File file = File(filePath);
      fileBytes = await file.readAsBytes();
    }

    // 构建 FormData
    // FormData formData = FormData.fromMap({
    //   "fileInfo": file,
    // });

    final uploadDio = Dio();
    uploadDio.options.connectTimeout = Duration(seconds: 10);
    uploadDio.options.sendTimeout = Duration(seconds: 10);

    var uploadResponse =
        await uploadDio.post(generateResponseData["data"]['uploadUrl'],
            data: fileBytes,
            options: Options(headers: {
              HttpHeaders.contentTypeHeader: contentType,
            }));
    setState(() {
      data = [
        {
          "url": generateResponseData['data']['fileUrl'],
          "uid": generateResponseData["data"]['fileCode'],
          "name": fileName,
          "size": _voiceDuration
        }
      ];
      widget.onChanged!(data!);
    });
  }

  void stopRecorder() async {
    await _recorder!.stopRecorder().then((path) {
      setState(() {
        //var url = value;
        if (_voiceDuration > widget.minDuration) {
          _recordingCompleted = true;
          if (path != null) {
            _upload(path);
          }
        } else {
          TDToast.showFail("录制需大于${widget.minDuration.toString()}秒",
              context: context);
        }
      });
    });
  }

  void play() async {
    assert(_playerIsReady &&
        _recordingCompleted &&
        _recorder!.isStopped &&
        _player!.isStopped);

    await _player!.startPlayer(
        fromURI: data!=null && data!.isNotEmpty ? data![0]['url'] :  _recordPath,
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        });

    await _player?.setSubscriptionDuration(const Duration(milliseconds: 100));
    _playerSubscription = _player?.onProgress!.listen((e) {
      _player!.logger
          .i('progress ${e.position} ${e.position.inMilliseconds.toDouble()}');
      setState(() {
        _voicePlayProgress = e.position.inMilliseconds.toDouble() /
            e.duration.inMilliseconds.toDouble();
      });
    });

    setState(() {});
  }

  void stopPlayer() {
    _player!.stopPlayer().then((value) {
      setState(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  _Fn? getRecorderFn() {
    if (!_recorderIsReady || !_player!.isStopped) {
      return null;
    }
    return _recorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_playerIsReady || !_recordingCompleted || !_recorder!.isStopped) {
      return null;
    }
    return _player!.isStopped ? play : stopPlayer;
  }

  Widget _renderRecord() {
    return Visibility(
      visible: !_recordingCompleted && _recorder!.isStopped,
      child: Positioned(
        left: 0,
        right: 0,
        child: InkWell(
            onTap: getRecorderFn(),
            borderRadius: BorderRadius.circular(80.0),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(80.0)),
              child: const Icon(Icons.mic, size: 40.0, color: Colors.white),
            )),
      ),
    );
  }

  Widget _renderRecording() {
    return Visibility(
      visible: !_recordingCompleted && !_recorder!.isStopped,
      child: Positioned(
        left: 0,
        top: 0,
        child: InkWell(
            onTap: getRecorderFn(),
            borderRadius: BorderRadius.circular(80.0),
            child: Container(
              width: 80,
              height: 80,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(80.0)),
              child: Icon(Icons.stop,
                  size: 40.0,
                  color: _voiceDuration < widget.minDuration
                      ? Colors.red
                      : Colors.green),
            )),
      ),
    );
  }

  Widget _renderPlay() {
    return Visibility(
      visible: _recordingCompleted && _player!.isStopped,
      child: Positioned(
        left: 0,
        right: 0,
        child: InkWell(
            onTap: getPlaybackFn(),
            borderRadius: BorderRadius.circular(80.0),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(80.0)),
              child:
                  const Icon(Icons.play_arrow, size: 40.0, color: Colors.white),
            )),
      ),
    );
  }

  Widget _renderPlaying() {
    return Visibility(
      visible: _recordingCompleted && !_player!.isStopped,
      child: Positioned(
        left: 0,
        top: 0,
        child: InkWell(
            onTap: getPlaybackFn(),
            borderRadius: BorderRadius.circular(80.0),
            child: Container(
              width: 80,
              height: 80,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(80.0)),
              child: Icon(Icons.pause,
                  size: 40.0,
                  color: _voiceDuration < widget.minDuration
                      ? Colors.red
                      : Colors.green),
            )),
      ),
    );
  }

  Widget makeBody() {
    print('mRecorder!.isStopped ${_recorder!.isStopped}');
    return Column(
      children: [
        Container(
          height: 24.0,
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(_voiceDuration > 0 && _recordingCompleted
              ? "${_voiceDuration.toInt()}''"
              : ''),
        ),
        Stack(children: [
          Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(80.0)),
              alignment: Alignment.center),
          Visibility(
              visible: !_recorder!.isStopped || _player!.isPlaying,
              child: Positioned(
                  left: 0,
                  right: 0,
                  child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: _recordingCompleted
                            ? _voicePlayProgress
                            : _voiceDuration / widget.maxDuration,
                        valueColor: _voiceDuration < widget.minDuration
                            ? const AlwaysStoppedAnimation<Color>(Colors.red)
                            : const AlwaysStoppedAnimation<Color>(Colors.green),
                        color: Colors.black,
                        backgroundColor: Colors.black12,
                        strokeWidth: 4.0,
                      )))),
          _renderRecord(),
          _renderRecording(),
          _renderPlay(),
          _renderPlaying(),
        ]),
        Container(
            height: 32.0,
            width: double.infinity,
            alignment: Alignment.center,
            margin: EdgeInsets.all(8),
            child: Visibility(
                visible: true,
                child: TextButton(
                    onPressed: () {
                      if (_recordingCompleted) {
                        setState(() {
                          /// 重新录制
                          _recordingCompleted = false;
                        });
                      } else {
                        getRecorderFn()!();
                      }
                    },
                    child: Text(_recordingCompleted ? '重新录制' : '点击开始录音')))),
        // Container(
        //   margin: const EdgeInsets.all(3),
        //   padding: const EdgeInsets.all(3),
        //   height: 80,
        //   width: double.infinity,
        //   alignment: Alignment.center,
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFFAF0E6),
        //     border: Border.all(
        //       color: Colors.indigo,
        //       width: 3,
        //     ),
        //   ),
        //   child: Row(children: [
        //     ElevatedButton(
        //       onPressed: getRecorderFn(),
        //       //color: Colors.white,
        //       //disabledColor: Colors.grey,
        //       child: Text(_recorder!.isRecording ? 'Stop' : 'Record'),
        //     ),
        //     const SizedBox(
        //       width: 20,
        //     ),
        //     Text(_recorder!.isRecording
        //         ? 'Recording in progress'
        //         : 'Recorder is stopped'),
        //   ]),
        // ),
        // Container(
        //   margin: const EdgeInsets.all(3),
        //   padding: const EdgeInsets.all(3),
        //   height: 80,
        //   width: double.infinity,
        //   alignment: Alignment.center,
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFFAF0E6),
        //     border: Border.all(
        //       color: Colors.indigo,
        //       width: 3,
        //     ),
        //   ),
        //   child: Row(children: [
        //     ElevatedButton(
        //       onPressed: getPlaybackFn(),
        //       //color: Colors.white,
        //       //disabledColor: Colors.grey,
        //       child: Text(_player!.isPlaying ? 'Stop' : 'Play'),
        //     ),
        //     const SizedBox(
        //       width: 20,
        //     ),
        //     Text(_player!.isPlaying
        //         ? 'Playback in progress'
        //         : 'Player is stopped'),
        //   ]),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return makeBody();
  }
}
