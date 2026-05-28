import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../../core/widgets/washi_tape.dart';
import '../../manitto_game/data/game_repository.dart';
import 'widgets/hint_blur.dart';

class HintCollectScreen extends StatefulWidget {
  const HintCollectScreen({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<HintCollectScreen> createState() => _HintCollectScreenState();
}

class _HintCollectScreenState extends State<HintCollectScreen> {
  final _repo = const GameRepository();
  bool _loading = true;
  String? _error;
  List<QuestionHistoryData> _history = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final history = await _repo.fetchQuestionHistory(widget.roomId);
      if (!mounted) return;
      setState(() => _history = history..sort((a, b) => b.date.compareTo(a.date)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'API 호출/응답 문제: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('힌트 답변 모음')),
      body: DoodleBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: AppTextStyles.bodyMedium))
                : ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemCount: _history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final item = _history[index];
            return Transform.rotate(
              angle: index.isEven ? -0.014 : 0.014,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? AppColors.CYellow.withValues(alpha: 0.34)
                          : AppColors.CSkyBlue.withValues(alpha: 0.24),
                      borderRadius: AppTheme.borderRadius,
                      border: AppTheme.handDrawnBorder(
                        color: index.isEven
                            ? AppColors.COrange
                            : AppColors.CSkyBlue,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          DateFormatter.formatApiDate(item.date),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.CTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(item.question, style: AppTextStyles.titleSmall),
                        const SizedBox(height: 14),
                        _AnswerBlock(
                          title: '나의 답변',
                          content: item.myAnswer ?? '이 날은 아직 답변하지 않았어요.',
                          color: AppColors.CYellow,
                        ),
                        const SizedBox(height: 10),
                        item.isBlurred
                            ? HintBlur(
                                child: _AnswerBlock(
                                  title: '마니또 답변',
                                  content: item.manittoAnswer ?? '',
                                  color: AppColors.CSkyBlue,
                                ),
                              )
                            : _AnswerBlock(
                                title: '마니또 답변',
                                content: item.manittoAnswer ?? '마니또가 고민 중이에요.',
                                color: AppColors.CSkyBlue,
                              ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: 26,
                    child: WashiTape.horizontal(
                      color: index.isEven
                          ? WashiTapeColor.orange
                          : WashiTapeColor.blue,
                      width: 80,
                      rotation: index.isEven ? 7 : -7,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnswerBlock extends StatelessWidget {
  const _AnswerBlock({
    required this.title,
    required this.content,
    required this.color,
  });

  final String title;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.CIvory.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: AppTheme.handDrawnBorder(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label.copyWith(color: color)),
          const SizedBox(height: 6),
          Text(content, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
