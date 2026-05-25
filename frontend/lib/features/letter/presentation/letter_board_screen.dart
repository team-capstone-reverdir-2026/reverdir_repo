import 'package:flutter/material.dart';

import '../../../core/network/api_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/washi_tape.dart';
import '../../manitto_game/data/mock_game_service.dart';

class LetterBoardScreen extends StatefulWidget {
  const LetterBoardScreen({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<LetterBoardScreen> createState() => _LetterBoardScreenState();
}

class _LetterBoardScreenState extends State<LetterBoardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = MockGameService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('쪽지함'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.CRed,
          unselectedLabelColor: AppColors.CTextTertiary,
          indicatorColor: AppColors.CRed,
          tabs: const [
            Tab(text: '받은 쪽지함'),
            Tab(text: '보낸 쪽지함'),
          ],
        ),
      ),
      body: CustomPaint(
        painter: _CorkBoardPainter(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final selected = await showDateRangePicker(
                    context: context,
                    firstDate: now.subtract(const Duration(days: 60)),
                    lastDate: now.add(const Duration(days: 1)),
                    initialDateRange: _range,
                  );
                  if (selected != null) setState(() => _range = selected);
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  _range == null
                      ? '날짜별 필터'
                      : '${DateFormatter.formatIso8601(_range!.start.toIso8601String())} ~ ${DateFormatter.formatIso8601(_range!.end.toIso8601String())}',
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _LetterList(
                    notes: _filter(service.letters, NoteDirection.received),
                    onOpen: (note) {
                      service.markLetterRead(note.id);
                      _showNoteDetail(note.copyWith(isRead: true));
                      setState(() {});
                    },
                  ),
                  _LetterList(
                    notes: _filter(service.letters, NoteDirection.sent),
                    onOpen: _showNoteDetail,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LetterNote> _filter(List<LetterNote> notes, NoteDirection direction) {
    final filtered = notes.where((note) {
      if (note.direction != direction) return false;
      final range = _range;
      if (range == null) return true;
      return !note.sentAt.isBefore(range.start) &&
          !note.sentAt.isAfter(range.end);
    }).toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return filtered;
  }

  void _showNoteDetail(LetterNote note) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(DateFormatter.formatRelative(note.sentAt.toIso8601String())),
          content: Text(note.content, style: AppTextStyles.bodyMedium),
        );
      },
    );
  }
}

class _LetterList extends StatelessWidget {
  const _LetterList({
    required this.notes,
    required this.onOpen,
  });

  final List<LetterNote> notes;
  final ValueChanged<LetterNote> onOpen;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Text('아직 쪽지가 없어요.', style: AppTextStyles.bodyMedium),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () => onOpen(note),
          child: Transform.rotate(
            angle: index.isEven ? -0.018 : 0.015,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _PaperNote(note: note, color: _paperColor(index)),
                Positioned(
                  top: -9,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: WashiTape.horizontal(
                      color: note.direction == NoteDirection.sent
                          ? WashiTapeColor.pink
                          : WashiTapeColor.blue,
                      width: 70,
                      rotation: index.isEven ? 7 : -7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _paperColor(int index) {
    final palette = [
      AppColors.CYellow.withValues(alpha: 0.82),
      AppColors.CPink.withValues(alpha: 0.72),
      AppColors.CSkyBlue.withValues(alpha: 0.72),
      AppColors.CGreen.withValues(alpha: 0.62),
      AppColors.CIvory,
    ];
    return palette[index % palette.length];
  }
}

class _PaperNote extends StatelessWidget {
  const _PaperNote({
    required this.note,
    required this.color,
  });

  final LetterNote note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final unreadReceived =
        note.direction == NoteDirection.received && !note.isRead;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(unreadReceived ? 10 : 24),
        border: AppTheme.handDrawnBorder(
          color: unreadReceived ? AppColors.COrange : AppColors.CBrown,
          width: unreadReceived ? 2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            unreadReceived ? Icons.drafts_outlined : Icons.note_alt_outlined,
            color: AppColors.CTextSecondary,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatRelative(note.sentAt.toIso8601String()),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 6),
                Text(
                  unreadReceived ? '비밀 쪽지가 도착했어요!' : note.content,
                  style: unreadReceived
                      ? AppTextStyles.bodyMedium
                      : AppTextStyles.bodyMedium.copyWith(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.wavy,
                          decorationColor:
                              AppColors.CTextPrimary.withValues(alpha: 0.20),
                        ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CorkBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.CBrown.withValues(alpha: 0.58),
    );
    final dotPaint = Paint()
      ..color = AppColors.CTextPrimary.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    for (var x = 8.0; x < size.width; x += 18) {
      for (var y = 8.0; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 1.3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
