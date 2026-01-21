import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/domain/entities/hadith.dart';
import 'package:islamic_app/data/repositories/bookmark_repository.dart';
import 'package:islamic_app/domain/entities/bookmark.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';

class HadithDetailScreen extends ConsumerStatefulWidget {
  final Hadith hadith;

  const HadithDetailScreen({super.key, required this.hadith});

  @override
  ConsumerState<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends ConsumerState<HadithDetailScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  String _selectedLanguage = 'en-US';
  bool _isArabic = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en-US', 'name': 'English'},
    {'code': 'ar-SA', 'name': 'العربية'},
    {'code': 'ur-PK', 'name': 'اردو'},
    {'code': 'tr-TR', 'name': 'Türkçe'},
    {'code': 'id-ID', 'name': 'Indonesian'},
    {'code': 'ms-MY', 'name': 'Malay'},
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(_selectedLanguage);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speak() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _tts.setLanguage(_selectedLanguage);
      final text = _isArabic ? widget.hadith.arabic : widget.hadith.english;
      await _tts.speak(text);
      setState(() => _isSpeaking = true);
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: AppColors.primaryGold),
                const SizedBox(width: 12),
                const Text(
                  'Select Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _languages.map((lang) {
                final isSelected = lang['code'] == _selectedLanguage;
                return ChoiceChip(
                  label: Text(lang['name']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedLanguage = lang['code']!);
                    _tts.setLanguage(_selectedLanguage);
                    Navigator.pop(context);
                    AppSnackbar.showInfo(context, 'Language: ${lang['name']}');
                  },
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Arabic/Translation toggle
            SwitchListTile(
              title: const Text('Read Arabic'),
              subtitle: const Text('Switch between Arabic and translation'),
              value: _isArabic,
              activeColor: AppColors.primaryGold,
              onChanged: (value) {
                setState(() => _isArabic = value);
                if (_isArabic) {
                  _tts.setLanguage('ar-SA');
                } else {
                  _tts.setLanguage(_selectedLanguage);
                }
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _shareHadith() {
    final text =
        '''
${widget.hadith.book} - Hadith ${widget.hadith.id}
${widget.hadith.chapter ?? ''}

Arabic:
${widget.hadith.arabic}

Translation:
${widget.hadith.english}

- Shared via DeenSphere
''';
    Clipboard.setData(ClipboardData(text: text));
    AppSnackbar.showSuccess(context, 'Hadith copied to clipboard! 📋');
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hadith.book} - ${widget.hadith.id}'),
        actions: [
          // Language selector
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
            tooltip: 'Change language',
          ),
          // Bookmark button
          Consumer(
            builder: (context, ref, child) {
              final bookmarksAsync = ref.watch(bookmarksStreamProvider);
              final isBookmarked = bookmarksAsync.maybeWhen(
                data: (bookmarks) => bookmarks.any(
                  (b) =>
                      b.id == widget.hadith.id.toString() && b.type == 'hadith',
                ),
                orElse: () => false,
              );

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.primaryGold : null,
                ),
                onPressed: () async {
                  final repo = ref.read(bookmarkRepositoryProvider);
                  if (isBookmarked) {
                    await repo.removeBookmark(
                      widget.hadith.id.toString(),
                      'hadith',
                    );
                    if (context.mounted) {
                      AppSnackbar.showInfo(context, 'Removed from bookmarks');
                    }
                  } else {
                    final bookmark = Bookmark(
                      id: widget.hadith.id.toString(),
                      type: 'hadith',
                      title:
                          '${widget.hadith.book} - Hadith ${widget.hadith.id}',
                      subtitle: widget.hadith.chapter ?? '',
                      content: widget.hadith.english.length > 150
                          ? '${widget.hadith.english.substring(0, 150)}...'
                          : widget.hadith.english,
                      route:
                          '/hadith/${widget.hadith.book}/${widget.hadith.id}',
                      timestamp: DateTime.now(),
                    );
                    await repo.addBookmark(bookmark);
                    if (context.mounted) {
                      AppSnackbar.showSuccess(context, 'Added to bookmarks ✨');
                    }
                  }
                },
                tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
              );
            },
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareHadith,
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chapter header
            if (widget.hadith.chapter != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  widget.hadith.chapter!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fade().slideY(begin: -0.1, end: 0),

            // Audio controls
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  // Play/Stop button
                  GestureDetector(
                        onTap: _speak,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: _isSpeaking
                                ? AppColors.goldTileGradient
                                : null,
                            color: _isSpeaking
                                ? null
                                : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isSpeaking ? Icons.stop : Icons.volume_up,
                            color: _isSpeaking
                                ? Colors.black
                                : AppColors.primaryGold,
                          ),
                        ),
                      )
                      .animate(target: _isSpeaking ? 1 : 0)
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                      ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSpeaking ? 'Playing...' : 'Listen to Hadith',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isArabic ? 'Arabic' : 'Translation',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Language button
                  IconButton(
                    icon: const Icon(Icons.translate),
                    color: AppColors.primaryGold,
                    onPressed: _showLanguageSelector,
                    tooltip: 'Language options',
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1, end: 0),

            // Hadith content
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.hadith.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 24,
                      height: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    widget.hadith.english,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ],
              ),
            ).animate().fade().scale(
              begin: const Offset(0.98, 0.98),
              end: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}
