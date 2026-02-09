
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers (جاهزة للتكملة: فحص/فاييربيس)
  final _nationalIdCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nationalIdCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ألوان من تصميمك
  static const _bg = Colors.white;
  static const _fieldFill = Color(0xFFF1F3FF); // نفس اللي ظاهر عندك
  static const _btnBlue = Color(0xFF467FFF);
  static const _textBlack = Color(0xFF000000);

  // مقاسات من Figma
  static const double _logoSize = 142;
  static const double _smallBoxH = 46;
  static const double _radiusField = 5;
  static const double _radiusButton = 10;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final formW = (screenW * 0.88).clamp(280.0, 420.0); // عرض الفورم
    final gap = 12.0;
    final halfW = (formW - gap) / 2;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 90, 36, 36),
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // LOGO (142x142)
                  Image.asset(
                    'assets/LOGO.png',
                    width: _logoSize,
                    height: _logoSize,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 18),

                  // National ID / Iqama (Group height 73)
                  _LabeledField(
                    label: 'National ID / Iqama',
                    width: formW,

                    boxHeight: 46,
                    controller: _nationalIdCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // First name + Last name (two boxes 160x46)
                  SizedBox(
  width: formW,
  child: Row(
    children: [
      _LabeledField(
        label: 'First name',
        width: halfW,
        boxHeight: _smallBoxH,
        controller: _firstNameCtrl,
        fillColor: _fieldFill,
        radius: _radiusField,
      ),
      SizedBox(width: gap),
      _LabeledField(
        label: 'Last name',
        width: halfW,
        boxHeight: _smallBoxH,
        controller: _lastNameCtrl,
        fillColor: _fieldFill,
        radius: _radiusField,
      ),
    ],
  ),
),

                  

                  const SizedBox(height: 16),

                  // Email address
                  _LabeledField(
                    label: 'Email address',
                    width: formW,

                    boxHeight: 46,
                    controller: _emailCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Password
                  _LabeledField(
                    label: 'Password',
                    width: formW,

                    boxHeight: 46,
                    controller: _passwordCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  // Confirm password
                  _LabeledField(
                    label: 'Confirm password',
                    width: formW,

                    boxHeight: 46,
                    controller: _confirmPasswordCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    obscureText: true,
                  ),

                  const SizedBox(height: 22),

                  // Create Account button (339x52, radius 10, color #467FFF)
                  SizedBox(
                    width: formW,

                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onCreateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _btnBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_radiusButton),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.25),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: _fieldFill, // نفس Figma (#F1F3FF)
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Have an account already? Log in (width 258 height 17 تقريبًا)
                  SizedBox(
                    width: formW,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: _textBlack,
                          ),
                          children: [
                            const TextSpan(text: 'Have an account already? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: _onLoginTap,
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: _btnBlue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onCreateAccount() {
    // TODO: هنا تكملين:
    // - Validation
    // - Firebase Auth createUserWithEmailAndPassword
    // - Save user data (NationalID, names) in Firestore
  }

  void _onLoginTap() {
    // TODO: روحي لصفحة Login
    // Navigator.pushNamed(context, '/login');
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.width,
    required this.boxHeight,
    required this.controller,
    required this.fillColor,
    required this.radius,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final double width;
  final double boxHeight;
  final TextEditingController controller;
  final Color fillColor;
  final double radius;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
       width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),

SizedBox(
  height: boxHeight,
  child: Container(
    decoration: BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(radius),
      border: const Border(
        bottom: BorderSide(
          color: Colors.black,
          width: 0.5, // نفس Figma
        ),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.centerLeft,
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: const InputDecoration(
        border: InputBorder.none, // مهم جدًا
        isDense: true,
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
