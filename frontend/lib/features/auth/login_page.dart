import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/paper_text_field.dart';
import 'auth_api.dart';
import 'register_page.dart';
import '../rooms/main_room_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> handleLogin() async {
    setState(() => isLoading = true);

    final success = await AuthApi.login(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainRoomPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디 또는 비밀번호를 확인해 주세요')),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget sticker(String text, double x, double y, double size) {
    return Positioned(
      left: x,
      top: y,
      child: Text(
        text,
        style: TextStyle(fontSize: size),
      ),
    );
  }

  Widget doodleUnderline() {
    return SizedBox(
      width: 135,
      height: 14,
      child: CustomPaint(
        painter: _DoodleUnderlinePainter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final appWidth = constraints.maxWidth > 900
                  ? 620.0
                  : constraints.maxWidth > 600
                      ? constraints.maxWidth * 0.62
                      : constraints.maxWidth * 0.9;

              return SizedBox(
                width: appWidth,
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      sticker('⭐', appWidth * 0.79, 58, 19),
                      sticker('🎈', appWidth * 0.10, 80, 21),
                      sticker('✨', appWidth * 0.07, 164, 18),
                      sticker('🎁', appWidth * 0.78, 198, 20),
                      sticker('🎀', appWidth * 0.15, 260, 20),
                      sticker('🍅', appWidth * 0.80, 340, 46),
                      sticker('💗', appWidth * 0.10, 520, 18),
                      sticker('🧸', appWidth * 0.05, 580, 20),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 52, 20, 30),
                        child: Column(
                          children: [
                            const SizedBox(height: 48),

                            const Text(
                              '🍅',
                              style: TextStyle(fontSize: 82),
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              '또마니또',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 5,
                                color: AppColors.text,
                              ),
                            ),

                            const SizedBox(height: 10),

                            doodleUnderline(),

                            const SizedBox(height: 70),

                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  PaperTextField(
                                    controller: usernameController,
                                    hint: '아이디',
                                  ),
                                  const SizedBox(height: 16),
                                  PaperTextField(
                                    controller: passwordController,
                                    hint: '비밀번호',
                                    obscureText: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 42),

                            SizedBox(
                              height: 62,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tomato,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  shadowColor: Colors.black.withOpacity(0.18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  isLoading ? '로그인 중...' : '로그인 😄',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text.rich(
                                TextSpan(
                                  text: '계정이 없으신가요? ',
                                  style: TextStyle(
                                    color: AppColors.subText,
                                    fontSize: 18,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '회원가입',
                                      style: TextStyle(
                                        color: AppColors.tomato,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 34),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DoodleUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.tomato
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.25,
        size.width * 0.55,
        size.height * 0.85,
        size.width,
        size.height * 0.45,
      );

    canvas.drawPath(path, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.08, size.height * 0.75)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.95,
        size.width * 0.62,
        size.height * 0.45,
        size.width * 0.92,
        size.height * 0.7,
      );

    canvas.drawPath(path2, paint..strokeWidth = 1.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}