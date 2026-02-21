import 'package:flutter/material.dart';
import '../controlles/signup_controller.dart';
import '../models/signup_model.dart';
import 'package:flutter/services.dart';

/// SignupScreen is the UI (View) responsible for collecting user registration data.
/// It delegates validation/state and Firebase logic to SignupController (Controller).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

/// _SignupScreenState holds UI-only state:
/// - FocusNodes (to detect focus and show live validation messages)
/// - local selection state (selectedType)
/// - password visibility toggles (eye icon)
class _SignupScreenState extends State<SignupScreen> {
  /// Controller that contains text controllers, validation getters, and createAccount().
  late final SignupController c;

  /// Local UI selection for highlighting the account type buttons.
  /// The actual chosen type is also stored inside SignupController.model via c.setAccountType().
  AccountType? selectedType;

  /// FocusNodes are used to:
  /// - know which field is focused
  /// - show/hide helper validation messages depending on focus
  /// - trigger UI refresh when focus changes
  final _nidFocus = FocusNode();
  final _firstFocus = FocusNode();
  final _lastFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  /// Password visibility (eye icon) toggles.
  /// true  => hidden (obscureText)
  /// false => shown
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  /// Triggers rebuild to update:
  /// - live validation messages
  /// - password rules indicators
  /// - focus-dependent UI
  void _refresh() => setState(() {});

  @override
  void initState() {
    super.initState();

    // Initialize controller once for the screen lifecycle.
    c = SignupController();

    // Rebuild UI when focus changes so helper messages update instantly.
    _nidFocus.addListener(_refresh);
    _firstFocus.addListener(_refresh);
    _lastFocus.addListener(_refresh);
    _emailFocus.addListener(_refresh);
    _passFocus.addListener(_refresh);
    _confirmFocus.addListener(_refresh);
  }

  @override
  void dispose() {
    // Dispose FocusNodes to avoid memory leaks.
    _nidFocus.dispose();
    _firstFocus.dispose();
    _lastFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();

    // Dispose controller text controllers.
    c.dispose();
    super.dispose();
  }

  // ===== THEME / STYLING CONSTANTS =====

  /// Screen background color.
  static const _bg = Colors.white;

  /// Default fill color for input fields (semi-transparent).
  static const _fieldFill = Color(0x5CE8DEF8);

  /// Link color used for "Log in".
  static const _btnBlue = Color(0xFF467FFF);

  /// Primary text color used across labels and normal text.
  static const _textBlack = Color(0xFF000000);

  /// Main brand color used for the primary button.
  static const _primaryPurple = Color(0xFF4F378B);

  // ===== DIMENSIONS (BASED ON FIGMA) =====

  /// Height for small text fields (e.g., first/last name).
  static const double _smallBoxH = 46;

  /// Border radius for input fields container.
  static const double _radiusField = 5;

  /// Border radius for main button.
  static const double _radiusButton = 10;

  /// Logo width/height and rounding.
  static const double _logoW = 112;
  static const double _logoH = 128;
  static const double _logoRadius = 33;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    /// When to show password rules:
    /// - user is focused on password field
    /// - or text exists but not strong
    /// - or user pressed submit and password is invalid
    final showPasswordRules =
        _passFocus.hasFocus ||
        (c.passwordCtrl.text.isNotEmpty && !c.isPasswordStrong) ||
        (c.submitted && !c.isPasswordStrong);

    /// When to show confirm-password rule:
    /// - user is focused on confirm field
    /// - or text exists but doesn't match
    /// - or user pressed submit and confirm is invalid
    final showConfirmRules =
        _confirmFocus.hasFocus ||
        (c.confirmPasswordCtrl.text.isNotEmpty && !c.isConfirmPasswordValid) ||
        (c.submitted && !c.isConfirmPasswordValid);

    /// Responsive form width:
    /// - uses 88% of screen width
    /// - clamped to stay between 280 and 420 for better UI consistency
    final formW = (screenW * 0.88).clamp(280.0, 420.0);

