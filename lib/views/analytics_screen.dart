import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;
  String? _error;
  List<_AssessmentData> _assessments = [];

  // ── Derived stats ──────────────────────────────────────────────────────────
  int get _total => _assessments.length;
  int get _lowCount =>
      _assessments.where((a) => a.riskLevel == 'Low').length;
  int get _modCount =>
      _assessments.where((a) => a.riskLevel == 'Moderate').length;
  int get _highCount =>
      _assessments.where((a) => a.riskLevel == 'High').length;

  double get _avgScore {
    if (_assessments.isEmpty) return 0;
    final sum = _assessments.fold<double>(0, (s, a) => s + a.riskScore);
    return sum / _assessments.length;
  }

  String get _trend {
    if (_assessments.length < 2) return 'stable';
    final last = _assessments.last.riskScore;
    final prev = _assessments[_assessments.length - 2].riskScore;
    if (last < prev - 0.02) return 'improving';
    if (last > prev + 0.02) return 'worsening';
    return 'stable';
  }

  // Most common risk factors across all assessments (if stored)
  Map<String, double> get _aggregatedFactors {
    final Map<String, List<double>> raw = {};
    for (final a in _assessments) {
      a.riskFactors.forEach((k, v) {
        raw.putIfAbsent(k, () => []).add(v);
      });
    }
    final Map<String, double> result = {};
    raw.forEach((k, vals) {
      result[k] = vals.fold(0.0, (s, v) => s + v) / vals.length;
    });
    // Sort by value descending and take top 6
    final sorted = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(6));
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Not signed in';
          _loading = false;
        });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .orderBy('createdAt', descending: false)
          .get();

      final list = snap.docs.map((doc) {
        final d = doc.data();
        return _AssessmentData.fromFirestore(d);
      }).toList();

      setState(() {
        _assessments = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _assessments.isEmpty
                  ? _buildEmpty()
                  : _buildContent(),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFE91E8C)),
          SizedBox(height: 16),
          Text('Loading your health data…',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load analytics',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error ?? '',
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E8C).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.analytics_outlined,
                  size: 50, color: Color(0xFFE91E8C)),
            ),
            const SizedBox(height: 24),
            const Text('No Data Yet',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Complete your first breast cancer risk assessment to see your personalised analytics and health trends here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey, height: 1.6, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/assessment'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Take First Assessment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main content ───────────────────────────────────────────────────────────
  Widget _buildContent() {
    final hasFactors = _aggregatedFactors.isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFFE91E8C),
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Hero summary cards ───────────────────────────────────────────
          _buildSummaryRow().animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 20),

          // ── Risk score over time ─────────────────────────────────────────
          if (_assessments.length >= 2) ...[
            _buildSectionHeader(
              icon: Icons.show_chart,
              title: 'Risk Score Over Time',
              subtitle: 'Your trend across all assessments',
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 10),
            _buildLineChart().animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 20),
          ],

          // ── Distribution donut ───────────────────────────────────────────
          _buildSectionHeader(
            icon: Icons.donut_large,
            title: 'Risk Distribution',
            subtitle: 'Breakdown of all your results',
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 10),
          _buildDonutChart().animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 20),

          // ── Risk factors bar chart (only if data exists) ─────────────────
          if (hasFactors) ...[
            _buildSectionHeader(
              icon: Icons.bar_chart,
              title: 'Risk Factor Breakdown',
              subtitle: 'Average contribution of each factor',
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 10),
            _buildBarChart().animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 20),
          ],

          // ── Insights ─────────────────────────────────────────────────────
          _buildSectionHeader(
            icon: Icons.lightbulb_outline,
            title: 'Health Insights',
            subtitle: 'Personalised based on your data',
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 10),
          _buildInsights().animate().fadeIn(delay: 450.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Summary row ────────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    final trendIcon = _trend == 'improving'
        ? Icons.trending_down
        : _trend == 'worsening'
            ? Icons.trending_up
            : Icons.trending_flat;
    final trendColor = _trend == 'improving'
        ? Colors.green
        : _trend == 'worsening'
            ? Colors.red
            : Colors.orange;
    final trendLabel = _trend == 'improving'
        ? 'Improving'
        : _trend == 'worsening'
            ? 'Worsening'
            : 'Stable';

    return Column(
      children: [
        // Top row — total + avg score
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total Assessments',
                value: '$_total',
                icon: Icons.assignment_outlined,
                color: const Color(0xFFE91E8C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: 'Average Risk Score',
                value: '${(_avgScore * 100).toStringAsFixed(1)}%',
                icon: Icons.speed_outlined,
                color: _avgScore < 0.33
                    ? Colors.green
                    : _avgScore < 0.66
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom row — trend + last result
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Current Trend',
                value: trendLabel,
                icon: trendIcon,
                color: trendColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: 'Latest Result',
                value: _assessments.last.riskLevel,
                icon: Icons.flag_outlined,
                color: _assessments.last.riskLevel == 'Low'
                    ? Colors.green
                    : _assessments.last.riskLevel == 'High'
                        ? Colors.red
                        : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Line chart — risk score over time ──────────────────────────────────────
  Widget _buildLineChart() {
    final spots = _assessments.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.riskScore * 100);
    }).toList();

    return _ChartCard(
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 36,
                    getTitlesWidget: (val, _) => Text(
                      '${val.toInt()}%',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (val, _) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= _assessments.length) {
                        return const SizedBox.shrink();
                      }
                      final dt = _assessments[idx].date;
                      if (dt == null) {
                        return Text('${idx + 1}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey));
                      }
                      return Text(
                        '${dt.day}/${dt.month}',
                        style: const TextStyle(
                            fontSize: 9, color: Colors.grey),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: const Color(0xFFE91E8C),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: const Color(0xFFE91E8C),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFE91E8C).withValues(alpha: 0.25),
                        const Color(0xFFE91E8C).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF2D2D2D),
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                            '${s.y.toStringAsFixed(1)}%',
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Donut chart — risk distribution ───────────────────────────────────────
  Widget _buildDonutChart() {
    final total = _total.toDouble();
    if (total == 0) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    if (_lowCount > 0) {
      sections.add(PieChartSectionData(
        value: _lowCount.toDouble(),
        color: const Color(0xFF4CAF50),
        title: '${((_lowCount / total) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13),
      ));
    }
    if (_modCount > 0) {
      sections.add(PieChartSectionData(
        value: _modCount.toDouble(),
        color: const Color(0xFFFF9800),
        title: '${((_modCount / total) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13),
      ));
    }
    if (_highCount > 0) {
      sections.add(PieChartSectionData(
        value: _highCount.toDouble(),
        color: const Color(0xFFE91E8C),
        title: '${((_highCount / total) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13),
      ));
    }

    return _ChartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Donut
            SizedBox(
              width: 160,
              height: 160,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 3,
                  pieTouchData: PieTouchData(enabled: false),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Legend
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(
                      color: const Color(0xFF4CAF50),
                      label: 'Low Risk',
                      count: _lowCount,
                      total: _total),
                  const SizedBox(height: 12),
                  _LegendItem(
                      color: const Color(0xFFFF9800),
                      label: 'Moderate',
                      count: _modCount,
                      total: _total),
                  const SizedBox(height: 12),
                  _LegendItem(
                      color: const Color(0xFFE91E8C),
                      label: 'High Risk',
                      count: _highCount,
                      total: _total),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bar chart — risk factor breakdown ──────────────────────────────────────
  Widget _buildBarChart() {
    final factors = _aggregatedFactors;
    if (factors.isEmpty) return const SizedBox.shrink();

    final keys = factors.keys.toList();
    final bars = keys.asMap().entries.map((e) {
      final val = factors[e.value]! * 100;
      final color = val < 33
          ? const Color(0xFF4CAF50)
          : val < 66
              ? const Color(0xFFFF9800)
              : const Color(0xFFE91E8C);
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: val.clamp(0, 100),
            color: color,
            width: 22,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    String shortLabel(String key) {
      // Shorten long key names for the x-axis
      final map = {
        'familyHistory': 'Family',
        'smoking': 'Smoking',
        'alcohol': 'Alcohol',
        'exercise': 'Exercise',
        'bmi': 'BMI',
        'age': 'Age',
        'hormonalContraceptives': 'Hormones',
        'diet': 'Diet',
        'breastfeeding': 'B.feed',
        'stress': 'Stress',
      };
return map[key] ?? (key.length > 7 ? key.substring(0, 7) : key);
    }

    return _ChartCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: 100,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 36,
                    getTitlesWidget: (val, _) => Text(
                      '${val.toInt()}%',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (val, _) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= keys.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          shortLabel(keys[idx]),
                          style: const TextStyle(
                              fontSize: 9, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: bars,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF2D2D2D),
                  getTooltipItem: (group, _, rod, __) =>
                      BarTooltipItem(
                    '${keys[group.x]}\n${rod.toY.toStringAsFixed(1)}%',
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Insights ───────────────────────────────────────────────────────────────
  Widget _buildInsights() {
    final insights = _generateInsights();
    return Column(
      children: insights
          .asMap()
          .entries
          .map((e) => _InsightCard(
                insight: e.value,
                delay: e.key * 80,
              ))
          .toList(),
    );
  }

  List<_Insight> _generateInsights() {
    final insights = <_Insight>[];

    // Insight 1 — trend
    if (_assessments.length >= 2) {
      if (_trend == 'improving') {
        insights.add(_Insight(
          icon: Icons.trending_down,
          color: Colors.green,
          title: 'Risk is Decreasing',
          body:
              'Your risk score has improved since your last assessment. Keep up the healthy habits — your efforts are working.',
        ));
      } else if (_trend == 'worsening') {
        insights.add(_Insight(
          icon: Icons.trending_up,
          color: Colors.red,
          title: 'Risk is Increasing',
          body:
              'Your risk score has risen since your last assessment. Consider reviewing your lifestyle factors and speaking with a healthcare provider.',
        ));
      } else {
        insights.add(_Insight(
          icon: Icons.trending_flat,
          color: Colors.orange,
          title: 'Risk is Stable',
          body:
              'Your risk score has remained consistent. Continue your current health routine and keep taking regular assessments.',
        ));
      }
    }

    // Insight 2 — assessment frequency
    if (_total == 1) {
      insights.add(_Insight(
        icon: Icons.calendar_month_outlined,
        color: const Color(0xFF7C4DFF),
        title: 'Take Assessments Regularly',
        body:
            'You have completed 1 assessment so far. Taking monthly assessments helps you track changes and catch trends early.',
      ));
    } else if (_total >= 2) {
      final first = _assessments.first.date;
      final last = _assessments.last.date;
      if (first != null && last != null) {
        final daysDiff = last.difference(first).inDays;
        final avgDays = daysDiff ~/ (_total - 1);
        if (avgDays > 45) {
          insights.add(_Insight(
            icon: Icons.calendar_today_outlined,
            color: const Color(0xFF7C4DFF),
            title: 'Increase Check-Up Frequency',
            body:
                'You average an assessment every $avgDays days. Monthly assessments give you the best picture of your health trends.',
          ));
        } else {
          insights.add(_Insight(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            title: 'Great Consistency!',
            body:
                'You\'ve been checking your risk regularly — every $avgDays days on average. Consistent monitoring is key to early detection.',
          ));
        }
      }
    }

    // Insight 3 — based on dominant risk level
    if (_highCount > _total ~/ 2) {
      insights.add(_Insight(
        icon: Icons.local_hospital_outlined,
        color: Colors.red,
        title: 'Consider a Clinical Screening',
        body:
            'More than half of your assessments have shown high risk. We strongly recommend scheduling a clinical breast exam or mammogram.',
      ));
    } else if (_lowCount == _total && _total >= 3) {
      insights.add(_Insight(
        icon: Icons.star_outline,
        color: Colors.green,
        title: 'Consistently Low Risk',
        body:
            'All $_total of your assessments show low risk. Excellent work maintaining a healthy lifestyle. Keep up your regular self-exams.',
      ));
    }

    // Insight 4 — from risk factors if available
    final factors = _aggregatedFactors;
    if (factors.isNotEmpty) {
      final highest = factors.entries.first;
      if (highest.value > 0.6) {
        final label = highest.key
            .replaceAllMapped(RegExp(r'([A-Z])'),
                (m) => ' ${m.group(0)}')
            .trim();
        insights.add(_Insight(
          icon: Icons.warning_amber_outlined,
          color: Colors.orange,
          title: 'High Impact Factor: ${_capitalize(label)}',
          body:
              '${_capitalize(label)} has been a consistently high risk contributor in your assessments. Focus on addressing this factor for the most impact.',
        ));
      }
    }

    // Fallback if very little data
    if (insights.isEmpty) {
      insights.add(_Insight(
        icon: Icons.info_outline,
        color: const Color(0xFF00BCD4),
        title: 'Keep Assessing',
        body:
            'Complete more assessments to unlock detailed trend analysis and personalised health insights.',
      ));
    }

    return insights;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE91E8C).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFE91E8C), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Data model — handles both cases (minimal and full Firestore data)
// ══════════════════════════════════════════════════════════════════════════════

class _AssessmentData {
  final String riskLevel;   // 'Low' | 'Moderate' | 'High'
  final double riskScore;   // 0.0 – 1.0
  final DateTime? date;
  final Map<String, double> riskFactors; // may be empty if not stored

  _AssessmentData({
    required this.riskLevel,
    required this.riskScore,
    required this.date,
    required this.riskFactors,
  });

  factory _AssessmentData.fromFirestore(Map<String, dynamic> d) {
    // ── Risk level ──────────────────────────────────────────────────────────
    final rawLevel = (d['riskLevel'] as String? ?? 'Low').trim();
    // Normalise variations: "low risk" → "Low", "HIGH" → "High" etc.
    String level = 'Moderate';
    if (rawLevel.toLowerCase().contains('low')) level = 'Low';
    if (rawLevel.toLowerCase().contains('high')) level = 'High';
    if (rawLevel.toLowerCase().contains('moderate') ||
        rawLevel.toLowerCase().contains('medium')) {
      level = 'Moderate';
    }

    // ── Risk score ──────────────────────────────────────────────────────────
    double score = 0.5;
    final rawScore = d['riskScore'];
    if (rawScore != null) {
      score = (rawScore as num).toDouble().clamp(0.0, 1.0);
    } else {
      // Derive from level if score not stored
      if (level == 'Low') score = 0.2;
      if (level == 'Moderate') score = 0.5;
      if (level == 'High') score = 0.8;
    }

    // ── Date ────────────────────────────────────────────────────────────────
    DateTime? date;
    final rawDate = d['createdAt'];
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate);
    }

    // ── Risk factors map — handles both 'riskFactors' and 'answers' keys ───
    // Case 1: riskFactors: { "smoking": 0.8, "bmi": 0.4, ... }
    // Case 2: answers: { "smoking": "yes", "exercise": "never", ... }
    // Case 3: neither key exists
    final Map<String, double> factors = {};

    final rawFactors = d['riskFactors'];
    if (rawFactors is Map) {
      rawFactors.forEach((k, v) {
        if (v is num) {
          factors[k.toString()] = v.toDouble().clamp(0.0, 1.0);
        }
      });
    }

    // If riskFactors not available, try to derive scores from answers map
    if (factors.isEmpty) {
      final rawAnswers = d['answers'];
      if (rawAnswers is Map) {
        rawAnswers.forEach((k, v) {
          final key = k.toString();
          final val = v.toString().toLowerCase();
          // Convert categorical answers to 0–1 scores
          double? score;
          if (val == 'yes' || val == 'true' || val == 'high' ||
              val == 'never' && key == 'exercise') {
            score = 0.8;
          } else if (val == 'no' || val == 'false' || val == 'low' ||
              val == 'daily' && key == 'exercise') {
            score = 0.1;
          } else if (val == 'sometimes' || val == 'moderate' ||
              val == 'medium') {
            score = 0.5;
          }
          if (score != null) factors[key] = score;
        });
      }
    }

    return _AssessmentData(
      riskLevel: level,
      riskScore: score,
      date: date,
      riskFactors: factors,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reusable widgets
// ══════════════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0
        ? ((count / total) * 100).toStringAsFixed(0)
        : '0';
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Text('$count',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(width: 4),
        Text('($pct%)',
            style:
                const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Insight {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Insight({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  final int delay;
  const _InsightCard({required this.insight, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: insight.color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(insight.icon, color: insight.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(insight.body,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay));
  }
}