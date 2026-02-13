import 'package:flutter/material.dart';
import '../controlles/signup_controller.dart';
import '../models/signup_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
  
}

class _SignupScreenState extends State<SignupScreen> {
  late final SignupController c;
  AccountType? selectedType;
   final _nidFocus = FocusNode();
  final _firstFocus = FocusNode();
  final _lastFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();
  void _refresh() => setState(() {});


  @override
void initState() {
  super.initState();
  c = SignupController();
  _nidFocus.addListener(_refresh);
  _firstFocus.addListener(_refresh);
  _lastFocus.addListener(_refresh);
  _emailFocus.addListener(_refresh);
  _passFocus.addListener(_refresh);
  _confirmFocus.addListener(_refresh);
}

@override
void dispose() {
   _nidFocus.dispose();
  _firstFocus.dispose();
  _lastFocus.dispose();
  _emailFocus.dispose();
  _passFocus.dispose();
  _confirmFocus.dispose();

  c.dispose();
  super.dispose();
}


  

  // ألوان من تصميمك
  static const _bg = Colors.white;
  static const _fieldFill = Color(0x5CE8DEF8); 
  static const _btnBlue = Color(0xFF467FFF);
  static const _textBlack = Color(0xFF000000);
    static const _primaryPurple = Color(0xFF4F378B);



  // مقاسات من Figma
  

  static const double _smallBoxH = 46;
  static const double _radiusField = 5;
  static const double _radiusButton = 10;
  static const double _logoW = 112;
  static const double _logoH = 128;
  static const double _logoRadius = 33;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final showPasswordRules =
    _passFocus.hasFocus ||
    (c.passwordCtrl.text.isNotEmpty && !c.isPasswordStrong) ||
    (c.submitted && !c.isPasswordStrong);
    final showConfirmRules =
    _confirmFocus.hasFocus ||
    (c.confirmPasswordCtrl.text.isNotEmpty && !c.isConfirmPasswordValid) ||
    (c.submitted && !c.isConfirmPasswordValid);

    
    final formW = (screenW * 0.88).clamp(280.0, 420.0); // عرض الفورم
    final gap = 12.0;
    final halfW = (formW - gap) / 2;
    return Scaffold(
      backgroundColor: _bg,
      
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 14),

                  // LOGO (142x142)
                  ClipRRect(
  borderRadius: BorderRadius.circular(_logoRadius),
  child: Image.asset(
    'assets/LOGO.png',
    width: _logoW,
    height: _logoH,
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
  child: const Text(
    'Saneea',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontFamily: 'DMSerifDisplay',
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.0,
      letterSpacing: 0,
      color: Colors.white, // ضروري مع ShaderMask
    ),
  ),
),

                  
                 

                  const SizedBox(height: 18),
                  
