# radioQ

> 让维基百科"开口说话" - 基于维基百科的 AI 播客应用

![radioQ Banner](https://via.placeholder.com/800x400/6366F1/FFFFFF?text=radioQ+AI+Podcast)

## ✨ 核心功能

### 1. 维基百科内容获取
- 全文搜索维基百科条目
- 获取页面摘要和完整内容
- 精选热门主题推荐

### 2. AI 智能处理
- **关键信息提炼**：自动提取文章核心要点
- **对话脚本生成**：将知识转化为自然的双人对话
- **章节划分**：智能划分播客章节

### 3. 播客播放器
- 完整的音频播放控制
- 播放/暂停/快进/后退
- 倍速播放（1.0x, 1.5x, 2.0x）
- 章节列表导航
- 收藏功能
- 分享功能

### 4. 本地数据存储
- 生成的播客本地保存
- 播放记录同步
- 收藏夹管理

## 📱 应用截图

### 发现页面
- 每日推荐卡片
- 热门主题快捷入口
- 为你推荐列表

### 播放器
- 沉浸式播放界面
- 播放进度条
- 完整控制按钮

### 搜索页面
- 实时搜索维基百科
- 热门搜索建议
- AI 生成进度动画

## 🚀 技术架构

### 前端技术栈
- **Flutter 3.x** - 跨平台 UI 框架
- **Provider** - 状态管理
- **Hive** - 本地 NoSQL 数据库
- **just_audio** - 音频播放
- **http** - 网络请求

### AI 服务流程
```
维基百科条目
    ↓
内容获取与清洗
    ↓
LLM 提炼关键信息
    ↓
生成对话脚本
    ↓
TTS 语音合成
    ↓
播客播放
```

## 📦 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/
│   └── podcast.dart             # 数据模型
├── providers/
│   └── podcast_provider.dart    # 状态管理
├── services/
│   ├── wikipedia_service.dart   # 维基百科 API
│   ├── ai_service.dart          # AI 服务
│   └── audio_service.dart       # 音频播放服务
├── screens/
│   ├── home_screen.dart         # 主页（发现/订阅/我的）
│   ├── player_screen.dart       # 播放器页面
│   └── search_screen.dart       # 搜索页面
└── widgets/
    ├── podcast_card.dart        # 播客卡片
    └── theme_button.dart        # 主题切换按钮
```

## 🔧 配置说明

### API Key 配置
应用支持 OpenAI 兼容的 API，可在设置页面配置：
- API Key
- API 地址（默认：https://api.openai.com/v1）

### 开发环境
```bash
# 安装依赖
flutter pub get

# 生成 Hive Adapter
flutter packages pub run build_runner build

# 运行应用
flutter run
```

## 🎯 使用流程

1. **搜索**：在搜索页输入想了解的知识主题
2. **选择**：从搜索结果中选择维基百科条目
3. **生成**：点击"生成播客"，AI 自动处理
4. **收听**：生成完成后自动进入播放页面
5. **管理**：收藏喜欢的播客，管理收听历史

## 🌟 特色亮点

### 🧠 智能内容处理
- 自动提炼文章要点，去除冗余信息
- 将书面语转化为自然口语对话
- 智能划分章节，便于定位跳转

### 🎨 优雅设计
- 深色/浅色模式自动适配
- 蓝紫渐变品牌视觉
- 流畅的动画过渡
- 符合 Material Design 3

### ⚡ 性能优化
- 本地缓存已生成的播客
- 按需加载数据
- 流畅的 60fps 动画

## 📄 License

MIT License - feel free to use this project for learning and development.

---

**💜 知识，值得被听见**
