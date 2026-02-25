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
  String? topMessage; // النص اللي يطلع فوق
  bool showTopMessage = false; // هل نعرضه أو لا

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
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Login Screen', style: TextStyle(fontSize: 20))),
    );
  }
}
