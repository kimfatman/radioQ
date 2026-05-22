import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/podcast.dart';
import '../services/wikipedia_service.dart';
import '../services/ai_service.dart';

class PodcastProvider with ChangeNotifier {
  List<Podcast> _podcasts = [];
  List<Podcast> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  final AIService _aiService = AIService();
  late Box<Podcast> _podcastBox;
  
  List<Podcast> get podcasts => _podcasts;
  List<Podcast> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  PodcastProvider() {
    _initHive();
  }
  
  Future<void> _initHive() async {
    _podcastBox = await Hive.openBox<Podcast>('podcasts');
    _podcasts = _podcastBox.values.toList();
    _favorites = _podcasts.where((p) => p.isFavorite).toList();
    notifyListeners();
  }
  
  // 搜索维基百科
  Future<List<WikiSearchResult>> searchWikipedia(String query) async {
    return await WikipediaService.search(query);
  }
  
  // 生成播客
  Future<Podcast?> generatePodcast(String wikiTitle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // 1. 获取维基百科内容
      final summary = await WikipediaService.getPageSummary(wikiTitle);
      final fullContent = await WikipediaService.getPageContent(wikiTitle);
      
      // 2. AI 生成播客
      final podcastData = await _aiService.generatePodcastFromWiki(
        wikiTitle,
        fullContent.isNotEmpty ? fullContent : summary.extract,
      );
      
      // 3. 创建播客对象
      final podcast = Podcast(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: podcastData['title'] ?? wikiTitle,
        description: podcastData['description'] ?? summary.extract,
        wikiUrl: summary.pageUrl,
        coverImage: summary.thumbnail,
        duration: podcastData['estimatedDuration'] ?? 600,
        createdAt: DateTime.now(),
        chapters: (podcastData['chapters'] as List?)
                ?.asMap()
                .entries
                .map((e) => Chapter(
                      id: e.key.toString(),
                      title: e.value['title'] ?? '',
                      startTime: e.key * 120, // 每章2分钟
                      duration: 120,
                    ))
                .toList() ??
            [],
      );
      
      // 4. 保存到本地
      await _podcastBox.put(podcast.id, podcast);
      _podcasts.insert(0, podcast);
      
      _isLoading = false;
      notifyListeners();
      
      return podcast;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // 切换收藏
  Future<void> toggleFavorite(Podcast podcast) async {
    podcast.isFavorite = !podcast.isFavorite;
    await podcast.save();
    
    if (podcast.isFavorite) {
      if (!_favorites.contains(podcast)) {
        _favorites.add(podcast);
      }
    } else {
      _favorites.removeWhere((p) => p.id == podcast.id);
    }
    
    notifyListeners();
  }
  
  // 删除播客
  Future<void> deletePodcast(Podcast podcast) async {
    await _podcastBox.delete(podcast.id);
    _podcasts.removeWhere((p) => p.id == podcast.id);
    _favorites.removeWhere((p) => p.id == podcast.id);
    notifyListeners();
  }
  
  // 获取热门推荐
  Future<List<WikiSearchResult>> getFeatured() async {
    return await WikipediaService.getFeatured();
  }
}
