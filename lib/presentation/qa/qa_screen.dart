import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isEmpty) return;

    ref
        .read(questionsRepositoryProvider)
        .postQuestion(_questionController.text.trim());

    Navigator.pop(context);
    _questionController.clear();
    AppSnackbar.showSuccess(context, 'Question posted anonymously');
  }

  void _showAskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask User Community'),
        content: TextField(
          controller: _questionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What is your question?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submitQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Post'),
          ),
        ],
      ),
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
          // AI Chat
          const _AIChatView(),

          // Community Q&A
          _CommunityQAView(onAsk: _showAskDialog),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _showAskDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
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
                              ? AppColors.primary
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
                            color: msg.isUser ? Colors.white : Colors.black87,
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
            child: LinearProgressIndicator(),
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
                icon: const Icon(Icons.send, color: AppColors.primary),
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

class _CommunityQAView extends ConsumerWidget {
  final VoidCallback onAsk;

  const _CommunityQAView({required this.onAsk});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsStreamProvider);

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No questions yet'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onAsk,
                  child: const Text('Ask First Question'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final q = questions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  q.question,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        q.status == 'answered'
                            ? Icons.check_circle
                            : Icons.schedule,
                        size: 14,
                        color: q.status == 'answered'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        q.status == 'answered' ? 'Answered' : 'Pending',
                        style: TextStyle(
                          color: q.status == 'answered'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat.yMMMd().format(q.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                children: [
                  if (q.status == 'answered' && q.answer != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.green.withValues(alpha: 0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Answer:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(q.answer!),
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
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
