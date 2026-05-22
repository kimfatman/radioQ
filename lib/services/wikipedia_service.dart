import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/podcast.dart';

class WikipediaService {
  static const String baseUrl = 'https://zh.wikipedia.org/w/api.php';
  static const String summaryBaseUrl = 'https://zh.wikipedia.org/api/rest_v1/page/summary';

  // 搜索维基百科条目
  static Future<List<WikiSearchResult>> search(String query) async {
    try {
      final url = Uri.parse(
        '$baseUrl?action=query&list=search&srsearch=${Uri.encodeComponent(query)}'
        '&srlimit=20&format=json&utf8=1'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final searchResults = data['query']['search'] as List;
        
        return searchResults.map((item) => WikiSearchResult(
          title: item['title'] as String,
          snippet: item['snippet'] as String,
          pageId: item['pageid'] as int,
        )).toList();
      }
      return [];
    } catch (e) {
      print('搜索维基百科出错: $e');
      return [];
    }
  }

  // 获取页面摘要
  static Future<WikiPageSummary> getPageSummary(String title) async {
    try {
      final encodedTitle = Uri.encodeComponent(title.replaceAll(' ', '_'));
      final url = Uri.parse('$summaryBaseUrl/$encodedTitle');
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return WikiPageSummary(
          title: data['title'] as String,
          extract: data['extract'] as String? ?? '',
          thumbnail: data['thumbnail']?['source'] as String?,
          pageUrl: data['content_urls']?['desktop']?['page'] as String? ?? 
                   'https://zh.wikipedia.org/wiki/$encodedTitle',
        );
      }
      throw Exception('获取页面摘要失败');
    } catch (e) {
      print('获取页面摘要出错: $e');
      rethrow;
    }
  }

  // 获取完整页面内容
  static Future<String> getPageContent(String title) async {
    try {
      final encodedTitle = Uri.encodeComponent(title);
      final url = Uri.parse(
        '$baseUrl?action=query&titles=$encodedTitle&prop=extracts'
        '&explaintext=1&format=json&utf8=1'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map;
        final pageId = pages.keys.first;
        final page = pages[pageId];
        
        return page['extract'] as String? ?? '';
      }
      return '';
    } catch (e) {
      print('获取页面内容出错: $e');
      return '';
    }
  }

  // 获取热门推荐
  static Future<List<WikiSearchResult>> getFeatured() async {
    try {
      // 获取首页推荐的特色条目
      final url = Uri.parse(
        '$baseUrl?action=parse&page=Portal:%E7%89%B9%E8%89%B2%E6%9D%A1%E7%9B%AE'
        '&prop=text&format=json&utf8=1'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // 简化处理，返回一些默认的热门主题
        return [
          WikiSearchResult(title: '太空探索', snippet: '人类探索宇宙的历程', pageId: 1),
          WikiSearchResult(title: '人工智能', snippet: '计算机科学的一个分支', pageId: 2),
          WikiSearchResult(title: '罗马帝国', snippet: '古代欧洲的伟大帝国', pageId: 3),
          WikiSearchResult(title: '量子力学', snippet: '物理学的重要分支', pageId: 4),
          WikiSearchResult(title: '进化论', snippet: '生物演化的理论', pageId: 5),
        ];
      }
      return [];
    } catch (e) {
      // 返回一些默认值
      return [
        WikiSearchResult(title: '太空探索', snippet: '人类探索宇宙的历程', pageId: 1),
        WikiSearchResult(title: '人工智能', snippet: '计算机科学的一个分支', pageId: 2),
      ];
    }
  }
}

class WikiSearchResult {
  final String title;
  final String snippet;
  final int pageId;

  WikiSearchResult({
    required this.title,
    required this.snippet,
    required this.pageId,
  });
}

class WikiPageSummary {
  final String title;
  final String extract;
  final String? thumbnail;
  final String pageUrl;

  WikiPageSummary({
    required this.title,
    required this.extract,
    this.thumbnail,
    required this.pageUrl,
  });
}