                  if (c.submitted && !c.allRequiredValid)
  Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      'Please complete all required fields.',
      style: const TextStyle(
        color: Colors.red,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    ),
  ),
  if (c.serverError != null)
  Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      c.serverError!,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    ),
  ),


                  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    _AccountTypeButton(
  text: 'Freelancer',
  icon: Icons.person_outline,
  isSelected: selectedType == AccountType.freelancer,
   showErrorBorder: c.submitted && !c.isAccountTypeSelected,
  
  onTap: () {
    setState(() => selectedType = AccountType.freelancer);
    c.setAccountType(AccountType.freelancer);
  },
),
    const SizedBox(width: 12),
    _AccountTypeButton(
  text: 'Client',
  icon: Icons.groups_outlined,
  isSelected: selectedType == AccountType.client,
  showErrorBorder: c.submitted && !c.isAccountTypeSelected,
  
  onTap: () {
    setState(() => selectedType = AccountType.client);
    
    c.setAccountType(AccountType.client);
  },
),

  ],

),
const SizedBox(height: 24),


                  // National ID / Iqama (Group height 73)
                  _LabeledField(
                    label: 'National ID / Iqama',
                    width: formW,
                    showError: c.submitted && !c.isNationalIdValid,
                    hintText: '1012345678',
                    focusNode: _nidFocus,
                    onChanged: _refresh,
                    boxHeight: 46,
                    controller: c.nationalIdCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    keyboardType: TextInputType.number,
                    liveMessage: (!_nidFocus.hasFocus &&
        c.nationalIdCtrl.text.isNotEmpty &&
        !c.isNationalIdValid)
    ? 'Must be 10 digits and start with 1 (ID) or 2 (Iqama).'
    : null,),

                  const SizedBox(height: 16),
 
                  // First name + Last name (two boxes 160x46)
                  SizedBox(
                  width: formW,
                  child: Row(
                  children: [
                 _LabeledField(
                 label: 'First name',
                 width: halfW,
        
        showError: c.submitted && !c.isFirstNameValid,
        hintText: 'Fatimah',
        focusNode: _firstFocus,
        onChanged: _refresh, 

        boxHeight: _smallBoxH,
        controller: c.firstNameCtrl,
        fillColor: _fieldFill,
        radius: _radiusField,
        liveMessage: (!_firstFocus.hasFocus &&
        c.firstNameCtrl.text.isNotEmpty &&
        !c.isFirstNameValid)
    ? 'Only letters, max 15 characters.'
    : null, ),
      SizedBox(width: gap),
      _LabeledField(
        label: 'Last name',
        width: halfW,
        boxHeight: _smallBoxH,
        showError: c.submitted && !c.isLastNameValid,
        hintText: 'Omran',
        focusNode:_lastFocus ,
          onChanged: _refresh, 
        controller: c.lastNameCtrl,

    
        fillColor: _fieldFill,
        radius: _radiusField,
        liveMessage: (!_lastFocus.hasFocus &&
        c.lastNameCtrl.text.isNotEmpty &&
        !c.isLastNameValid)
    ? 'Only letters, max 15 characters.'
    : null,
      ),
    ],
  ),
),

                  

                  const SizedBox(height: 16),

                  // Email address
                  _LabeledField(
                    label: 'Email address',
                    width: formW,
                    showError: c.submitted && !c.isEmailValid,
                    hintText: 'example@gmail.com',
                    focusNode: _emailFocus,
                     onChanged: _refresh,
                    boxHeight: 46,
                    controller: c.emailCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    keyboardType: TextInputType.emailAddress,
                    liveMessage:  (!_emailFocus.hasFocus &&
        c.emailCtrl.text.isNotEmpty &&
        !c.isEmailValid)
    ? 'Please enter a valid Gmail address (example@gmail.com).'
    : null,

                  ),

                  const SizedBox(height: 16),
                
                  // Password
                  
_LabeledField(
  label: 'Password',
  width: formW,
  showError: c.submitted && !c.isPasswordValid,
  hintText: 'example-25',
  focusNode: _passFocus,
  onChanged: _refresh,
  boxHeight: 46,
  controller: c.passwordCtrl,
  fillColor: _fieldFill,
  radius: _radiusField,
  obscureText: true,
),

