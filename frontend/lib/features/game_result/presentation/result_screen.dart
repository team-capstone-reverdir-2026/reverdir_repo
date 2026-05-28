import 'package:flutter/material.dart';

import '../../../core/network/api_error_tracker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
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
  bool _loadingReveal = true;
  bool _loadingReport = false;
  String? _error;
  ManittoPersonData? _myManitto;
  List<ManittoChainData> _chain = const [];
  PersonalReportData? _report;
  String? _reportError;

  @override
  void initState() {
    super.initState();
    _loadReveal();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결과 리포트'),
        leading: const AppBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: DoodleBackground(
        child: _loadingReveal
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: AppTextStyles.bodyMedium))
                : Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _controller,
                          onPageChanged: (value) {
                            setState(() => _index = value);
                            if (value == 1 &&
                                _report == null &&
                                !_loadingReport) {
                              _loadPersonalReport();
                            }
                          },
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
                            _buildPersonalPage(),
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
                                color: _index == i
                                    ? AppColors.CRed
                                    : AppColors.CBrown,
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

  Widget _buildPersonalPage() {
    if (_loadingReport) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI가 리포트를 작성 중이에요…\n최대 5분 정도 걸릴 수 있어요.'),
          ],
        ),
      );
    }
    if (_reportError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_reportError!, style: AppTextStyles.bodyMedium),
        ),
      );
    }
    if (_report == null) {
      return const SizedBox.shrink();
    }
    return ReportPersonal(report: _report!);
  }

  Future<void> _loadReveal() async {
    setState(() {
      _loadingReveal = true;
      _error = null;
    });
    try {
      final reveal = await _repo.fetchRevealResult(widget.roomId);
      if (!mounted) return;
      setState(() {
        _myManitto = reveal.$1;
        _chain = reveal.$2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = ApiErrorTracker.userMessage(e));
    } finally {
      if (mounted) setState(() => _loadingReveal = false);
    }
  }

  Future<void> _loadPersonalReport() async {
    setState(() {
      _loadingReport = true;
      _reportError = null;
    });
    try {
      final report = await _repo.fetchMyReport(widget.roomId);
      if (!mounted) return;
      setState(() => _report = report);
    } catch (e) {
      if (!mounted) return;
      setState(() => _reportError = 'AI 리포트를 불러오지 못했어요: $e');
    } finally {
      if (mounted) setState(() => _loadingReport = false);
    }
  }
}
