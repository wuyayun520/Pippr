import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Featured Talents'),
            _buildTalentGrid(),
            const SizedBox(height: 24),
            _buildSectionTitle('Categories'),
            _buildCategoryList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Trending Now'),
            _buildTrendingList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stars,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
          
            SizedBox(height: 8),
            Text(
              'Discover and showcase your talent',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTalentGrid() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTalentCard('Singer', Icons.mic, 'Music'),
          const SizedBox(width: 12),
          _buildTalentCard('Dancer', Icons.music_note, 'Dance'),
          const SizedBox(width: 12),
          _buildTalentCard('Actor', Icons.theater_comedy, 'Acting'),
          const SizedBox(width: 12),
          _buildTalentCard('Comedian', Icons.sentiment_very_satisfied, 'Comedy'),
          const SizedBox(width: 12),
          _buildTalentCard('Musician', Icons.piano, 'Instruments'),
        ],
      ),
    );
  }

  Widget _buildTalentCard(String title, IconData icon, String category) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {'name': 'Music', 'icon': Icons.music_note, 'count': '1.2K'},
      {'name': 'Dance', 'icon': Icons.accessibility_new, 'count': '856'},
      {'name': 'Acting', 'icon': Icons.movie, 'count': '642'},
      {'name': 'Comedy', 'icon': Icons.emoji_emotions, 'count': '423'},
      {'name': 'Magic', 'icon': Icons.auto_awesome, 'count': '289'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category['icon'] as IconData,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              category['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category['count'] as String,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              // Navigate to category detail
            },
          ),
        );
      },
    );
  }

  Widget _buildTrendingList() {
    final trendingItems = [
      {'title': 'Amazing Vocal Performance', 'artist': 'Sarah Chen', 'views': '125K'},
      {'title': 'Street Dance Battle', 'artist': 'Dance Crew Pro', 'views': '98K'},
      {'title': 'Stand-up Comedy Special', 'artist': 'Mike Johnson', 'views': '76K'},
      {'title': 'Piano Masterpiece', 'artist': 'Emma Wilson', 'views': '64K'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: trendingItems.length,
      itemBuilder: (context, index) {
        final item = trendingItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.play_circle_outline,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item['artist'] as String,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['views'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
            onTap: () {
              // Navigate to detail
            },
          ),
        );
      },
    );
  }
}

