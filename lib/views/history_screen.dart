import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/assessment_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Low Risk', 'Moderate Risk', 'High Risk'];
  final User? _user = FirebaseAuth.instance.currentUser;

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Recently';
    final date = timestamp.toDate();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).round()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).round()} months ago';
    return '${(diff.inDays / 365).round()} years ago';
  }

  Color _riskColor(String level) {
    switch (level) {
      case 'Low Risk': return const Color(0xFF4CAF50);
      case 'Moderate Risk': return const Color(0xFFFF9800);
      default: return const Color(0xFFF44336);
    }
  }

  String _riskEmoji(String level) {
    switch (level) {
      case 'Low Risk': return '✅';
      case 'Moderate Risk': return '⚠️';
      default: return '🔴';
    }
  }

  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this assessment? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await AssessmentService.deleteAssessment(docId);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context, Map<String, dynamic> data, String docId) {
    final String riskLevel = data['riskLevel'] ?? 'Low Risk';
    final Color color = _riskColor(riskLevel);
    final double riskScore = (data['riskScore'] ?? 0.0).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(_riskEmoji(riskLevel),
                          style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(riskLevel,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color)),
                        Text(
                          '${(riskScore * 100).toStringAsFixed(1)}% risk  •  ${_timeAgo(data['createdAt'] as Timestamp?)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 14),

              // Score bar
              Text('Risk Score',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: riskScore,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text('${(riskScore * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),
              const Text('Assessment Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5,
                children: [
                  _DetailChip(label: 'Age', value: '${(data['age'] ?? 0).toInt()} yrs', icon: Icons.cake_outlined),
                  _DetailChip(label: 'BMI', value: '${(data['bmi'] ?? 0.0).toStringAsFixed(1)}', icon: Icons.monitor_weight_outlined),
                  _DetailChip(label: 'Smoking', value: data['smoking'] ?? '-', icon: Icons.smoking_rooms_outlined),
                  _DetailChip(label: 'Exercise', value: data['exercise'] ?? '-', icon: Icons.directions_run_outlined),
                  _DetailChip(label: 'Alcohol', value: data['alcohol'] ?? '-', icon: Icons.local_bar_outlined),
                  _DetailChip(label: 'Diet', value: data['diet'] ?? '-', icon: Icons.restaurant_outlined),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteDialog(context, docId);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/input');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Assessment History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Clear All History'),
                content: const Text('Delete all assessment records? This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      Navigator.pop(context);
                      await AssessmentService.deleteAllAssessments();
                    },
                    child: const Text('Clear All', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AssessmentService.getAssessments(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E8C)),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Filter docs
          final filtered = _filter == 'All'
              ? allDocs
              : allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['riskLevel'] == _filter;
                }).toList();

          // Count each level
          final lowCount = allDocs.where((d) =>
              (d.data() as Map)['riskLevel'] == 'Low Risk').length;
          final modCount = allDocs.where((d) =>
              (d.data() as Map)['riskLevel'] == 'Moderate Risk').length;
          final highCount = allDocs.where((d) =>
              (d.data() as Map)['riskLevel'] == 'High Risk').length;

          return Column(
            children: [
              // Stats banner
              Container(
                color: const Color(0xFFE91E8C),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    _StatBadge(label: 'Total', value: allDocs.length.toString(), color: Colors.white),
                    _StatBadge(label: 'Low', value: lowCount.toString(), color: const Color(0xFF4CAF50)),
                    _StatBadge(label: 'Moderate', value: modCount.toString(), color: const Color(0xFFFF9800)),
                    _StatBadge(label: 'High', value: highCount.toString(), color: const Color(0xFFF44336)),
                  ],
                ),
              ),

              // Filter chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _filters[i];
                      final selected = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFFE91E8C) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(f,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.grey.shade700,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            )),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 72, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              allDocs.isEmpty
                                  ? 'No assessments yet'
                                  : 'No records match this filter',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            if (allDocs.isEmpty)
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/input'),
                                icon: const Icon(Icons.add),
                                label: const Text('Take First Assessment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E8C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final doc = filtered[i];
                          final data = doc.data() as Map<String, dynamic>;
                          final docId = doc.id;
                          final String riskLevel = data['riskLevel'] ?? 'Low Risk';
                          final double riskScore = (data['riskScore'] ?? 0.0).toDouble();
                          final color = _riskColor(riskLevel);

                          return Dismissible(
                            key: Key(docId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              bool confirm = false;
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Record'),
                                  content: const Text('Delete this record?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () {
                                        confirm = true;
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                              return confirm;
                            },
                            onDismissed: (_) async {
                              await AssessmentService.deleteAssessment(docId);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Record deleted')),
                              );
                            },
                            child: GestureDetector(
                              onTap: () => _showDetailSheet(context, data, docId),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: .08),
                                      blurRadius: 8, spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52, height: 52,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: .1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Text(_riskEmoji(riskLevel),
                                            style: const TextStyle(fontSize: 24)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(riskLevel,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: color)),
                                          const SizedBox(height: 2),
                                          Text(
                                            _timeAgo(data['createdAt'] as Timestamp?),
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: riskScore,
                                              backgroundColor: Colors.grey.shade200,
                                              valueColor: AlwaysStoppedAnimation<Color>(color),
                                              minHeight: 5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${(riskScore * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: color),
                                        ),
                                        const Icon(Icons.chevron_right,
                                            color: Colors.grey, size: 18),
                                      ],
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: i * 60)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/input'),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Assessment'),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DetailChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}