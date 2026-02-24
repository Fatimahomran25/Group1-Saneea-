// client_profile.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  // -------- form / state --------
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // -------- controllers --------
  final TextEditingController _nameCtrl =
      TextEditingController(text: "Manar Alrazin");
  final TextEditingController _bioCtrl = TextEditingController(
      text: "bio bio bio bio bio bio\nbio bio bio bio bio bio");
  final TextEditingController _emailCtrl =
      TextEditingController(text: "ma.alrazin@gmail.com");

  // read-only
  final String _nationalId = "1110000000";

  // counter
  int _bioLen = 0;

  // image
  File? _pickedImage;

  // rating / reviews
  final double _rating = 4.0;
  final List<_Review> _reviews = const [
    _Review(name: "Lina Alharbi", rating: 4, text: "Very good work and fast delivery."),
    _Review(name: "Lina Alharbi", rating: 4, text: "Excellent communication and quality."),
    _Review(name: "Lina Alharbi", rating: 4, text: "On time and professional."),
  ];

  // colors close to figma
  static const Color kPurple = Color(0xFF3A1B63);
  static const Color kSoftBg = Color(0xFFF5F0FA);
  static const Color kBorder = Color(0x663A1B63);

  @override
  void initState() {
    super.initState();
    _bioLen = _bioCtrl.text.length;

    _bioCtrl.addListener(() {
      setState(() {
        _bioLen = _bioCtrl.text.length;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // -------- actions --------
  Future<void> _pickProfileImage() async {
    if (!_isEditing) return;

    final picker = ImagePicker();
    final XFile? x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;

    setState(() => _pickedImage = File(x.path));
  }

  void _startEdit() {
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
    // لو تبين يرجع القيم القديمة بدل ما يبقى التعديل (قولي لي وأضيف snapshot)
    _formKey.currentState?.reset();
  }

  void _save() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    // هنا تحطين حفظ للـ Firebase/Backend
    // مثال: await updateProfile(name, bio, email, image);

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved successfully")),
    );
  }

  // -------- validators --------
  String? _nameValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Name is required";
    if (value.length < 2) return "Name is too short";
    return null;
  }

  String? _bioValidator(String? v) {
    final value = (v ?? "");
    if (value.length > 150) return "Bio must be 150 characters or less";
    return null;
  }

  String? _gmailValidator(String? v) {
    final value = (v ?? "").trim();

    if (value.isEmpty) return "Email is required";

    // Gmail فقط + لازم ينتهي @gmail.com
    final reg = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    if (!reg.hasMatch(value)) {
      return "Enter a valid email (example: name@gmail.com)";
    }
    return null;
  }

  // -------- UI --------
  @override
  Widget build(BuildContext context) {
    // يقلل إحساس "مكبرة" (خصوصًا لو جهازك Text size كبير)
    final mq = MediaQuery.of(context);
    final fixedMq = mq.copyWith(textScaler: const TextScaler.linear(1.0));

    return MediaQuery(
      data: fixedMq,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (!_isEditing)
              TextButton.icon(
                onPressed: _startEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Edit"),
                style: TextButton.styleFrom(
                  foregroundColor: kPurple,
                ),
              )
            else ...[
              TextButton(
                onPressed: _cancelEdit,
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, size: 18),
                label: const Text("Done"),
                style: TextButton.styleFrom(
                  foregroundColor: kPurple,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Header(
                purple: kPurple,
                isEditing: _isEditing,
                nameCtrl: _nameCtrl,
                nameValidator: _nameValidator,
                onPickImage: _pickProfileImage,
                pickedImage: _pickedImage,
              ),

              const SizedBox(height: 10),

              // BIO Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionCard(
                  child: _EditableField(
                    label: "Bio",
                    enabled: _isEditing,
                    controller: _bioCtrl,
                    maxLength: 150,
                    maxLines: 4,
                    validator: _bioValidator,
                    counterText: "${_bioLen.clamp(0, 150)}/150",
                    hintText: "Write your bio...",
                    purple: kPurple,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Info card: National ID + Email + Rating
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionCard(
                  background: kSoftBg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReadOnlyBlock(
                        title: "National ID / Iqama",
                        value: _nationalId,
                        purple: kPurple,
                      ),
                      const SizedBox(height: 10),

                      _EditableField(
                        label: "Email Address",
                        enabled: _isEditing,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: _gmailValidator,
                        hintText: "name@gmail.com",
                        purple: kPurple,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Rating",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _StarsReadOnly(value: _rating, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            _rating.toStringAsFixed(1),
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Reviews
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Reviews",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _reviews
                      .map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ReviewCard(
                              purple: kPurple,
                              review: r,
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Account actions (Figma-like)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AccountActionsCard(purple: kPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Widgets ----------------

class _Header extends StatelessWidget {
  const _Header({
    required this.purple,
    required this.isEditing,
    required this.nameCtrl,
    required this.nameValidator,
    required this.onPickImage,
    required this.pickedImage,
  });

  final Color purple;
  final bool isEditing;
  final TextEditingController nameCtrl;
  final String? Function(String?) nameValidator;
  final VoidCallback onPickImage;
  final File? pickedImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            color: const Color(0xFFF2EAFB),
            border: Border.all(color: purple.withOpacity(0.25)),
          ),
          child: Stack(
            children: [
              // decorative circles (like figma)
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: purple.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: purple.withOpacity(0.18)),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                right: 20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: purple.withOpacity(0.18)),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: isEditing ? onPickImage : null,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 41,
                                backgroundColor: const Color(0xFFF2EAFB),
                                backgroundImage:
                                    pickedImage != null ? FileImage(pickedImage!) : null,
                                child: pickedImage == null
                                    ? Icon(Icons.person, color: purple, size: 34)
                                    : null,
                              ),
                            ),
                            if (isEditing)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: purple.withOpacity(0.35)),
                                  ),
                                  child: Icon(Icons.camera_alt, size: 14, color: purple),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Name (editable)
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          controller: nameCtrl,
                          enabled: isEditing,
                          validator: nameValidator,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: purple,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 2),
                          ),
                        ),
                      ),

                      Text(
                        "Client",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.background});

  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ClientProfilePageState.kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.enabled,
    required this.controller,
    required this.purple,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
    this.counterText,
    this.hintText,
  });

  final String label;
  final bool enabled;
  final TextEditingController controller;
  final Color purple;

  final int? maxLength;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? counterText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: purple.withOpacity(0.35), width: 1.2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hintText,
            counterText: counterText ?? "",
            filled: true,
            fillColor: Colors.white.withOpacity(0.75),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: purple, width: 1.4),
            ),
            disabledBorder: border.copyWith(
              borderSide: BorderSide(color: purple.withOpacity(0.18), width: 1.2),
            ),
            errorBorder: border.copyWith(
              borderSide: const BorderSide(color: Colors.red, width: 1.3),
            ),
            focusedErrorBorder: border.copyWith(
              borderSide: const BorderSide(color: Colors.red, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyBlock extends StatelessWidget {
  const _ReadOnlyBlock({
    required this.title,
    required this.value,
    required this.purple,
  });

  final String title;
  final String value;
  final Color purple;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: purple,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.purple,
    required this.review,
  });

  final Color purple;
  final _Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: purple.withOpacity(0.6), width: 1.1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF2EAFB),
            child: Icon(Icons.person, color: purple, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        style: TextStyle(
                          color: purple,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _StarsReadOnly(value: review.rating.toDouble(), size: 16),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  review.text,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountActionsCard extends StatelessWidget {
  const _AccountActionsCard({required this.purple});

  final Color purple;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          color: _ClientProfilePageState.kSoftBg,
          border: Border.all(color: _ClientProfilePageState.kBorder, width: 1.2),
        ),
        child: Column(
          children: [
            _ActionBtn(
              text: "Reset password",
              color: Colors.blue,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reset password clicked")),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionBtn(
              text: "Log out",
              color: Colors.red,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logout clicked")),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionBtn(
              text: "Delete account",
              color: Colors.red,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Delete account clicked")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  final String text;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        backgroundColor: Colors.white.withOpacity(0.6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StarsReadOnly extends StatelessWidget {
  const _StarsReadOnly({required this.value, this.size = 20});

  final double value; // 0..5
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = value.round().clamp(0, 5);
    return Row(
      children: List.generate(5, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            size: size,
            color: isFilled ? Colors.amber : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}

// simple model
class _Review {
  final String name;
  final int rating;
  final String text;

  const _Review({
    required this.name,
    required this.rating,
    required this.text,
  });
}