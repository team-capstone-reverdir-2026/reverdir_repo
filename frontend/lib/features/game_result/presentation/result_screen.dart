import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../manitto_game/data/game_repository.dart';
import '../widgets/report_personal.dart';
import '../widgets/report_reveal.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _controller = PageController();
  final _repo = const GameRepository();
  int _index = 0;
  bool _loading = true;
  String? _error;
  ManittoPersonData? _myManitto;
  List<ManittoChainData> _chain = const [];
  PersonalReportData? _report;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결과 리포트')),
      body: DoodleBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: AppTextStyles.bodyMedium))
                : Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                children: [
                  ReportReveal(
                    myManitto: _myManitto!,
                    chain: _chain,
                    onNext: () => _controller.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  ReportPersonal(report: _report!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _index == i ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _index == i ? AppColors.CRed : AppColors.CBrown,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reveal = await _repo.fetchRevealResult(widget.roomId);
      final report = await _repo.fetchMyReport(widget.roomId);
      if (!mounted) return;
      setState(() {
        _myManitto = reveal.$1;
        _chain = reveal.$2;
        _report = report;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'API 호출/응답 문제: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
