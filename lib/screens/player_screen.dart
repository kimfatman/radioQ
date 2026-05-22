import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../providers/podcast_provider.dart';
import '../services/audio_service.dart';

class PlayerScreen extends StatefulWidget {
  final Podcast podcast;

  const PlayerScreen({super.key, required this.podcast});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayerService _audioService = AudioPlayerService();
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _audioService.play(widget.podcast);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Podcast?>(
        stream: _audioService.currentPodcastStream,
        initialData: widget.podcast,
        builder: (context, snapshot) {
          final podcast = snapshot.data ?? widget.podcast;
          
          return Column(
            children: [
              // 顶部封面区域
              Expanded(
                flex: 3,
                child: _buildCoverArea(podcast),
              ),
              
              // 播放控制区域
              Expanded(
                flex: 2,
                child: _buildControlsArea(podcast),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoverArea(Podcast podcast) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6).withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.expand_more, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text('正在播放', style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )),
                  const Spacer(),
                  Consumer<PodcastProvider>(
                    builder: (_, provider, __) {
                      return IconButton(
                        icon: Icon(
                          podcast.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          provider.toggleFavorite(podcast);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 封面插画占位
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.public,
                size: 80,
                color: Colors.white54,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 标题和来源
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                podcast.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '来自维基百科',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsArea(Podcast podcast) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 进度条
          StreamBuilder<Duration>(
            stream: _audioService.positionStream,
            initialData: Duration.zero,
            builder: (context, positionSnapshot) {
              final position = positionSnapshot.data ?? Duration.zero;
              
              return StreamBuilder<Duration>(
                stream: _audioService.durationStream,
                initialData: Duration(seconds: podcast.duration),
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration(seconds: podcast.duration);
                  final progress = duration.inSeconds > 0
                      ? position.inSeconds / duration.inSeconds
                      : 0.0;
                  
                  return Column(
                    children: [
                      Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (value) {
                          final newPosition = Duration(
                            seconds: (value * duration.inSeconds).toInt(),
                          );
                          _audioService.seek(newPosition);
                        },
                        activeColor: const Color(0xFF6366F1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position),
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(_formatDuration(duration),
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          
          const Spacer(),
          
          // 播放控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 后退15秒
              IconButton(
                icon: const Icon(Icons.replay_10, size: 32),
                onPressed: () => _audioService.rewind15(),
              ),
              
              const SizedBox(width: 24),
              
              // 播放/暂停按钮
              StreamBuilder<bool>(
                stream: _audioService.playingStream,
                initialData: true,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? true;
                  
                  return GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        _audioService.pause();
                      } else {
                        _audioService.resume();
                      }
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 24),
              
              // 快进15秒
              IconButton(
                icon: const Icon(Icons.forward_10, size: 32),
                onPressed: () => _audioService.forward15(),
              ),
            ],
          ),
          
          const Spacer(),
          
          // 底部功能按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 倍速
              TextButton.icon(
                onPressed: () {
                  // 切换倍速
                  setState(() {
                    if (_playbackSpeed == 1.0) {
                      _playbackSpeed = 1.5;
                    } else if (_playbackSpeed == 1.5) {
                      _playbackSpeed = 2.0;
                    } else {
                      _playbackSpeed = 1.0;
                    }
                  });
                },
                icon: const Icon(Icons.speed, size: 20),
                label: Text('${_playbackSpeed}x'),
              ),
              
              // 节目列表
              IconButton(
                icon: const Icon(Icons.list_alt),
                onPressed: () => _showChaptersBottomSheet(context, podcast),
              ),
              
              // 收藏
              Consumer<PodcastProvider>(
                builder: (_, provider, __) {
                  return IconButton(
                    icon: Icon(
                      podcast.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: podcast.isFavorite ? const Color(0xFF6366F1) : null,
                    ),
                    onPressed: () => provider.toggleFavorite(podcast),
                  );
                },
              ),
              
              // 分享
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // 分享功能
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showChaptersBottomSheet(BuildContext context, Podcast podcast) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('章节列表', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 16),
            if (podcast.chapters.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('暂无章节信息', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                itemCount: podcast.chapters.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final chapter = podcast.chapters[index];
                  return ListTile(
                    title: Text(chapter.title),
                    trailing: Text(chapter.startTimeText),
                    onTap: () {
                      _audioService.seek(Duration(seconds: chapter.startTime));
                      Navigator.pop(context);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
