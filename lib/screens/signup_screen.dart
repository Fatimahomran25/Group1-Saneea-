import 'package:flutter/material.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({
    super.key,
    this.onCreateAccount,
    this.onLoginTap,
  });

  final VoidCallback? onCreateAccount;
  final VoidCallback? onLoginTap;

  // Colors from Figma
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _dark = Color(0xFF111111);
  static const Color _fieldBg = Color(0xFFF1F3FF);
  static const Color _primary = Color(0xFF467FFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 360, // Figma frame width
            height: 900, // allow content that goes below 780 (button/text)
            child: Stack(
              children: [
                // 2) Back Icon
                Positioned(
                  left: 27,
                  top: 70,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 21,
                      color: _dark,
                    ),
                  ),
                ),

                // 3) Logo
                Positioned(
                  left: 135,
                  top: 92,
                  child: SizedBox(
                    width: 142,
                    height: 142,
                    child: Image.asset(
                      'assets/image.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // A) National ID / Iqama
                Positioned(
                  left: 37,
                  top: 255,
                  child: _labelText("National ID / Iqama"),
                ),
                Positioned(
                  left: 37,
                  top: 279,
                  child: _inputField(
                    width: 339,
                    height: 73,
                    hintText: "",
                    obscureText: false,
                  ),
                ),

                // B) First & Last Name (Row)
                Positioned(
                  left: 37,
                  top: 368,
                  child: SizedBox(
                    width: 339,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First name
                        SizedBox(
                          width: 163,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _labelText("First name"),
                              const SizedBox(height: 6),
                              _inputField(
                                width: 163,
                                height: 73,
                                hintText: "",
                                obscureText: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 13),
                        // Last name
                        SizedBox(
                          width: 163,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _labelText("Last name"),
                              const SizedBox(height: 6),
                              _inputField(
                                width: 163,
                                height: 73,
                                hintText: "",
                                obscureText: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // C) Email Address
                Positioned(
                  left: 37,
                  top: 481,
                  child: _labelText("Email address"),
                ),
                Positioned(
                  left: 37,
                  top: 505,
                  child: _inputField(
                    width: 339,
                    height: 73,
                    hintText: "",
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),

                // D) Password
                Positioned(
                  left: 37,
                  top: 594,
                  child: _labelText("Password"),
                ),
                Positioned(
                  left: 37,
                  top: 618,
                  child: _inputField(
                    width: 339,
                    height: 73,
                    hintText: "",
                    obscureText: true,
                  ),
                ),

                // E) Confirm Password
                Positioned(
                  left: 37,
                  top: 707,
                  child: _labelText("Confirm password"),
                ),
                Positioned(
                  left: 37,
                  top: 731,
                  child: _inputField(
                    width: 339,
                    height: 73,
                    hintText: "",
                    obscureText: true,
                  ),
                ),

                // 5) Primary Button
                Positioned(
                  left: 37,
                  top: 776,
                  child: SizedBox(
                    width: 339,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onCreateAccount ?? () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),

                // 6) Bottom Text
                Positioned(
                  left: 42,
                  top: 842,
                  child: Row(
                    children: [
                      const Text(
                        "Have an account already? ",
                        style: TextStyle(
                          fontSize: 16,
                          color: _dark,
                        ),
                      ),
                      InkWell(
                        onTap: onLoginTap ?? () {},
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            fontSize: 16,
                            color: _primary,
                          ),
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
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: _dark,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _inputField({
    required double width,
    required double height,
    required String hintText,
    required bool obscureText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: const BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        alignment: Alignment.centerLeft,
        child: TextField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isCollapsed: true,
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
