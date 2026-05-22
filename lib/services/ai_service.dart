import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // 使用 OpenAI 兼容的 API（可配置）
  String? apiKey;
  String baseUrl = 'https://api.openai.com/v1';

  AIService({this.apiKey});

  // 第一步：提炼关键信息
  Future<String> extractKeyPoints(String content) async {
    final prompt = '''
请将以下维基百科内容提炼成适合播客的关键信息结构：

内容：
$content

请以JSON格式返回，包含：
{
  "title": "吸引人的播客标题",
  "introduction": "开场介绍（50-100字）",
  "key_points": [
    "要点1",
    "要点2",
    "要点3",
    "要点4",
    "要点5"
  ],
  "conclusion": "总结（30-50字）",
  "chapters": [
    {"title": "章节标题", "content": "章节内容概要"}
  ]
}
''';

    return await _callLLM(prompt);
  }

  // 第二步：生成对话脚本
  Future<String> generateScript(Map<String, dynamic> keyPoints) async {
    final prompt = '''
请基于以下关键信息，生成一段双人对话播客脚本：

标题：${keyPoints['title']}
介绍：${keyPoints['introduction']}
要点：${(keyPoints['key_points'] as List).join('、')}
总结：${keyPoints['conclusion']}

要求：
1. 两位主播：主持人Alex和嘉宾Luna
2. 对话自然流畅，像是真实的聊天
3. 适当加入口语化表达和过渡语
4. 总时长约8-10分钟（约2000字）
5. 格式：[说话人]：内容

请直接返回对话脚本，不需要其他说明。
''';

    return await _callLLM(prompt);
  }

  // 第三步：生成完整的播客（一站式）
  Future<Map<String, dynamic>> generatePodcastFromWiki(String wikiTitle, String content) async {
    // 简化版：直接生成完整播客信息
    final keyPoints = await extractKeyPoints(content);
    
    try {
      final keyPointsData = json.decode(keyPoints);
      final script = await generateScript(keyPointsData);
      
      return {
        'title': keyPointsData['title'] ?? wikiTitle,
        'description': keyPointsData['introduction'] ?? '',
        'script': script,
        'chapters': keyPointsData['chapters'] ?? [],
        'estimatedDuration': 600, // 10分钟
      };
    } catch (e) {
      // 降级处理
      return {
        'title': wikiTitle,
        'description': content.substring(0, content.length > 200 ? 200 : content.length),
        'script': _createSimpleScript(wikiTitle, content),
        'chapters': [],
        'estimatedDuration': 300,
      };
    }
  }

  String _createSimpleScript(String title, String content) {
    return '''
[Alex]：欢迎来到 radioQ，今天我们要聊的是 $title。

[Luna]：是的，这是一个非常有趣的话题。让我来给大家介绍一下。

[Alex]：好的，根据维基百科的介绍：${content.substring(0, content.length > 500 ? 500 : content.length)}

[Luna]：确实非常有意思。希望大家通过这个节目能对 $title 有更深入的了解。

[Alex]：感谢收听，我们下期再见！
''';
  }

  // 调用大语言模型
  Future<String> _callLLM(String prompt) async {
    if (apiKey == null || apiKey!.isEmpty) {
      // 没有API Key时，返回模拟数据
      await Future.delayed(const Duration(seconds: 2));
      return json.encode({
        'title': '人类为什么会探索太空？',
        'introduction': '从古至今，人类对宇宙的向往从未停止。从古代的天文观测到现代的太空探索，我们一直在追寻未知。',
        'key_points': [
          '太空探索的历史起源',
          '冷战时期的太空竞赛',
          '阿波罗登月计划',
          '国际空间站与国际合作',
          '未来太空探索展望'
        ],
        'conclusion': '太空探索代表着人类对未知的勇气，它将继续推动人类文明向前发展。',
        'chapters': [
          {'title': '历史起源', 'content': '从古代天文观测到航天时代'},
          {'title': '太空竞赛', 'content': '美苏之间的太空竞争'},
          {'title': '登月壮举', 'content': '阿波罗11号的历史性时刻'},
          {'title': '国际合作', 'content': '国际空间站与全球合作'},
          {'title': '未来展望', 'content': '火星殖民与深空探索'}
        ]
      });
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      }
      throw Exception('API调用失败');
    } catch (e) {
      print('LLM调用失败: $e');
      rethrow;
    }
  }
}
