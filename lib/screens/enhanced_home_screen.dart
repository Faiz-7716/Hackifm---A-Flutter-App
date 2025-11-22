import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/comprehensive_models.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  Map<String, dynamic> recommendations = {};
  List<NotificationModel> recentNotifications = [];
  List recentlyViewed = [];
  Map<String, dynamic> trending = {};
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _apiService.getRecommendations(),
        _apiService.getNotifications(limit: 5),
        _apiService.getRecentlyViewed(limit: 10),
        _apiService.getTrending(period: 'weekly'),
      ]);

      setState(() {
        recommendations = results[0]['success']
            ? results[0]['recommendations'] ?? {}
            : {};
        recentNotifications =
            (results[1]['notifications'] as List<dynamic>?)
                ?.map((n) => NotificationModel.fromJson(n))
                .toList() ??
            [];
        recentlyViewed = results[2]['recently_viewed'] ?? [];
        trending = results[3]['success'] ? results[3]['trending'] ?? {} : {};
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HackIFM Dashboard'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(
                '${recentNotifications.where((n) => !n.isRead).length}',
              ),
              child: const Icon(Icons.notifications),
            ),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'For You'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trending'),
            Tab(icon: Icon(Icons.history), text: 'Recent'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildForYouTab(),
                  _buildTrendingTab(),
                  _buildRecentTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildForYouTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickActions(),
        const SizedBox(height: 24),
        _buildNotificationsPreview(),
        const SizedBox(height: 24),
        _buildRecommendationsSection(
          'Recommended Internships',
          recommendations['internships'] ?? [],
          'internship',
        ),
        const SizedBox(height: 24),
        _buildRecommendationsSection(
          'Top Courses',
          recommendations['courses'] ?? [],
          'course',
        ),
        const SizedBox(height: 24),
        _buildRecommendationsSection(
          'Upcoming Events',
          recommendations['events'] ?? [],
          'event',
        ),
      ],
    );
  }

  Widget _buildTrendingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🔥 This Week\'s Hottest Opportunities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildRecommendationsSection(
          'Trending Internships',
          trending['internships'] ?? [],
          'internship',
        ),
        const SizedBox(height: 24),
        _buildRecommendationsSection(
          'Popular Courses',
          trending['courses'] ?? [],
          'course',
        ),
        const SizedBox(height: 24),
        _buildRecommendationsSection(
          'Hot Events',
          trending['events'] ?? [],
          'event',
        ),
      ],
    );
  }

  Widget _buildRecentTab() {
    if (recentlyViewed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No recent activity',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentlyViewed.length,
      itemBuilder: (context, index) {
        final item = recentlyViewed[index];
        final details = item['details'];
        if (details == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTypeColor(item['opportunity_type']),
              child: Icon(
                _getTypeIcon(item['opportunity_type']),
                color: Colors.white,
              ),
            ),
            title: Text(details['title'] ?? 'Unknown'),
            subtitle: Text(
              'Viewed ${_formatDate(item['viewed_at'])}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openDetail(item['opportunity_type'], details['id']),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  icon: Icons.upload_file,
                  label: 'Upload Resume',
                  onTap: () => Navigator.pushNamed(context, '/profile/resume'),
                ),
                _buildQuickActionButton(
                  icon: Icons.person,
                  label: 'Complete Profile',
                  onTap: () => Navigator.pushNamed(context, '/profile/edit'),
                ),
                _buildQuickActionButton(
                  icon: Icons.add_circle,
                  label: 'Submit Content',
                  onTap: () =>
                      Navigator.pushNamed(context, '/submit-opportunity'),
                ),
                _buildQuickActionButton(
                  icon: Icons.bookmark,
                  label: 'Saved Items',
                  onTap: () => Navigator.pushNamed(context, '/profile/saved'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPreview() {
    if (recentNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🔔 Recent Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/notifications'),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentNotifications.take(3).length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = recentNotifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead
                      ? Colors.grey
                      : Colors.blue,
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  notification.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatDate(notification.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(String title, List items, String type) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _viewAll(type),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.take(10).length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildOpportunityCard(item, type);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> item, String type) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _openDetail(type, item['id']),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getTypeColor(type),
                    radius: 20,
                    child: Icon(
                      _getTypeIcon(type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item['company'] ??
                              item['instructor'] ??
                              item['organizer'] ??
                              '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  item['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (type == 'internship' && item['stipend_max'] != null)
                    Text(
                      '₹${item['stipend_min']}-${item['stipend_max']}/month',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  else if (type == 'course')
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(' ${item['rating'] ?? 0}'),
                      ],
                    ),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        size: 14,
                        color: Colors.grey,
                      ),
                      Text(
                        ' ${item['views_count'] ?? 0}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'internship':
        return Icons.work;
      case 'course':
        return Icons.school;
      case 'event':
        return Icons.event;
      default:
        return Icons.help;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'internship':
        return Colors.blue;
      case 'course':
        return Colors.green;
      case 'event':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'approval':
        return Icons.check_circle;
      case 'completion':
        return Icons.task_alt;
      case 'reminder':
        return Icons.alarm;
      case 'submission':
        return Icons.upload;
      case 'report':
        return Icons.flag;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _openDetail(String type, int id) {
    Navigator.pushNamed(context, '/$type-detail', arguments: {'id': id});
  }

  void _viewAll(String type) {
    Navigator.pushNamed(context, '/${type}s');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
