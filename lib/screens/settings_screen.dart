import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/app_theme.dart';
import 'dart:ui';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Iconsax.arrow_left,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Pengaturan',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: _buildSettingsList(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(bool isDark) {
    final List<Map<String, dynamic>> settingsItems = [
      {
        'icon': Iconsax.user,
        'title': 'Edit Profil',
        'subtitle': 'Ubah informasi profil Anda',
      },
      {
        'icon': Iconsax.security_user,
        'title': 'Privasi dan Keamanan',
        'subtitle': 'Kelola pengaturan privasi akun',
      },
      {
        'icon': Iconsax.notification,
        'title': 'Notifikasi',
        'subtitle': 'Atur preferensi notifikasi',
      },
      {
        'icon': Iconsax.colorfilter,
        'title': 'Tampilan',
        'subtitle': 'Sesuaikan tema dan tampilan',
      },
      {
        'icon': Iconsax.shield_tick,
        'title': 'Keamanan Akun',
        'subtitle': 'Verifikasi dua langkah & keamanan',
      },
      {
        'icon': Iconsax.info_circle,
        'title': 'Tentang',
        'subtitle': 'Informasi aplikasi & kebijakan',
      },
      {
        'icon': Iconsax.logout,
        'title': 'Keluar',
        'subtitle': 'Keluar dari akun Anda',
        'isLogout': true,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: settingsItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'],
                  color: item['isLogout'] == true
                      ? Colors.red
                      : (isDark ? Colors.white : Colors.black),
                  size: 20,
                ),
              ),
              title: Text(
                item['title'],
                style: TextStyle(
                  color: item['isLogout'] == true
                      ? Colors.red
                      : (isDark ? Colors.white : Colors.black),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item['subtitle'],
                style: TextStyle(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                Iconsax.arrow_right_3,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                size: 16,
              ),
              onTap: () {
                // Implement settings actions here
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
