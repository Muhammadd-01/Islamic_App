import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/data/repositories/questions_repository.dart';
import 'package:islamic_app/presentation/qa/qa_provider.dart';
import 'package:islamic_app/presentation/widgets/app_snackbar.dart';
import 'package:intl/intl.dart';

class QAScreen extends ConsumerStatefulWidget {
  const QAScreen({super.key});

  @override
  ConsumerState<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends ConsumerState<QAScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _questionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(questionsRepositoryProvider)
          .postQuestion(_questionController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        _questionController.clear();
        AppSnackbar.showSuccess(context, 'Question posted successfully! ✨');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to post question');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showAskDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ask Question',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.question_answer,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Ask Community'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _questionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'What would you like to ask?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGold,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your question will be posted anonymously',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _questionController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setButtonState) {
                    return ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text('Post Question'),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Assistant'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'AI Chat'),
            Tab(text: 'Community Q&A'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _AIChatView(),
          _CommunityQAView(onAsk: _showAskDialog),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _showAskDialog,
              backgroundColor: AppColors.primaryGold,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Ask Question',
                style: TextStyle(color: Colors.black),
              ),
            ).animate().scale(delay: 200.ms)
          : null,
    );
  }
}

class _AIChatView extends ConsumerWidget {
  const _AIChatView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(qaProvider);
    final isLoading = ref.watch(qaLoadingProvider);
    final textController = TextEditingController();

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ask any religious question',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ).animate().fade().scale(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? AppColors.primaryGold
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: msg.isUser
                                ? const Radius.circular(0)
                                : null,
                            bottomLeft: !msg.isUser
                                ? const Radius.circular(0)
                                : null,
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.black : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(color: AppColors.primaryGold),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Ask AI...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(qaProvider.notifier).sendMessage(value);
                      textController.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primaryGold),
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    ref
                        .read(qaProvider.notifier)
                        .sendMessage(textController.text);
                    textController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommunityQAView extends ConsumerStatefulWidget {
  final VoidCallback onAsk;

  const _CommunityQAView({required this.onAsk});

  @override
  ConsumerState<_CommunityQAView> createState() => _CommunityQAViewState();
}

class _CommunityQAViewState extends ConsumerState<_CommunityQAView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsStreamProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search questions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // Questions List
        Expanded(
          child: questionsAsync.when(
            data: (questions) {
              final filtered = _searchQuery.isEmpty
                  ? questions
                  : questions.where((q) {
                      final query = _searchQuery.toLowerCase();
                      return q.question.toLowerCase().contains(query) ||
                          (q.answer?.toLowerCase().contains(query) ?? false);
                    }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.forum_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No questions yet'
                            : 'No results for "$_searchQuery"',
                      ),
                      const SizedBox(height: 8),
                      if (_searchQuery.isEmpty)
                        ElevatedButton(
                          onPressed: widget.onAsk,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Ask First Question'),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final q = filtered[index];
                  return _QuestionCard(question: q, index: index);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int index;

  const _QuestionCard({required this.question, required this.index});

  void _copyAnswer(BuildContext context) {
    final content =
        '''
ISLAMIC Q&A

Question:
${question.question}

${question.status == 'answered' && question.answer != null ? '''
Answer:
${question.answer}

Asked on: ${DateFormat.yMMMd().format(question.createdAt)}
''' : 'Status: Pending Answer'}

---
DeenSphere Islamic App
''';

    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Answer copied to clipboard!'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          question.question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                question.status == 'answered'
                    ? Icons.check_circle
                    : Icons.schedule,
                size: 14,
                color: question.status == 'answered'
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                question.status == 'answered' ? 'Answered' : 'Pending',
                style: TextStyle(
                  color: question.status == 'answered'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat.yMMMd().format(question.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        children: [
          if (question.status == 'answered' && question.answer != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green.withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Answer:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyAnswer(context),
                        tooltip: 'Copy Answer',
                        color: AppColors.primaryGold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(question.answer!),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Waiting for an answer from scholars...',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    ).animate().fade().slideY(
      begin: 0.1,
      end: 0,
      delay: Duration(milliseconds: index * 50),
    );
  }
}
