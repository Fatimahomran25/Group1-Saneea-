import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controlles/login_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                            fontSize: 17,
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

            
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(     onTap: () {
Navigator.pushNamed(context, '/forgotPassword');
                        
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
                           onPressed: c.isLoading ? null : () async {
        FocusScope.of(context).unfocus(); // يقفل الكيبورد

        setState(() => c.submit());
final nid = c.nationalIdCtrl.text.trim();

setState(() {
  c.nationalIdError = null;
  c.passwordError = null;
});

        if (nid.length != 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a 10-digit National ID / Iqama.')),
          );
          return;
        }
         if (nid.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter your National ID / Iqama.')),
          );
          return;
        }

        if (c.passwordCtrl.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Enter your password.')),
  );
  return;
}
final role = await c.loginAndGetRole();
setState(() {});

if (role == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(c.serverError ?? 'Login failed')),
  );
  return;
}

if (role == 'admin') {
  Navigator.pushReplacementNamed(context, '/adminHome');
} else if (role == 'freelancer') {
  Navigator.pushReplacementNamed(context, '/freelancerHome');
} else {
  Navigator.pushReplacementNamed(context, '/clientHome');
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