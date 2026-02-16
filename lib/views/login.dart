import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controlles/login_controller.dart';
import 'signup.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final LoginController c = LoginController();
  final _nidFocus = FocusNode();
  final _passFocus = FocusNode();

  static const _bg = Colors.white;
  static const _fieldFill = Color(0x5CE8DEF8);
  static const _textBlack = Color(0xFF000000);
  static const _primaryPurple = Color(0xFF4F378B);

  static const double _smallBoxH = 46;
  static const double _radiusField = 5;
  static const double _radiusButton = 10;

  @override
  void initState() {
    super.initState();
    _nidFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nidFocus.dispose();
    _passFocus.dispose();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final formW = (screenW * 0.88).clamp(280.0, 420.0);

    final showPassRules = _passFocus.hasFocus ||
        (c.passwordCtrl.text.isNotEmpty && !c.isPasswordValid) ||
        (c.submitted && !c.isPasswordValid);

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
                  const SizedBox(height: 30),

                  // LOGO
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

                  // Title
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
                    child: const Text(
                      'Saneea',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSerifDisplay',
                        fontSize: 36,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ===== National ID / Iqama =====
                  SizedBox(
                    width: formW,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          /*'National ID / Iqama',
                          style: TextStyle(
                            fontFamily: 'DMSerifDisplay',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: _textBlack,*/
                              'National ID / Iqama',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        SizedBox(
                          height: _smallBoxH,
                          child: TextFormField(
                            controller: c.nationalIdCtrl,
                            focusNode: _nidFocus,
                            onChanged: (_) => setState(() {}),
                            keyboardType: TextInputType.number,
                            inputFormatters:  [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _fieldFill,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(_radiusField),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        if (_nidFocus.hasFocus ||
                            c.nationalIdCtrl.text.isNotEmpty ||
                            c.submitted) ...[
                          const SizedBox(height: 8),

                          // Rule 1: 10 digits
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: c.nationalIdCtrl.text.length == 10
                                    ? Colors.green
                                    : (c.nationalIdCtrl.text.isEmpty
                                        ? Colors.grey
                                        : Colors.red),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Must be exactly 10 digits.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: c.nationalIdCtrl.text.length == 10
                                      ? Colors.green
                                      : (c.nationalIdCtrl.text.isEmpty
                                          ? Colors.grey
                                          : Colors.red),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Rule 2: starts with 1 or 2
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: (c.nationalIdCtrl.text.startsWith('1') ||
                                        c.nationalIdCtrl.text.startsWith('2'))
                                    ? Colors.green
                                    : (c.nationalIdCtrl.text.isEmpty
                                        ? Colors.grey
                                        : Colors.red),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Starts with 1 (ID) or 2 (Iqama).',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: (c.nationalIdCtrl.text.startsWith('1') ||
                                          c.nationalIdCtrl.text.startsWith('2'))
                                      ? Colors.green
                                      : (c.nationalIdCtrl.text.isEmpty
                                          ? Colors.grey
                                          : Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ===== Password =====
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
                            controller: c.passwordCtrl,
                            focusNode: _passFocus,
                            onChanged: (_) => setState(() {}),
                            obscureText: c.obscurePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _fieldFill,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(_radiusField),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
    onPressed: () => setState(() => c.togglePasswordVisibility()),
    icon: Icon(
      c.obscurePassword ? Icons.visibility_off : Icons.visibility,
      color: _primaryPurple,
    ),
                              ),
                            ),
                          ),
                        ),

                        if (showPassRules) ...[
                          const SizedBox(height: 10),
                          _RuleRow(
                              text: 'At least 8 characters', ok: c.hasMinLength),
                          _RuleRow(text: 'Contains a letter', ok: c.hasLetter),
                          _RuleRow(text: 'Contains a number', ok: c.hasNumber),
                          _RuleRow(
                              text: 'Contains a special character',
                              ok: c.hasSpecialChar),
                        ],

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(     onTap: () {
                          Navigator.pushNamed(context, '/signup');
},
  
                            
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF4F378B),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: formW,
                          height: 46,
                          child: ElevatedButton(
                           onPressed: (c.isLoading || !c.allRequiredValid)
    ? null
    : () async {
        FocusScope.of(context).unfocus(); // يقفل الكيبورد

        setState(() => c.submit());

        final success = await c.login();
        setState(() {});

        if (success) {
          Navigator.pushReplacementNamed(context, '/clientHome');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(c.serverError ?? 'Login failed.'),
            ),
          );
        }
      },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple,
                              disabledBackgroundColor:
                                  _primaryPurple.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(_radiusButton),
                              ),
                              elevation: 6,
                            ),
                            child: c.isLoading
    ? const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
    : const Text(
        'Log in',
        style: TextStyle(
         fontFamily: 'DMSerifDisplay',
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),

                          ),
                        ),
                        const SizedBox(height: 12),
Align(
  alignment: Alignment.centerLeft,
  child: Row(
    children: [
      const Text(
        "Doesn’t have an account? ",
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SignupScreen(), 
            ),
          );
        },
        child: const Text(
          "Sign up",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF467FFF),
          ),
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

class _RuleRow extends StatelessWidget {
  final String text;
  final bool ok;
  const _RuleRow({required this.text, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: ok ? Colors.green : Colors.red),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ok ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