    /// Horizontal gap between First Name and Last Name fields.
    final gap = 12.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Scroll view prevents overflow on small screens / keyboard open.
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              // Keeps UI aligned and prevents being too wide on tablets.
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 14),

                  // ===== BRAND LOGO =====
                  // Rounded image container to match design.
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

                  // ===== BRAND TITLE (GRADIENT TEXT) =====
                  // ShaderMask applies a gradient over the text color (text color must be white).
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
                        // Required because ShaderMask uses text color as a mask
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ===== GLOBAL FORM ERROR MESSAGES =====
                  // Shows only after submit if any required field is invalid.
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

                  // Shows server-side error (e.g., email already in use, duplicate nationalId).
                  if (c.serverError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        c.serverError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // ===== ACCOUNT TYPE SELECTION =====
                  // Two custom buttons: Freelancer / Client.
                  // Red border appears if user submitted without choosing a type.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AccountTypeButton(
                        text: 'Freelancer',
                        icon: Icons.person_outline,
                        isSelected: selectedType == AccountType.freelancer,
                        showErrorBorder:
                            c.submitted && !c.isAccountTypeSelected,
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
                        showErrorBorder:
                            c.submitted && !c.isAccountTypeSelected,
                        onTap: () {
                          setState(() => selectedType = AccountType.client);
                          c.setAccountType(AccountType.client);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== NATIONAL ID / IQAMA FIELD =====
                  // Numeric only + max length 10 (Saudi ID/Iqama length constraint).
                  _LabeledField(
                    label: 'National ID / Iqama',
                    width: formW,
                    maxLength: 10,
                    showError: c.submitted && !c.isNationalIdValid,
                    focusNode: _nidFocus,
                    onChanged: _refresh,
                    boxHeight: 46,
                    controller: c.nationalIdCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    keyboardType: TextInputType.number,
                    // Live message appears when user leaves the field or on submit.
                    liveMessage:
                        (!_nidFocus.hasFocus &&
                            c.nationalIdCtrl.text.isNotEmpty &&
                            !c.isNationalIdValid)
                        ? 'Must be 10 digits and start with 1 (ID) or 2 (Iqama).'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ===== NAME FIELDS (FIRST + LAST) =====
                  SizedBox(
                    width: formW,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'First name',
                            width: double.infinity,
                            showError: c.submitted && !c.isFirstNameValid,
                            focusNode: _firstFocus,
                            onChanged: _refresh,
                            boxHeight: _smallBoxH,
                            controller: c.firstNameCtrl,
                            fillColor: _fieldFill,
                            radius: _radiusField,
                            liveMessage:
                                (!_firstFocus.hasFocus &&
                                    c.firstNameCtrl.text.isNotEmpty &&
                                    !c.isFirstNameValid)
                                ? 'Only letters, max 15 characters.'
                                : null,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _LabeledField(
                            label: 'Last name',
                            width: double.infinity,
                            boxHeight: _smallBoxH,
                            showError: c.submitted && !c.isLastNameValid,
                            focusNode: _lastFocus,
                            onChanged: _refresh,
                            controller: c.lastNameCtrl,
                            fillColor: _fieldFill,
                            radius: _radiusField,
                            liveMessage:
                                (!_lastFocus.hasFocus &&
                                    c.lastNameCtrl.text.isNotEmpty &&
                                    !c.isLastNameValid)
                                ? 'Only letters, max 15 characters.'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== EMAIL FIELD =====
                  // Uses email keyboard + Gmail format validation in the controller.
                  _LabeledField(
                    label: 'Email address',
                    width: formW,
                    showError: c.submitted && !c.isEmailValid,
                    hintText: 'e.g. example@gmail.com',
                    focusNode: _emailFocus,
                    onChanged: _refresh,
                    boxHeight: 46,
                    controller: c.emailCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    keyboardType: TextInputType.emailAddress,
                    liveMessage:
                        (!_emailFocus.hasFocus &&
                            c.emailCtrl.text.isNotEmpty &&
                            !c.isEmailValid)
                        ? 'Please enter a valid Gmail address.'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ===== PASSWORD FIELD =====
                  // Eye icon toggles obscureText between hidden/shown.
                  _LabeledField(
                    label: 'Password',
                    width: formW,
                    showError: c.submitted && !c.isPasswordValid,
                    hintText: 'e.g. Password@1',
                    focusNode: _passFocus,
                    onChanged: _refresh,
                    boxHeight: 46,
                    controller: c.passwordCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    obscureText: _obscurePass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off : Icons.visibility,
                        color: _primaryPurple,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),

                  // Password rules UI feedback (not a validation change, only visual indicators).
                  if (showPasswordRules) ...[
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PasswordRule(
                          text: "Contains at least 8 letters",
                          isValid: c.hasAtLeast8Letters,
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

                  // ===== CONFIRM PASSWORD FIELD =====
                  // Eye icon toggles obscureText between hidden/shown.
                  _LabeledField(
                    label: 'Confirm password',
                    width: formW,
                    showError: c.submitted && !c.isConfirmPasswordValid,
                    hintText: 'e.g. Password@1',
                    focusNode: _confirmFocus,
                    onChanged: _refresh,
                    boxHeight: 46,
                    controller: c.confirmPasswordCtrl,
                    fillColor: _fieldFill,
                    radius: _radiusField,
                    obscureText: _obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _primaryPurple,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    // Live message shown when not focused or on submit.
                    liveMessage:
                        (!_confirmFocus.hasFocus &&
                            c.confirmPasswordCtrl.text.isNotEmpty &&
                            !c.isConfirmPasswordValid)
                        ? 'Passwords do not match.'
                        : null,
                  ),

                  // Confirm password rule indicator.
                  if (showConfirmRules) ...[
                    const SizedBox(height: 8),
                    _PasswordRule(
                      text: "Matches password",
                      isValid: c.isConfirmPasswordValid,
                      isActive: c.confirmPasswordCtrl.text.isNotEmpty,
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ===== SUBMIT BUTTON =====
                  // Calls submit() to show validation, then createAccount() to register via Firebase.
                  SizedBox(
                    width: formW,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Marks the form as submitted (used by validation UI).
                        setState(c.submit);

                        // Attempts account creation; returns AccountType on success or null on failure.
                        final type = await c.createAccount();

                        // Rebuild UI to show serverError if any.
                        setState(() {});

                        // Avoid navigation if widget is no longer in the tree.
                        if (!mounted) return;

                        // Stop if createAccount failed.
                        if (type == null) return;

                        // Navigate based on selected account type.
                        Navigator.pushReplacementNamed(
                          this.context,
                          type == AccountType.freelancer
                              ? '/freelancerHome'
                              : '/clientHome',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_radiusButton),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== LOGIN LINK =====
                  // RichText + GestureDetector to make only "Log in" clickable.
                  SizedBox(
                    width: formW,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Text(
                            "Have an account already? ",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () => c.loginTap(context),
                            child: const Text(
                              "Log in",
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

/// _LabeledField is a reusable UI component that renders:
/// - a label
/// - a styled TextField with optional maxLength, numeric filtering, and suffix icon
/// - an optional liveMessage under the field (animated size)
class _LabeledField extends StatelessWidget {
  const _LabeledField({
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
    this.liveMessage,
    this.onChanged,
    this.maxLength,
    this.suffixIcon,
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
  final String? liveMessage;
  final VoidCallback? onChanged;
  final int? maxLength;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label text.
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),

          // Styled text field container (fill color, border radius, error border).
          SizedBox(
            height: boxHeight,
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  // Red border on validation error, otherwise transparent.
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

                // Input formatting:
                // - digitsOnly when numeric keyboard is used
                // - length limiting if maxLength is provided
                inputFormatters: [
                  if (keyboardType == TextInputType.number)
                    FilteringTextInputFormatter.digitsOnly,
                  if (maxLength != null)
                    LengthLimitingTextInputFormatter(maxLength!),
                ],

                // Enforces max length behavior (also hides the default counter in UI).
                maxLength: maxLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,

                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  // Hide the default maxLength counter text.
                  counterText: '',
                  // Optional suffix icon (e.g., password eye icon).
                  suffixIcon: suffixIcon,
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),

          // Animated helper/error text under the field.
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: liveMessage == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      liveMessage!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// _AccountTypeButton is a reusable UI component for account type selection.
/// It shows:
/// - icon + label
/// - selected border color
/// - error border color if submitted without selecting any account type
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
        // Fixed size based on design.
        width: 136,
        height: 142,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(60),
          border: Border.all(
            // Red if form submitted without selection, otherwise selected/unselected color.
            color: showErrorBorder
                ? Colors.red
                : (isSelected
                      ? const Color(0xFF4F378B)
                      : const Color(0xFFB8A9D9)),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 65, color: const Color(0xFF4F378B)),
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
}

/// _PasswordRule is a small UI indicator row for password rules.
/// It changes color depending on:
/// - inactive (grey) when user didn't type
/// - valid (green)
/// - invalid (red)
class _PasswordRule extends StatelessWidget {
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
      // Neutral state (no typing yet).
      color = Colors.grey;
    } else {
      // Green if rule is satisfied, else red.
      color = isValid ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
