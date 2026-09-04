import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/repositories/ai_repository.dart';

class ConversationalAiScreen extends StatefulWidget {
  const ConversationalAiScreen({super.key});

  @override
  State<ConversationalAiScreen> createState() => _ConversationalAiScreenState();
}

class _ConversationalAiScreenState extends State<ConversationalAiScreen> {
  final AiRepository _aiRepo = AiRepository();
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final Set<String> _synthesizedSkills = {};
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message from AI Career Agent
    _messages.add({
      'sender': 'agent',
      'text':
          "Hello! I am your HyaUp AI Career Agent. If you don't have a resume handy, no worries! Tell me about your background, tools you've worked with, or what kind of role you're looking for in Cameroon.",
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add({'sender': 'user', 'text': text.trim()});
      _isTyping = true;
    });

    final response = await _aiRepo.sendCareerAgentMessage(
      userMessage: text,
      conversationHistory: _messages,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'sender': 'agent',
          'text': response['reply'] ?? "I've noted that in your candidate profile.",
        });

        if (response['suggested_skills'] is List) {
          _synthesizedSkills.addAll(
            (response['suggested_skills'] as List).map((e) => e.toString()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI Career Intake", style: AppTypography.titleMedium),
                Text(
                  "Conversational Vector Profiler",
                  style: AppTypography.bodySmall.copyWith(color: AppColors.emerald, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Extracted Skills Strip (if any)
          if (_synthesizedSkills.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.background,
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text("Vector Skills: ", style: AppTypography.labelSmall),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _synthesizedSkills.map((skill) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              skill,
                              style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.primaryDark),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      border: isUser ? null : Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isUser ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "AI Career Agent is analyzing...",
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
              ),
            ),

          // Quick Prompts row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildPromptChip("I build Flutter apps with Firebase"),
                _buildPromptChip("Python FastAPI & SQL experience"),
                _buildPromptChip("Looking for Douala or Remote roles"),
              ],
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: "Describe your skills or experience...",
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: () => _sendMessage(_inputController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String prompt) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(prompt),
        labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.primary),
        backgroundColor: AppColors.primaryContainer,
        side: BorderSide.none,
        onPressed: () => _sendMessage(prompt),
      ),
    );
  }
}
