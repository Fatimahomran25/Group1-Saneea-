import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../controlles/client_profile_controller.dart';

class ClientProfile extends StatelessWidget {
  const ClientProfile({super.key});

  // colors close to figma
  static const Color kPurple = Color(0xFF3A1B63);
  static const Color kSoftBg = Color(0xFFF5F0FA);
  static const Color kBorder = Color(0x663A1B63);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final fixedMq = mq.copyWith(textScaler: const TextScaler.linear(1.0));

    return MediaQuery(
      data: fixedMq,
      child: ChangeNotifierProvider(
        create: (_) => ClientProfileController()..init(),
        child: const _ClientProfileBody(),
      ),
    );
  }
}

class _ClientProfileBody extends StatefulWidget {
  const _ClientProfileBody();

  @override
  State<_ClientProfileBody> createState() => _ClientProfileBodyState();
}

class _ClientProfileBodyState extends State<_ClientProfileBody> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickProfileImage(ClientProfileController c) async {
    if (!c.isEditing) return;

    final XFile? x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;

    c.setPickedImage(File(x.path));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ClientProfileController>();

    if (c.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (c.error != null) {
      return Scaffold(body: Center(child: Text(c.error!)));
    }

    final p = c.profile!;
    final purple = ClientProfile.kPurple;

    ImageProvider? avatar;
    if (c.pickedImageFile != null) {
      avatar = FileImage(c.pickedImageFile!);
    } else if (p.photoUrl != null && p.photoUrl!.isNotEmpty) {
      avatar = NetworkImage(p.photoUrl!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!c.isEditing)
            TextButton.icon(
              onPressed: c.startEdit,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text("Edit"),
              style: TextButton.styleFrom(foregroundColor: purple),
            )
          else ...[
            TextButton(onPressed: c.cancelEdit, child: const Text("Cancel")),
            const SizedBox(width: 6),
            TextButton.icon(
              onPressed: c.isSaving
                  ? null
                  : () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;

                      final ok = await c.save();
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? "Saved successfully ✅"
                                : (c.error ?? "Save failed"),
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.check, size: 18),
              label: const Text("Save"),
              style: TextButton.styleFrom(foregroundColor: purple),
            ),
            const SizedBox(width: 8),
          ],

          // ✅ Logout فوق فقط
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => c.logout(context),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _Header(
              purple: purple,
              isEditing: c.isEditing,
              nameCtrl: c.nameCtrl,
              nameValidator: c.validateName,
              onPickImage: () => _pickProfileImage(c),
              avatar: avatar,
            ),

            const SizedBox(height: 10),

            // BIO Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionCard(
                child: _EditableField(
                  label: "Bio",
                  enabled: c.isEditing,
                  controller: c.bioCtrl,
                  maxLength: ClientProfileController.bioMax,
                  maxLines: 4,
                  validator: c.validateBio,
                  counterText: "${c.bioLen.clamp(0, 150)}/150",
                  hintText: "Write your bio...",
                  purple: purple,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Info card: National ID + Email + Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionCard(
                background: ClientProfile.kSoftBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReadOnlyBlock(
                      title: "National ID / Iqama",
                      value: p.nationalId,
                      purple: purple,
                    ),
                    const SizedBox(height: 10),

                    _EditableField(
                      label: "Email Address",
                      enabled: c.isEditing,
                      controller: c.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: c.validateGmail,
                      hintText: "name@gmail.com",
                      purple: purple,
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
                        _StarsReadOnly(value: p.rating, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          p.rating.toStringAsFixed(1),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Reviews title
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

            // ✅ Reviews outer box + inner boxes (figma-like)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ReviewsOuterCard(
                child: c.reviews.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text("No reviews yet."),
                      )
                    : Column(
                        children: c.reviews
                            .map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ReviewFigmaTile(
                                  name: r.reviewerName,
                                  rating: r.rating,
                                  text: r.text,
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ تحت: Reset + Delete فقط
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AccountActionsCard(
                onResetPassword: () =>
                    Navigator.pushNamed(context, '/forgotPassword'),
                onDelete: () => c.deleteAccount(context),
              ),
            ),
          ],
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
    required this.avatar,
  });

  final Color purple;
  final bool isEditing;
  final TextEditingController nameCtrl;
  final String? Function(String?) nameValidator;
  final VoidCallback onPickImage;
  final ImageProvider? avatar;

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
                                backgroundImage: avatar,
                                child: avatar == null
                                    ? Icon(
                                        Icons.person,
                                        color: purple,
                                        size: 34,
                                      )
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
                                    border: Border.all(
                                      color: purple.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: purple,
                                  ),
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
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 2),
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
        border: Border.all(color: ClientProfile.kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: purple, width: 1.4),
            ),
            disabledBorder: border.copyWith(
              borderSide: BorderSide(
                color: purple.withOpacity(0.18),
                width: 1.2,
              ),
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

class _ReviewsOuterCard extends StatelessWidget {
  const _ReviewsOuterCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ClientProfile.kBorder, width: 1.2),
      ),
      child: child,
    );
  }
}

class _ReviewFigmaTile extends StatelessWidget {
  const _ReviewFigmaTile({
    required this.name,
    required this.rating,
    required this.text,
  });

  final String name;
  final int rating;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ClientProfile.kBorder.withOpacity(0.7),
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ClientProfile.kBorder.withOpacity(0.6)),
            ),
            child: const Icon(Icons.person_outline, size: 20),
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
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    _StarsReadOnly(value: rating.toDouble(), size: 16),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.25),
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
  const _AccountActionsCard({
    required this.onResetPassword,
    required this.onDelete,
  });

  final VoidCallback onResetPassword;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          color: ClientProfile.kSoftBg,
          border: Border.all(color: ClientProfile.kBorder, width: 1.2),
        ),
        child: Column(
          children: [
            _ActionBtn(
              text: "Reset password",
              color: Colors.blue,
              onPressed: onResetPassword,
            ),
            const SizedBox(height: 12),
            _ActionBtn(
              text: "Delete account",
              color: Colors.red,
              onPressed: onDelete,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
