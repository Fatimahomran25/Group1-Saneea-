import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}
class _IntroScreenState extends State<IntroScreen> {
  // مقاسات من Figma (اdp)
  static const double _logoW = 250;
  static const double _logoH = 300;
  static const double _textW = 300;
  static const double _textH = 86;
 @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signup');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            Image.asset(
              'assets/LOGO.png',
              width: _logoW,
              height: _logoH,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),

            // Text Saneea (Gradient مثل فيقما)
            SizedBox(
              width: _textW,
              height: _textH,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFF4F378B),
                      Color(0xFF8F3F78),
                      Color(0xFF5A3888),
                      Color(0xFFA24272),
                    ],
                  ).createShader(bounds);
                },
                child: const Text(
                  'Saneea',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSerifDisplay',
                    fontSize: 80, // نفس فيقما
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                    color: Colors.white, // لازم مع ShaderMask
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // زر يبدأ (ينقل للـ Signup)
            
          ],
        ),
      ),
    );
  }
}
  
