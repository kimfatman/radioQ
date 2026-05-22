import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/podcast.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  Podcast? _currentPodcast;
  
  // 流控制器
  final StreamController<Podcast?> _currentPodcastController = StreamController.broadcast();
  final StreamController<Duration> _positionController = StreamController.broadcast();
  final StreamController<Duration> _durationController = StreamController.broadcast();
  final StreamController<bool> _playingController = StreamController.broadcast();
  
  // 流
  Stream<Podcast?> get currentPodcastStream => _currentPodcastController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get playingStream => _playingController.stream;
  
  // 当前状态
  Podcast? get currentPodcast => _currentPodcast;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get isPlaying => _player.playing;
  
  AudioPlayerService() {
    _init();
  }
  
  void _init() {
    // 监听播放位置变化
    _player.positionStream.listen((pos) {
      _positionController.add(pos);
    });
    
    // 监听时长变化
    _player.durationStream.listen((dur) {
      _durationController.add(dur ?? Duration.zero);
    });
    
    // 监听播放状态变化
    _player.playingStream.listen((playing) {
      _playingController.add(playing);
    });
    
    // 监听播放完成
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _incrementPlayCount();
      }
    });
  }
  
  // 播放播客
  Future<void> play(Podcast podcast) async {
    if (podcast.audioUrl == null) {
      // 如果没有音频URL，播放演示音频
      // 实际应用中这里应该调用TTS服务生成音频
      await _playDemoAudio(podcast);
      return;
    }
    
    try {
      await _player.setUrl(podcast.audioUrl!);
      _currentPodcast = podcast;
      _currentPodcastController.add(podcast);
      await _player.play();
    } catch (e) {
      print('播放失败: $e');
      // 降级到演示音频
      await _playDemoAudio(podcast);
    }
  }
  
  // 演示模式：用计时器模拟播放
  Timer? _demoTimer;
  int _demoPosition = 0;
  
  Future<void> _playDemoAudio(Podcast podcast) async {
    _currentPodcast = podcast;
    _currentPodcastController.add(podcast);
    _durationController.add(Duration(seconds: podcast.duration));
    
    _demoPosition = _player.position.inSeconds;
    _playingController.add(true);
    
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _demoPosition++;
      _positionController.add(Duration(seconds: _demoPosition));
      
      if (_demoPosition >= podcast.duration) {
        timer.cancel();
        _playingController.add(false);
        _incrementPlayCount();
      }
    });
  }
  
  // 暂停
  Future<void> pause() async {
    if (_currentPodcast?.audioUrl != null) {
      await _player.pause();
    } else {
      _demoTimer?.cancel();
      _playingController.add(false);
    }
  }
  
  // 继续播放
  Future<void> resume() async {
    if (_currentPodcast?.audioUrl != null) {
      await _player.play();
    } else if (_currentPodcast != null) {
      await _playDemoAudio(_currentPodcast!);
    }
  }
  
  // 跳转
  Future<void> seek(Duration position) async {
    if (_currentPodcast?.audioUrl != null) {
      await _player.seek(position);
    } else {
      _demoPosition = position.inSeconds;
      _positionController.add(position);
    }
  }
  
  // 快进15秒
  Future<void> forward15() async {
    final newPos = position + const Duration(seconds: 15);
    if (newPos < duration) {
      await seek(newPos);
    } else {
      await seek(duration);
    }
  }
  
  // 后退15秒
  Future<void> rewind15() async {
    final newPos = position - const Duration(seconds: 15);
    if (newPos > Duration.zero) {
      await seek(newPos);
    } else {
      await seek(Duration.zero);
    }
  }
  
  // 停止
  Future<void> stop() async {
    _demoTimer?.cancel();
    _playingController.add(false);
    await _player.stop();
  }
  
  // 增加播放次数
  void _incrementPlayCount() {
    if (_currentPodcast != null) {
      _currentPodcast!.playCount++;
      _currentPodcast!.save();
    }
  }
  
  // 清理资源
  void dispose() {
    _demoTimer?.cancel();
    _player.dispose();
    _currentPodcastController.close();
    _positionController.close();
    _durationController.close();
    _playingController.close();
  }
}
