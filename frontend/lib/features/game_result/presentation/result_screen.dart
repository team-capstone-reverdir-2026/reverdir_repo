import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/doodle_background.dart';
import '../../manitto_game/data/mock_game_service.dart';
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
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = MockGameService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('결과 리포트')),
      body: DoodleBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                children: [
                  ReportReveal(
                    service: service,
                    onNext: () => _controller.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  ReportPersonal(report: service.personalReport),
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
}
