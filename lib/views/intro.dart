import 'package:flutter/material.dart';

/// IntroScreen
/// This screen functions as the application's splash screen.
/// It displays the app logo and brand name,
/// then automatically navigates to the signup screen after 3 seconds.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  /// Logo width in logical pixels
  static const double _logoW = 250;

  /// Logo height in logical pixels
  static const double _logoH = 300;

  /// Brand text container width
  static const double _textW = 300;

  /// Brand text container height
  static const double _textH = 86;

  @override
  void initState() {
    super.initState();

    /// Delays navigation for 2 seconds to simulate splash behavior.
    /// After the delay, the screen is replaced with the signup screen.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // Prevents navigation if widget is disposed
      Navigator.pushReplacementNamed(context, '/signup');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Sets the background color of the intro screen
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          /// Vertically centers content
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Application logo
            Image.asset(
              'assets/LOGO.png',
              width: _logoW,
              height: _logoH,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 18),

            /// Brand name with gradient styling
            SizedBox(
              width: _textW,
              height: _textH,
              child: ShaderMask(
                /// Applies a linear gradient effect to the text
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
                    fontSize: 80,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                    color: Colors.white, // Required for ShaderMask
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
