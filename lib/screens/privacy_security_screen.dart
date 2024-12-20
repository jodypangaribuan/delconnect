import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _isPrivateAccount = false;
  bool _showActivityStatus = true;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark(context);

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
                  'Privasi dan Keamanan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPrivacySection(isDark),
                      const SizedBox(height: 24),
                      _buildSecuritySection(isDark),
                      const SizedBox(height: 24),
                      _buildDataSection(isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.commonCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.lock,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Pengaturan Privasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitch(
            'Akun Privat',
            'Hanya pengikut yang dapat melihat profil Anda',
            _isPrivateAccount,
            (value) => setState(() => _isPrivateAccount = value),
            isDark,
          ),
          _buildSwitch(
            'Status Aktivitas',
            'Tampilkan status online/offline Anda',
            _showActivityStatus,
            (value) => setState(() => _showActivityStatus = value),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.commonCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.shield_tick,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Keamanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitch(
            'Autentikasi Dua Faktor',
            'Tambahan keamanan untuk akun Anda',
            _twoFactorAuth,
            (value) => setState(() => _twoFactorAuth = value),
            isDark,
          ),
          _buildSecurityOption(
            'Ubah Kata Sandi',
            'Perbarui kata sandi akun Anda',
            Iconsax.key,
            isDark,
            () {
              // Implement password change functionality
            },
          ),
          _buildSecurityOption(
            'Perangkat yang Login',
            'Kelola sesi login aktif',
            Iconsax.mobile,
            isDark,
            () {
              // Implement active sessions management
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.commonCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.document,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Data dan Penyimpanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSecurityOption(
            'Unduh Data',
            'Dapatkan salinan data akun Anda',
            Iconsax.document_download,
            isDark,
            () {
              // Implement data download functionality
            },
          ),
          _buildSecurityOption(
            'Hapus Data Cache',
            'Bersihkan data sementara aplikasi',
            Iconsax.trash,
            isDark,
            () {
              // Implement cache clearing functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption(String title, String subtitle,
      IconData trailingIcon, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              trailingIcon,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