if (showPasswordRules) ...[
  const SizedBox(height: 8),
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _PasswordRule(
        text: "At least 10 characters",
        isValid: c.hasMinLength,
        isActive: c.passwordCtrl.text.isNotEmpty,
      ),
      _PasswordRule(
        text: "Contains a number",
        isValid: c.hasNumber,
        isActive: c.passwordCtrl.text.isNotEmpty,
      ),
      _PasswordRule(
        text: "Contains a special character",
        isValid: c.hasSpecialChar,
        isActive: c.passwordCtrl.text.isNotEmpty,
      ),
    ],
  ),
],



                  const SizedBox(height: 16),

                  // Confirm password
                  _LabeledField(
                    label: 'Confirm password',
                    width: formW,
                    showError: c.submitted && !c.isConfirmPasswordValid,
                    hintText: 'example-25',
                    focusNode: _confirmFocus,
                    onChanged: _refresh, 
                    
                    boxHeight: 46,
                    controller: c.confirmPasswordCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    obscureText: true,
                    liveMessage: (!_confirmFocus.hasFocus &&
          c.confirmPasswordCtrl.text.isNotEmpty &&
          !c.isConfirmPasswordValid)
      ? 'Passwords do not match.'
      : null,
                  ),if (showConfirmRules) ...[
  const SizedBox(height: 8),
  _PasswordRule(
    text: "Matches password",
    isValid: c.isConfirmPasswordValid,
    isActive: c.confirmPasswordCtrl.text.isNotEmpty,
  ),
],

                  const SizedBox(height: 22),

                  // Create Account button (339x52, radius 10, color #467FFF)
                  SizedBox(
                    width: formW,

                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
  setState(() => c.submit());

  final type = await c.createAccount();
if (type != null) {
  if (type == AccountType.freelancer) {
    Navigator.pushReplacementNamed(context, '/freelancerHome');
  } else {
    Navigator.pushReplacementNamed(context, '/clientHome');
  }
}
  setState(() {}); // عشان serverError يظهر

  if (!mounted) return;
  if (type == null) return; // ❌ لا تنقل إذا فشل

  if (type == AccountType.freelancer) {
    Navigator.pushReplacementNamed(context, '/freelancerHome');
  } else {
    Navigator.pushReplacementNamed(context, '/clientHome');
  }
},


                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
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
                          color: Colors.white, // 
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Have an account already? Log in (width 258 height 17 )
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
                                onTap: () => c.loginTap(context),

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


}

class _LabeledField extends StatelessWidget {
   _LabeledField({
    required this.label,
    required this.width,
    required this.boxHeight,
    required this.controller,
    required this.fillColor,
    required this.radius,
    this.keyboardType,
    required this.showError,
    this.obscureText = false,
    
    required this.focusNode,
    this.hintText,
this.helperText,
    this.liveMessage,
    this.onChanged, 

    
  });

  final String label;
  final double width;
  final double boxHeight;
  final TextEditingController controller;
  final Color fillColor;
  final double radius;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool showError;

  
final FocusNode focusNode;
final String? hintText;
final String? helperText;
final String? liveMessage;
final VoidCallback? onChanged;








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
      border: Border.all(
  color: showError ? Colors.red : Colors.transparent,
  width: 1.5,
),

       
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.centerLeft,
    child: TextField(
      focusNode: focusNode, 
      controller: controller,
      onChanged: (_) => onChanged?.call(),

      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration:  InputDecoration(
        hintText: hintText,
        border: InputBorder.none, // مهم جدًا
        isDense: true,
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  ),
),if (liveMessage != null) ...[

  const SizedBox(height: 6),
  Text(
    liveMessage!,
    style: const TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
  ),
],


        ],
      ),
    );
  }
 
}
 class _AccountTypeButton extends StatelessWidget {
  const _AccountTypeButton({
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.showErrorBorder,
  });

  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showErrorBorder;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 136,   //  Figma
        height: 142,  //  Figma
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(60),
          border: Border.all(
             color: showErrorBorder
      ? Colors.red
      : (isSelected ? const Color(0xFF4F378B) : const Color(0xFFB8A9D9)),
  
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 65,
              color: const Color(0xFF4F378B),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4F378B),
              ),
            ),
          ],
        ),
      ),
    );
  }

}class _PasswordRule extends StatelessWidget {
  const _PasswordRule({
    required this.text,
    required this.isValid,
    required this.isActive,
  });

  final String text;
  final bool isValid;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    Color color;

    if (!isActive) {
      color = Colors.grey; // ⚪ قبل ما يكتب
    } else {
      color = isValid ? Colors.green : Colors.red;
    }



    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size:10,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

