import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/podcast_provider.dart';
import '../widgets/podcast_card.dart';
import '../widgets/theme_button.dart';
import 'player_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DiscoverPage(),
          SubscriptionsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined),
            activeIcon: Icon(Icons.subscriptions),
            label: '订阅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

// 发现页面
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('radioQ', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 每日推荐
          _buildDailyRecommendation(context),
          const SizedBox(height: 24),
          // 热门主题
          _buildHotTopics(context),
          const SizedBox(height: 24),
          // 为你推荐
          _buildRecommendations(context),
        ],
      ),
    );
  }

  Widget _buildDailyRecommendation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('每日推荐', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
          child: Stack(
            children: [
              // 背景装饰
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(Icons.public, size: 180, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('人类为什么会探索太空？', style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 8),
                    const Text('来自维基百科条目：太空探索', style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    )),
                    const Spacer(),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // 跳转到播放页
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('立即收听'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHotTopics(BuildContext context) {
    final topics = [
      {'icon': Icons.public, 'name': '宇宙', 'color': Colors.blue},
      {'icon': Icons.smart_toy, 'name': '人工智能', 'color': Colors.purple},
      {'icon': Icons.history, 'name': '历史', 'color': Colors.orange},
      {'icon': Icons.science, 'name': '科学', 'color': Colors.green},
      {'icon': Icons.psychology, 'name': '哲学', 'color': Colors.pink},
      {'icon': Icons.more_horiz, 'name': '更多', 'color': Colors.grey},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('热门主题', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: topics.map((topic) {
            return Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (topic['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    topic['icon'] as IconData,
                    color: topic['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(topic['name'] as String, style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final provider = Provider.of<PodcastProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('为你推荐', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 12),
        if (provider.podcasts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('还没有生成播客，快去搜索吧！',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.podcasts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final podcast = provider.podcasts[index];
              return PodcastCard(
                podcast: podcast,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(podcast: podcast),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

// 订阅页面
class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PodcastProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我的订阅')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('收藏的播客', style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 16),
          if (provider.favorites.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('还没有收藏任何播客',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final podcast = provider.favorites[index];
                return PodcastCard(
                  podcast: podcast,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(podcast: podcast),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

// 个人页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 统计卡片
          _buildStatsCard(context),
          const SizedBox(height: 24),
          // 功能列表
          _buildMenuList(context),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final provider = Provider.of<PodcastProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('生成播客', '${provider.podcasts.length}'),
          _buildStatItem('收藏', '${provider.favorites.length}'),
          _buildStatItem('收听时长', '0h'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        )),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('API 设置'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 打开API设置页面
          },
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('下载管理'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('关于 radioQ'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('帮助与反馈'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}
