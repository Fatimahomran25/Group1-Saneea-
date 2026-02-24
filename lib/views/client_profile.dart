import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../controlles/client_profile_controller.dart';

class ClientProfile extends StatelessWidget {
  const ClientProfile({super.key});

  // ✅ MATCH AdminProfile colors
  static const Color kPurple = Color.fromRGBO(79, 55, 139, 1);
  static const Color kHeaderBg = Color(0xFFF2EAFB);
  static const Color kCardBg = Color(0xFFF4F1FA);
  static const Color kSoftBorder = Color(0x66B8A9D9);

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

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? x = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
    );
    if (x == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: x.path,
      compressQuality: 90,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Photo',
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Edit Photo',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped == null) return;

    c.setPickedImage(File(cropped.path));
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
    const purple = ClientProfile.kPurple;

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
            TextButton(
              onPressed: c.cancelEdit,
              child: const Text("Cancel"),
            ),
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

          // ✅ Logout like Admin (red + bigger)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.red, size: 28),
              onPressed: () => c.logout(context),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 10),

            _HeaderLikeAdmin(
              purple: purple,
              isEditing: c.isEditing,
              nameCtrl: c.nameCtrl,
              nameValidator: c.validateName,
              onPickImage: () => _pickProfileImage(c),
              avatar: avatar,
              roleText: "Client",
            ),

            const SizedBox(height: 14),

            // ✅ ONE LONG CARD like Admin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                decoration: BoxDecoration(
                  color: ClientProfile.kCardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: ClientProfile.kSoftBorder,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BIO (editable)
                    _EditableField(
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

                    const SizedBox(height: 18),

                    // National ID (read-only)
                    _ReadOnlyBlock(
                      title: "National ID / Iqama",
                      value: p.nationalId,
                      purple: purple,
                    ),

                    const SizedBox(height: 18),

                    // Email (editable)
                    _EditableField(
                      label: "Email Address",
                      enabled: c.isEditing,
                      controller: c.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: c.validateGmail,
                      hintText: "name@gmail.com",
                      purple: purple,
                    ),

                    const SizedBox(height: 18),

                    // Rating (read-only)
                    Text(
                      "Rating",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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

                    const SizedBox(height: 18),

                    // Reviews (inside same long card)
                    Text(
                      "Reviews",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _ReviewsBox(
                      child: c.reviews.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text("No reviews yet."),
                            )
                          : ListView.builder(
                              itemCount: c.reviews.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i) {
                                final r = c.reviews[i];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i == c.reviews.length - 1 ? 0 : 12,
                                  ),
                                  child: _ReviewTile(
                                    name: r.reviewerName,
                                    rating: r.rating,
                                    text: r.text,
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Buttons at bottom (Reset + Delete)
                    _AdminStyleOutlinedBtn(
                      text: "Reset password",
                      textColor: const Color(0xFF2F7BFF),
                      borderColor: purple.withOpacity(0.25),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/forgotPassword',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AdminStyleOutlinedBtn(
                      text: "Delete account",
                      textColor: Colors.red,
                      borderColor: purple.withOpacity(0.25),
                      onPressed: () => c.deleteAccount(context),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------- Widgets (UI only) ----------------

class _HeaderLikeAdmin extends StatelessWidget {
  const _HeaderLikeAdmin({
    required this.purple,
    required this.isEditing,
    required this.nameCtrl,
    required this.nameValidator,
    required this.onPickImage,
    required this.avatar,
    required this.roleText,
  });

  final Color purple;
  final bool isEditing;
  final TextEditingController nameCtrl;
  final String? Function(String?) nameValidator;
  final VoidCallback onPickImage;
  final ImageProvider? avatar;
  final String roleText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          color: ClientProfile.kHeaderBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: purple.withOpacity(0.22),
            width: 1.2,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 41,
                            backgroundColor: ClientProfile.kHeaderBg,
                            backgroundImage: avatar,
                            child: avatar == null
                                ? Icon(Icons.person, color: purple, size: 34)
                                : null,
                          ),
                        ),
                      ),
                      if (isEditing)
                        Positioned(
                          right: 10,
                          bottom: 8,
                          child: GestureDetector(
                            onTap: onPickImage,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: purple,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 260,
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
                const SizedBox(height: 4),
                Text(
                  roleText,
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
      ),
    );
  }
}

class _ReviewsBox extends StatelessWidget {
  const _ReviewsBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ClientProfile.kSoftBorder,
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
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
          color: ClientProfile.kSoftBorder.withOpacity(0.85),
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
              border: Border.all(
                color: ClientProfile.kSoftBorder.withOpacity(0.8),
              ),
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

class _AdminStyleOutlinedBtn extends StatelessWidget {
  const _AdminStyleOutlinedBtn({
    required this.text,
    required this.textColor,
    required this.borderColor,
    required this.onPressed,
  });

  final String text;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: borderColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
      borderSide: BorderSide(color: purple.withOpacity(0.25), width: 1.2),
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
            fillColor: Colors.white,
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