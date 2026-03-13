import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_localizations.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Basics', 'Risk Factors', 'Self-Exam', 'Treatment', 'Prevention'
  ];

  final List<_Article> _articles = [
    _Article(
      title: 'What is Breast Cancer?',
      category: 'Basics',
      icon: Icons.info_outline,
      color: Color(0xFFE91E8C),
      readTime: '3 min read',
      url: 'https://www.cancer.org/cancer/types/breast-cancer/about/what-is-breast-cancer.html',
      content: '''Breast cancer occurs when cells in the breast grow out of control. These cells usually form a tumor that can often be seen on an x-ray or felt as a lump.

The tumor is malignant (cancer) if the cells can grow into (invade) surrounding tissues or spread (metastasize) to distant areas of the body.

Breast cancer occurs almost entirely in women, but men can get breast cancer too.

**Types of Breast Cancer:**
• Ductal Carcinoma In Situ (DCIS) – Non-invasive
• Invasive Ductal Carcinoma – Most common type (80%)
• Invasive Lobular Carcinoma – Second most common
• Triple Negative Breast Cancer – Aggressive type
• HER2-positive Breast Cancer

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
      content: '''Knowing the warning signs of breast cancer is crucial for early detection. See a doctor immediately if you notice:

**Physical Changes:**
• A new lump in the breast or underarm
• Thickening or swelling of part of the breast
• Irritation or dimpling of breast skin
• Redness or flaky skin in the nipple area
• Pulling in of the nipple or pain in the nipple area
• Nipple discharge other than breast milk (including blood)
• Any change in size or shape of the breast
• Pain in any area of the breast

**Remember:**
Most lumps are NOT cancer — but any new lump should be checked by a doctor. Early detection is your best defense.

Do not ignore changes even if a recent mammogram was normal.''',
    ),
    _Article(
      title: 'Risk Factors Explained',
      category: 'Risk Factors',
      icon: Icons.analytics_outlined,
      color: Color(0xFF7C4DFF),
      readTime: '5 min read',
      url: 'https://www.cancer.gov/types/breast/risk/understanding',
      content: '''Understanding your risk factors helps you take proactive steps. Risk factors are divided into those you can and cannot control.

**Factors You Cannot Control:**
• Being a woman (99% of cases are female)
• Increasing age (most cases occur after 50)
• Family history of breast or ovarian cancer
• Personal history of breast cancer or certain non-cancerous conditions
• Dense breast tissue
• Starting periods before age 12
• Starting menopause after age 55
• Inherited gene mutations (BRCA1, BRCA2)

**Factors You CAN Control:**
• Physical inactivity — exercise reduces risk by 10-20%
• Being overweight or obese after menopause
• Taking hormones (HRT or birth control pills)
• Alcohol consumption — even 1 drink/day increases risk
• Never having been pregnant
• Not breastfeeding
• Smoking

Having risk factors does NOT mean you will get breast cancer. Many women with multiple risk factors never develop it, and many without risk factors do. Knowledge helps you make informed decisions.''',
    ),
    _Article(
      title: 'How to Do a Self-Exam',
      category: 'Self-Exam',
      icon: Icons.touch_app_outlined,
      color: Color(0xFF4CAF50),
      readTime: '6 min read',
      url: 'https://www.nationalbreastcancer.org/breast-self-exam/',
      content: '''A breast self-exam (BSE) is a simple check you can do at home. The best time is 3-5 days after your period starts when breasts are less tender.

**Step 1 — In the Mirror**
Stand with your arms at your sides. Look for:
• Changes in size, shape, or color
• Visible distortion or swelling
• Dimpling, puckering, or bulging
• Nipple changes or discharge
Raise your arms and check again.

**Step 2 — While Lying Down**
• Lie down with right arm behind your head
• Use the three middle fingers of your left hand
• Use circular motions about the size of a coin
• Cover the entire breast from armpit to sternum
• Use light, medium, then firm pressure
• Repeat for the left breast

**Step 3 — While Standing/Sitting**
• Many women find it easier to feel tissue when skin is wet
• Check in the shower using the same technique

**What to Feel For:**
• Hard knot or lump
• Areas that are thicker than others
• Any change from your last exam

**When to Do It:**
Once a month, same time each month. Do not panic over every change — hormonal changes are normal. See your doctor if you notice persistent changes.''',
    ),
    _Article(
      title: 'Screening & Mammograms',
      category: 'Prevention',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF00BCD4),
      readTime: '4 min read',
      url: 'https://www.cancer.org/cancer/types/breast-cancer/screening-tests-and-early-detection/mammograms.html',
      content: '''Regular screening is the most powerful tool for early detection of breast cancer, often finding it before symptoms appear.

**Screening Guidelines (General):**
• Ages 40-44: Option to start annual mammograms
• Ages 45-54: Annual mammograms recommended
• Ages 55+: Switch to every 2 years OR continue annually
• High-risk women: May need MRI + mammogram starting at 30

**What is a Mammogram?**
A mammogram is an X-ray of the breast. It can detect tumors that are too small to feel. Modern digital mammograms are very accurate.

**Other Screening Methods:**
• Breast Ultrasound — used with mammograms for dense tissue
• Breast MRI — for high-risk patients
• 3D Mammogram (Tomosynthesis) — more detailed than standard
• Clinical Breast Exam — done by a healthcare provider

**Preparing for a Mammogram:**
• Do not wear deodorant, perfume, or powder on the day
• Wear a two-piece outfit for easy undressing
• Tell the technician about any breast changes
• Bring previous mammogram images for comparison

Early detection through screening reduces mortality by up to 30%.''',
    ),
    _Article(
      title: 'Healthy Habits to Reduce Risk',
      category: 'Prevention',
      icon: Icons.favorite_outline,
      color: Color(0xFFE91E8C),
      readTime: '5 min read',
      url: 'https://www.who.int/news-room/fact-sheets/detail/cancer',
      content: '''While you cannot eliminate all risk, lifestyle changes can significantly lower your chance of developing breast cancer.

**Exercise Regularly:**
• Aim for 150-300 minutes of moderate activity per week
• Even 30 minutes of walking daily makes a difference
• Exercise reduces estrogen levels and body fat

**Maintain a Healthy Weight:**
• Obesity after menopause increases risk by 20-40%
• Excess fat tissue produces estrogen, fueling some cancers
• Focus on sustainable healthy eating, not crash diets

**Limit Alcohol:**
• Each alcoholic drink per day increases risk by 7-10%
• If you drink, limit to less than 1 drink per day
• Red wine is NOT protective against breast cancer

**Eat a Balanced Diet:**
• Plenty of fruits, vegetables, and whole grains
• Limit red meat and processed foods
• Include omega-3 rich foods (fish, flaxseed, walnuts)
• Cruciferous vegetables (broccoli, cabbage) may be protective

**Other Steps:**
• Quit smoking — linked to increased risk in younger women
• Breastfeed if possible — reduces risk
• Limit hormone replacement therapy
• Avoid radiation exposure when possible
• Manage stress through meditation, yoga, or counseling

Small consistent changes add up to significant risk reduction over time.''',
    ),
    _Article(
      title: 'Treatment Options Overview',
      category: 'Treatment',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFF7C4DFF),
      readTime: '7 min read',
      url: 'https://www.mayoclinic.org/diseases-conditions/breast-cancer/diagnosis-treatment/drc-20352475',
      content: '''If breast cancer is diagnosed, several treatment options are available. The best treatment depends on the stage, type, and your overall health.

**Surgery:**
• Lumpectomy — removes only the tumor and small margin of tissue
• Mastectomy — removes one or both breasts
• Sentinel node biopsy — checks if cancer has spread to lymph nodes

**Radiation Therapy:**
• Uses high-energy rays to destroy cancer cells
• Usually given after lumpectomy
• Daily sessions over 3-6 weeks
• Side effects: fatigue, skin changes

**Chemotherapy:**
• Uses drugs to kill cancer cells throughout the body
• May be given before surgery (neoadjuvant) or after (adjuvant)
• Side effects: hair loss, nausea, fatigue, infection risk

**Hormone Therapy:**
• For hormone receptor-positive cancers (ER+ or PR+)
• Tamoxifen or aromatase inhibitors
• Typically taken for 5-10 years
• Reduces recurrence risk significantly

**Targeted Therapy:**
• For HER2-positive cancers (Herceptin/trastuzumab)
• Specifically targets cancer cells while sparing normal cells

**Immunotherapy:**
• Helps your immune system fight cancer
• Used for triple-negative breast cancer

**Support During Treatment:**
Remember that treatment is a journey. Support groups, counseling, and palliative care are all important parts of comprehensive cancer care.

Always discuss options thoroughly with your oncologist.''',
    ),
    _Article(
      title: 'Myths vs Facts',
      category: 'Basics',
      icon: Icons.quiz_outlined,
      color: Color(0xFFFF9800),
      readTime: '3 min read',
      url: 'https://www.komen.org/breast-cancer/facts-statistics/myths-vs-facts/',
      content: '''Many myths about breast cancer can cause unnecessary fear or false reassurance. Here are the facts:

**MYTH: Only women with a family history get breast cancer**
FACT: 85% of women diagnosed have NO family history. All women are at risk.

**MYTH: Antiperspirants and deodorants cause breast cancer**
FACT: No scientific evidence supports this claim.

**MYTH: A lump always means cancer**
FACT: 80% of lumps are benign (non-cancerous). Always get checked.

**MYTH: Breast cancer only affects older women**
FACT: While risk increases with age, young women can get breast cancer too.

**MYTH: Mammograms cause cancer from radiation**
FACT: The radiation dose is extremely low — much less than a chest X-ray.

**MYTH: Small-breasted women have lower risk**
FACT: Breast size does not affect cancer risk.

**MYTH: If you have no symptoms, you are fine**
FACT: Many breast cancers are detected before symptoms appear. Regular screening is essential.

**MYTH: Men cannot get breast cancer**
FACT: About 1% of breast cancer cases occur in men. Men should also check for lumps.

Stay informed. Accurate information saves lives.''',
    ),
  ];

  List<_Article> get _filteredArticles {
    return _articles.where((a) {
      final matchesSearch = _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || a.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
      ),
      body: Column(
        children: [
          // ── Search + category chips ──────────────────────────────────────
          Container(
            color: const Color(0xFFE91E8C),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search bar
                Container(
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
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon:
                                  const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final selected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFFE91E8C)
                                  : Colors.white,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Article list ─────────────────────────────────────────────────
          Expanded(
            child: _filteredArticles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(l.noArticlesFound,
                            style:
                                TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredArticles.length,
                    itemBuilder: (_, i) {
                      final article = _filteredArticles[i];
                      return _ArticleCard(
                        article: article,
                        delay: i * 80,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                _ArticleDetailScreen(article: article),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Article Card ──────────────────────────────────────────────────────────────

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
              spreadRadius: 2,
            ),
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
                    child: Text(
                      article.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: article.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                      const Spacer(),
                      // ── "Read online" chip visible on card ───────────────
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
  const _ArticleDetailScreen({required this.article});

  // ── FIXED: real URL launcher logic ───────────────────────────────────────
  // Uses Uri.parse + launchUrl with fallback modes.
  // No longer relies on canLaunchUrl which needs a separate queries config.
  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(article.url);
    bool launched = false;

    // Try 1: open in external browser (Chrome / default browser)
    try {
      launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    // Try 2: fall back to in-app WebView if external browser fails
    if (!launched) {
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } catch (_) {
        launched = false;
      }
    }

    // Try 3: platform default (last resort)
    if (!launched) {
      try {
        launched = await launchUrl(uri);
      } catch (_) {
        launched = false;
      }
    }

    if (!launched && context.mounted) {
      _showUrlFallbackDialog(context);
    }
  }

  // Shows the URL in a dialog so user can copy it manually if all launch
  // attempts fail (e.g. device has no browser installed).
  void _showUrlFallbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.link, color: Color(0xFFE91E8C)),
          SizedBox(width: 8),
          Text('Open in Browser'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Could not open the browser automatically.\n'
              'Copy the link below and paste it in your browser:',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                article.url,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFE91E8C)),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C)),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
          // ── Open in browser icon ────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Read full article online',
            onPressed: () => _openUrl(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => _openUrl(context), // shares by opening
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header banner ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: BoxDecoration(
                color: article.color,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28)),
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
                    child: Icon(article.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(article.readTime,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_library_outlined,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text('Health Education',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Article content ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildContent(article.content),
            ),

            // ── Read Full Article button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openUrl(context),
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

            // ── Source label — shows which website it opens ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.link, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _extractDomain(article.url),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Tip footer ───────────────────────────────────────────────
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
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: article.color),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Knowledge is power. Share this article with someone who might benefit.',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Extracts readable domain from URL for the source label
  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  Widget _buildContent(String content) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('**') && line.endsWith('**')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
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
                  child: Text(
                    line.substring(2),
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        } else if (line.isEmpty) {
          return const SizedBox(height: 4);
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: const TextStyle(
                  fontSize: 14, height: 1.7, color: Colors.black87),
            ),
          );
        }
      }).toList(),
    );
  }
}

// ── Data Model ────────────────────────────────────────────────────────────────

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