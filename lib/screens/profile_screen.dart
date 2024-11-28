import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.bell, color: textColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(CupertinoIcons.settings, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.pastelBlue,
                              AppTheme.pastelIndigo
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: surfaceColor,
                          child: CircleAvatar(
                            radius: 47,
                            backgroundColor: primary.withOpacity(0.1),
                            child: Icon(CupertinoIcons.person_fill,
                                size: 50, color: primary),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: AppTheme.textStyleHeading.copyWith(
                      color: textColor,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@johndoe',
                    style: TextStyle(color: textSecondaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Software Developer | Flutter Enthusiast',
                    style: TextStyle(color: textSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1), // Divider
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Posts', '245', textColor, textSecondaryColor),
                  _buildStat('Following', '851', textColor, textSecondaryColor),
                  _buildStat(
                      'Followers', '1.2K', textColor, textSecondaryColor),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) => _buildPostItem(
                context,
                index,
                isDark,
                textColor,
                textSecondaryColor,
                primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
      String label, String value, Color textColor, Color secondaryColor) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.textStyleHeading.copyWith(
            color: textColor,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: secondaryColor),
        ),
      ],
    );
  }

  Widget _buildPostItem(BuildContext context, int index, bool isDark,
      Color textColor, Color secondaryColor, Color primary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: isDark ? AppTheme.elevatedCardDark : AppTheme.elevatedCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index % 2 == 0)
            Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors:
                      isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
                ),
              ),
              child: Center(
                child: Icon(Icons.image, size: 48, color: primary),
              ),
            ),
          Text(
            'Post caption #${index + 1}',
            style: TextStyle(color: textColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${2 + index}h ago',
                style: TextStyle(color: secondaryColor, fontSize: 12),
              ),
              const Spacer(),
              Icon(CupertinoIcons.heart, size: 16, color: secondaryColor),
              const SizedBox(width: 4),
              Text('${24 + index}', style: TextStyle(color: secondaryColor)),
              const SizedBox(width: 16),
              Icon(CupertinoIcons.chat_bubble, size: 16, color: secondaryColor),
              const SizedBox(width: 4),
              Text('${5 + index}', style: TextStyle(color: secondaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}
