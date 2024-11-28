import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'chat_rooms_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavigationTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatRoomsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  Widget _buildStoryAvatar(
      int index, Color primary, Color surfaceColor, Color textSecondaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.pastelBlue, AppTheme.pastelIndigo],
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: surfaceColor,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Icon(CupertinoIcons.person, color: primary),
                  ),
                ),
              ),
              if (index == 0)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            index == 0 ? 'Your Story' : 'User $index',
            style: AppTheme.textStyleLabel.copyWith(color: textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPost(BuildContext context, int index, bool isDark) {
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final textSecondaryColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final primary = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isDark ? AppTheme.elevatedCardDark : AppTheme.elevatedCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.pastelBlue, AppTheme.pastelIndigo],
                ),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.transparent,
                child: Icon(CupertinoIcons.person, color: primary),
              ),
            ),
            title: Row(
              children: [
                Text(
                  'User Name',
                  style: AppTheme.textStyleLabel.copyWith(color: textColor),
                ),
                const SizedBox(width: 4),
                Icon(Icons.verified, size: 14, color: primary),
              ],
            ),
            subtitle: Text(
              '2h ago',
              style: TextStyle(color: textSecondaryColor),
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_horiz, color: textSecondaryColor),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exciting news! Just launched a new feature in DelConnect! 🚀\n\nWhat do you think about it? Share your thoughts below! #innovation #tech',
                  style:
                      AppTheme.textStyleSubheading.copyWith(color: textColor),
                ),
                if (index % 2 == 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: isDark
                            ? AppTheme.gradientDark
                            : AppTheme.gradientLight,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.image, size: 48, color: primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildActionButton(
                        CupertinoIcons.heart, '24K', textSecondaryColor),
                    const SizedBox(width: 16),
                    _buildActionButton(
                        CupertinoIcons.chat_bubble, '1.2K', textSecondaryColor),
                  ],
                ),
                _buildActionButton(
                    CupertinoIcons.share, 'Share', textSecondaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final textSecondaryColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final primary = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.pastelBlue, AppTheme.pastelIndigo],
                    ).createShader(bounds),
                    child: Text(
                      'DelConnect',
                      style: AppTheme.textStyleHeading.copyWith(
                        color: textColor,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(CupertinoIcons.heart, color: textColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.chat_bubble, color: textColor),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: () async {
          // Add refresh logic here
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) => _buildStoryAvatar(
                    index,
                    primary,
                    surfaceColor,
                    textSecondaryColor,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPost(context, index, isDark),
                childCount: 5,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primary,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, CupertinoIcons.home, 'Home'),
                _buildNavItem(1, CupertinoIcons.chat_bubble_2, 'Chats'),
                _buildNavItem(2, CupertinoIcons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? (isDark ? AppTheme.darkText : AppTheme.lightText)
        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary);

    return InkWell(
      onTap: () => _onNavigationTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
