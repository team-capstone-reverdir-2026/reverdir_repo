import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/paper_text_field.dart';
import 'auth_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Uint8List? avatarBytes;

  final ImagePicker picker = ImagePicker();

  Future<void> pickAvatar() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      avatarBytes = bytes;
    });
  }

  Future<void> handleRegister() async {
    setState(() {
      isLoading = true;
    });

    final success = await AuthApi.register(
      name: nameController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      avatarBytes: avatarBytes,
      );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입 완료'),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('입력값을 다시 확인해 주세요'),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildAvatarBox() {
    return GestureDetector(
      onTap: pickAvatar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.line,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: avatarBytes == null
                  ? Center(
                      child: Text(
                        '🍅',
                        style: TextStyle(
                          fontSize: 52,
                          color: AppColors.tomato.withOpacity(0.75),
                        ),
                      ),
                    )
                  : Image.memory(
                      avatarBytes!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            right: -5,
            bottom: 3,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.tomato.withOpacity(0.92),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTape(Color color) {
    return Container(
      width: 150,
      height: 22,
      decoration: BoxDecoration(
        color: color.withOpacity(0.75),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 36,
              right: 36,
              child: Text(
                '☁️',
                style: TextStyle(fontSize: 38),
              ),
            ),

            const Positioned(
              top: 92,
              right: 76,
              child: Text(
                '🧸',
                style: TextStyle(fontSize: 22),
              ),
            ),

            const Positioned(
              top: 70,
              left: 85,
              child: Text(
                '✨',
                style: TextStyle(fontSize: 30),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.text,
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                          letterSpacing: 2,
                        ),
                      ),

                      const Spacer(),

                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 34),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 46),
                              padding: const EdgeInsets.fromLTRB(
                                28,
                                76,
                                28,
                                30,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.paper,
                                borderRadius: BorderRadius.circular(34),
                                border: Border.all(
                                  color: AppColors.line.withOpacity(0.55),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '이름 🎀',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  PaperTextField(
                                    controller: nameController,
                                    hint: '20자 미만',
                                  ),

                                  const SizedBox(height: 24),

                                  const Text(
                                    '아이디 🎀',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  PaperTextField(
                                    controller: usernameController,
                                    hint: '4글자 이상 20자 미만',
                                  ),

                                  const SizedBox(height: 24),

                                  const Text(
                                    '비밀번호 🎀',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  PaperTextField(
                                    controller: passwordController,
                                    hint: '4글자 이상 20자 미만',
                                    obscureText: true,
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              top: 32,
                              child: buildTape(AppColors.blue),
                            ),

                            Positioned(
                              top: 0,
                              child: buildAvatarBox(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              isLoading ? '가입 중...' : '가입하기',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}