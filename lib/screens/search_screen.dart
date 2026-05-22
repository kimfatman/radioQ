import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/podcast_provider.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _isGenerating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final provider = Provider.of<PodcastProvider>(context, listen: false);
    final results = await provider.searchWikipedia(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _generatePodcast(String title) async {
    setState(() {
      _isGenerating = true;
    });

    final provider = Provider.of<PodcastProvider>(context, listen: false);
    final podcast = await provider.generatePodcast(title);

    setState(() {
      _isGenerating = false;
    });

    if (podcast != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(podcast: podcast)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索维基百科条目...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResults = [];
                });
              },
            ),
          ),
          onChanged: (value) {
            _performSearch(value);
          },
        ),
      ),
      body: Stack(
        children: [
          _buildSearchResults(),
          if (_isGenerating) _buildGeneratingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && _searchController.text.isEmpty) {
      return _buildSuggestions();
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('未找到相关结果'),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(result.title),
          subtitle: Text(
            _cleanHtml(result.snippet),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: ElevatedButton(
            onPressed: () => _generatePodcast(result.title),
            child: const Text('生成播客'),
          ),
          onTap: () {
            // 查看维基百科页面详情
          },
        );
      },
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      '太空探索',
      '人工智能',
      '量子力学',
      '罗马帝国',
      '达尔文',
      '相对论',
      '黑洞',
      '文艺复兴',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('热门搜索', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((s) {
            return InkWell(
              onTap: () {
                _searchController.text = s;
                _performSearch(s);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGeneratingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'AI 正在生成播客...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '正在从维基百科提取内容\n并将知识转化为播客',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            _buildStepIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      '获取维基百科内容',
      'AI 理解提炼关键信息',
      '生成对话脚本',
      '语音合成生成音频',
    ];

    return Column(
      children: steps.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                e.key < 2 ? Icons.check_circle : Icons.radio_button_unchecked,
                color: e.key < 2 ? Colors.green : Colors.white30,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                e.value,
                style: TextStyle(
                  color: e.key < 2 ? Colors.white : Colors.white30,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _cleanHtml(String htmlText) {
    // 简单的HTML标签清理
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}
