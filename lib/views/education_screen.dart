import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/io_client.dart';
import 'package:dart_rss/dart_rss.dart';
import '../core/app_localizations.dart';

// ── RSS Feed Sources ───────────────────────────────────────────────────────────
const List<_FeedSource> _feedSources = [
  _FeedSource(
    name: 'Breast Cancer News',
    url: 'https://breastcancernews.com/feed/',
    category: 'News',
    color: Color(0xFFE91E8C),
  ),
  _FeedSource(
    name: 'Science Daily',
    url: 'https://www.sciencedaily.com/rss/health_medicine/breast_cancer.xml',
    category: 'Research',
    color: Color(0xFF7C4DFF),
  ),
  _FeedSource(
    name: 'National Breast Cancer Foundation',
    url: 'https://www.nationalbreastcancer.org/feed/',
    category: 'Awareness',
    color: Color(0xFF4CAF50),
  ),
  _FeedSource(
    name: 'Susan G. Komen',
    url: 'https://www.komen.org/feed/',
    category: 'Prevention',
    color: Color(0xFF00BCD4),
  ),
];

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  late TabController _tabController;

  bool _loadingLive = true;
  String? _liveError;
  List<_LiveArticle> _liveArticles = [];

  final List<String> _categories = [
    'All', 'News', 'Research', 'Awareness', 'Prevention',
  ];

  final List<_Article> _localArticles = [
    _Article(
      title: 'What is Breast Cancer?',
      category: 'Basics',
      icon: Icons.info_outline,
      color: Color(0xFFE91E8C),
      readTime: '3 min read',
      url: 'https://www.cancer.org/cancer/types/breast-cancer/about/what-is-breast-cancer.html',
      content: '''Breast cancer occurs when cells in the breast grow out of control. These cells usually form a tumor that can often be seen on an x-ray or felt as a lump.

**Types of Breast Cancer:**
• Ductal Carcinoma In Situ (DCIS) – Non-invasive
• Invasive Ductal Carcinoma – Most common type (80%)
• Invasive Lobular Carcinoma – Second most common
• Triple Negative Breast Cancer – Aggressive type

**Key Statistics:**
• 1 in 8 women will develop breast cancer in their lifetime
• When caught early, the 5-year survival rate is 99%
• Regular screening dramatically improves outcomes''',
    ),
    _Article(
      title: 'Warning Signs to Watch',
      category: 'Basics',
      icon: Icons.warning_amber_outlined,
      color: Color(0xFFFF9800),
      readTime: '4 min read',
      url: 'https://www.cdc.gov/breast-cancer/signs-symptoms/index.html',
      content: '''Knowing the warning signs of breast cancer is crucial for early detection.

**Physical Changes:**
• A new lump in the breast or underarm
• Thickening or swelling of part of the breast
• Irritation or dimpling of breast skin
• Nipple discharge other than breast milk
• Any change in size or shape of the breast

Most lumps are NOT cancer — but any new lump should be checked by a doctor.''',
    ),
    _Article(
      title: 'Risk Factors Explained',
      category: 'Risk Factors',
      icon: Icons.analytics_outlined,
      color: Color(0xFF7C4DFF),
      readTime: '5 min read',
      url: 'https://www.cancer.gov/types/breast/risk/understanding',
      content: '''Understanding your risk factors helps you take proactive steps.

**Factors You Cannot Control:**
• Being a woman
• Increasing age
• Family history of breast or ovarian cancer
• Inherited gene mutations (BRCA1, BRCA2)

**Factors You CAN Control:**
• Physical inactivity
• Being overweight after menopause
• Alcohol consumption
• Smoking''',
    ),
    _Article(
      title: 'How to Do a Self-Exam',
      category: 'Self-Exam',
      icon: Icons.touch_app_outlined,
      color: Color(0xFF4CAF50),
      readTime: '6 min read',
      url: 'https://www.nationalbreastcancer.org/breast-self-exam/',
      content: '''A breast self-exam (BSE) is a simple check you can do at home.

**Step 1 — In the Mirror**
Look for changes in size, shape, or color.

**Step 2 — While Lying Down**
Use circular motions with three fingers, covering the entire breast.

**Step 3 — While Standing**
Check in the shower using the same technique.

Do this once a month, same time each month.''',
    ),
    _Article(
      title: 'Screening & Mammograms',
      category: 'Prevention',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF00BCD4),
      readTime: '4 min read',
      url: 'https://www.cancer.org/cancer/types/breast-cancer/screening-tests-and-early-detection/mammograms.html',
      content: '''Regular screening is the most powerful tool for early detection.

**Guidelines:**
• Ages 40-44: Option to start annual mammograms
• Ages 45-54: Annual mammograms recommended
• Ages 55+: Every 2 years or continue annually

Early detection through screening reduces mortality by up to 30%.''',
    ),
    _Article(
      title: 'Healthy Habits to Reduce Risk',
      category: 'Prevention',
      icon: Icons.favorite_outline,
      color: Color(0xFFE91E8C),
      readTime: '5 min read',
      url: 'https://www.who.int/news-room/fact-sheets/detail/cancer',
      content: '''Lifestyle changes can significantly lower your chance of developing breast cancer.

**Key Habits:**
• Exercise 150-300 minutes per week
• Maintain a healthy weight
• Limit alcohol to less than 1 drink per day
• Eat plenty of fruits, vegetables, and whole grains
• Quit smoking
• Breastfeed if possible''',
    ),
    _Article(
      title: 'Treatment Options Overview',
      category: 'Treatment',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFF7C4DFF),
      readTime: '7 min read',
      url: 'https://www.mayoclinic.org/diseases-conditions/breast-cancer/diagnosis-treatment/drc-20352475',
      content: '''Several treatment options are available depending on the stage and type.

**Options:**
• Surgery (Lumpectomy or Mastectomy)
• Radiation Therapy
• Chemotherapy
• Hormone Therapy
• Targeted Therapy (HER2-positive)
• Immunotherapy (Triple-negative)

Always discuss options thoroughly with your oncologist.''',
    ),
    _Article(
      title: 'Myths vs Facts',
      category: 'Basics',
      icon: Icons.quiz_outlined,
      color: Color(0xFFFF9800),
      readTime: '3 min read',
      url: 'https://www.komen.org/breast-cancer/facts-statistics/myths-vs-facts/',
      content: '''Many myths about breast cancer cause unnecessary fear or false reassurance.

**MYTH:** Only women with family history get breast cancer
**FACT:** 85% of women diagnosed have NO family history.

**MYTH:** A lump always means cancer
**FACT:** 80% of lumps are benign. Always get checked.

**MYTH:** Men cannot get breast cancer
**FACT:** About 1% of cases occur in men.

Stay informed. Accurate information saves lives.''',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLiveArticles();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── Fetch RSS feeds — bypasses SSL certificate errors ─────────
  Future<void> _fetchLiveArticles() async {
    setState(() {
      _loadingLive = true;
      _liveError = null;
    });

    // Create an HTTP client that accepts self-signed certificates
    // This fixes CERTIFICATE_VERIFY_FAILED on some Android devices
    final httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final ioClient = IOClient(httpClient);

    final List<_LiveArticle> fetched = [];
    int successCount = 0;

    for (final source in _feedSources) {
      try {
        final response = await ioClient.get(
          Uri.parse(source.url),
          headers: {'User-Agent': 'BreastCareAI/1.0'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final feed = RssFeed.parse(response.body);
          for (final item in (feed.items ?? []).take(5)) {
            final title = item.title?.trim() ?? '';
            final description = _stripHtml(item.description ?? '');
            final link = item.link ?? '';
            final pubDate = item.pubDate ?? '';

            if (title.isEmpty || link.isEmpty) continue;

            fetched.add(_LiveArticle(
              title: title,
              summary: description.length > 200
                  ? '${description.substring(0, 200)}...'
                  : description,
              url: link,
              source: source.name,
              category: source.category,
              color: source.color,
              pubDate: _formatDate(pubDate),
            ));
          }
          successCount++;
        }
      } catch (e) {
        debugPrint('[RSS] Failed to fetch ${source.name}: $e');
      }
    }

    ioClient.close();

    if (!mounted) return;
    setState(() {
      _liveArticles = fetched;
      _loadingLive = false;
      if (successCount == 0 && fetched.isEmpty) {
        _liveError = 'Could not load live articles. Check your connection.';
      }
    });
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  String _formatDate(String pubDate) {
    try {
      final dt = DateTime.parse(pubDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      try {
        final parts = pubDate.split(' ');
        if (parts.length >= 4) return '${parts[1]} ${parts[2]} ${parts[3]}';
      } catch (_) {}
      return pubDate.length > 16 ? pubDate.substring(0, 16) : pubDate;
    }
  }

  List<_Article> get _filteredLocalArticles {
    return _localArticles.where((a) {
      return _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<_LiveArticle> get _filteredLiveArticles {
    return _liveArticles.where((a) {
      final matchesSearch = _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.summary.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || a.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } catch (_) {}
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not open: $url'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Education Hub',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh live articles',
            onPressed: _fetchLiveArticles,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.article_outlined), text: 'Live Articles'),
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Health Guides'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFE91E8C),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: l.searchArticles,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLiveTab(),
                _buildLocalTab(l),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE91E8C)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.grey.shade700,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: _loadingLive
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFE91E8C)),
                      SizedBox(height: 16),
                      Text('Loading latest articles…',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : _liveError != null && _liveArticles.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(_liveError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _fetchLiveArticles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE91E8C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _filteredLiveArticles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text('No articles found',
                                  style:
                                      TextStyle(color: Colors.grey.shade400)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFFE91E8C),
                          onRefresh: _fetchLiveArticles,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredLiveArticles.length,
                            itemBuilder: (_, i) {
                              final article = _filteredLiveArticles[i];
                              return _LiveArticleCard(
                                article: article,
                                delay: i * 60,
                                onTap: () => _openUrl(context, article.url),
                              ).animate().fadeIn(
                                  delay: Duration(milliseconds: i * 60));
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildLocalTab(AppTranslations l) {
    final filtered = _filteredLocalArticles;
    return filtered.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(l.noArticlesFound,
                    style: TextStyle(color: Colors.grey.shade400)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final article = filtered[i];
              return _ArticleCard(
                article: article,
                delay: i * 80,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _ArticleDetailScreen(
                      article: article,
                      openUrl: _openUrl,
                    ),
                  ),
                ),
              );
            },
          );
  }
}

// ── Live Article Card ─────────────────────────────────────────────────────────

class _LiveArticleCard extends StatelessWidget {
  final _LiveArticle article;
  final int delay;
  final VoidCallback onTap;
  const _LiveArticleCard({
    required this.article,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 8,
                spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: article.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(article.category,
                      style: TextStyle(
                          fontSize: 10,
                          color: article.color,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(article.source,
                      style:
                          const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis),
                ),
                if (article.pubDate.isNotEmpty)
                  Text(article.pubDate,
                      style:
                          const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(article.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            if (article.summary.isNotEmpty)
              Text(article.summary,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: article.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: article.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new,
                          size: 12, color: article.color),
                      const SizedBox(width: 4),
                      Text('Read Full Article',
                          style: TextStyle(
                              fontSize: 11,
                              color: article.color,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Local Article Card ────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final _Article article;
  final int delay;
  final VoidCallback onTap;
  const _ArticleCard({
    required this.article,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 8,
                spreadRadius: 2),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: article.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(article.icon, color: article.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: article.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(article.category,
                        style: TextStyle(
                            fontSize: 10,
                            color: article.color,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  Text(article.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(article.readTime,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: article.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new,
                                size: 10, color: article.color),
                            const SizedBox(width: 3),
                            Text('Read online',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: article.color,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1);
  }
}

// ── Article Detail Screen ─────────────────────────────────────────────────────

class _ArticleDetailScreen extends StatelessWidget {
  final _Article article;
  final Future<void> Function(BuildContext, String) openUrl;
  const _ArticleDetailScreen({
    required this.article,
    required this.openUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: article.color,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(article.category,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => openUrl(context, article.url),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: BoxDecoration(
                color: article.color,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        Icon(article.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(article.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(article.readTime,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildContent(article.content),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => openUrl(context, article.url),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l.readFullArticle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: article.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: article.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: article.color.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  Icon(Icons.lightbulb_outline, color: article.color),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Knowledge is power. Share this article with someone who might benefit.',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String content) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('**') && line.endsWith('**')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Text(line.replaceAll('**', ''),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87)),
          );
        } else if (line.startsWith('•')) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ',
                    style:
                        TextStyle(fontSize: 14, color: Colors.black54)),
                Expanded(
                  child: Text(line.substring(2),
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87)),
                ),
              ],
            ),
          );
        } else if (line.isEmpty) {
          return const SizedBox(height: 4);
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(line,
                style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: Colors.black87)),
          );
        }
      }).toList(),
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class _FeedSource {
  final String name;
  final String url;
  final String category;
  final Color color;
  const _FeedSource({
    required this.name,
    required this.url,
    required this.category,
    required this.color,
  });
}

class _LiveArticle {
  final String title;
  final String summary;
  final String url;
  final String source;
  final String category;
  final Color color;
  final String pubDate;
  const _LiveArticle({
    required this.title,
    required this.summary,
    required this.url,
    required this.source,
    required this.category,
    required this.color,
    required this.pubDate,
  });
}

class _Article {
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final String readTime;
  final String content;
  final String url;
  const _Article({
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.readTime,
    required this.content,
    required this.url,
  });
}