import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/post_service.dart';
import '../constants/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:iconsax/iconsax.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final List<File> _selectedImages = [];
  final PostService _postService = PostService();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _createPost() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 gambar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _postService.createPost(
        caption: _captionController.text.trim(),
        images: _selectedImages,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      (isDark ? Colors.black : Colors.white).withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Iconsax.arrow_left,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Buat Postingan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    _isLoading
                        ? Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? Colors.white : AppTheme.primaryBlue,
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: _selectedImages.isEmpty
                                ? null
                                : () => _createPost(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryBlue,
                            ),
                            child: Text(
                              'Bagikan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _selectedImages.isEmpty
                                    ? (isDark ? Colors.white60 : Colors.black38)
                                    : AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected Images
                      Container(
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildAddImageButton(isDark),
                            ..._selectedImages.asMap().entries.map(
                                  (entry) =>
                                      _buildSelectedImage(entry.key, isDark),
                                ),
                          ],
                        ),
                      ),

                      // Caption Input
                      Container(
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _captionController,
                          maxLines: 5,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tulis caption...',
                            hintStyle: TextStyle(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
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

  Widget _buildAddImageButton(bool isDark) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Iconsax.add,
          color: isDark ? Colors.white70 : Colors.black54,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSelectedImage(int index, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(_selectedImages[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImages.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
