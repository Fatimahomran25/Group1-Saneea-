import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controlles/login_controller.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

final LoginController c = LoginController();

  @override
  void dispose() {
    c.dispose();
    super.dispose(); 
      }
static const _bg = Colors.white;
static const _fieldFill = Color(0x5CE8DEF8);
static const _btnBlue = Color(0xFF467FFF);
static const _textBlack = Color(0xFF000000);
static const _primaryPurple = Color(0xFF4F378B);

static const double _smallBoxH = 46;
static const double _radiusField = 5;
static const double _radiusButton = 10;
static const double _logoW = 112;
static const double _logoH = 128;
static const double _logoRadius = 33;

  @override
  Widget build(BuildContext context) {

 final screenW = MediaQuery.of(context).size.width;
final formW = (screenW * 0.88).clamp(280.0, 420.0);

   return Scaffold(
backgroundColor: _bg,
  body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30), //ارتفاع اللوقو

            ClipRRect(
              borderRadius: BorderRadius.circular(33),
              child: Image.asset(
                'assets/LOGO.png',
                width: 112,
                height: 128,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 6),

            ShaderMask(
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
              child:  Text(
                'Saneea',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSerifDisplay',
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                  color: Colors.white,
                ),
              ),
            ),
            
const SizedBox(height: 22),

SizedBox(
  width: formW,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'National ID / Iqama',
        style: TextStyle(
          fontFamily: 'DMSerifDisplay',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: _textBlack,
        ),
      ),
      const SizedBox(height: 8),

      SizedBox(
        height: _smallBoxH,
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters:  [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: _fieldFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radiusField),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),

SizedBox(
  width: formW,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Password',
        style: TextStyle(
          fontFamily: 'DMSerifDisplay',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: _textBlack,
        ),
      ),
      const SizedBox(height: 8),

      SizedBox(
        height: _smallBoxH,
        child: TextFormField(
          obscureText: true, // نخليه مخفي مؤقتاً
          decoration: InputDecoration(
            filled: true,
            fillColor: _fieldFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radiusField),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            final v = value ?? '';
            if (v.isEmpty) return 'Required';
            if (v.length != 13) return 'Must be exactly 13 characters';

            final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
            final hasDigit = RegExp(r'\d').hasMatch(v);
            final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(v);

            if (!hasLetter) return 'Must include at least one letter';
            if (!hasDigit) return 'Must include at least one number';
            if (!hasSpecial) return 'Must include at least one special character';
            return null;
          },
        ),
      ),
    ],
  ),
),
    ],
    
  ),
),
          ],
        ),
      ),
    ),
  ),
),

);
  }
}
