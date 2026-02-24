
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controlles/freelancer_profile_controller.dart';
import '../models/freelancer_profile_model.dart';

class FreelancerProfileView extends StatefulWidget {
  const FreelancerProfileView({super.key});

  @override
  State<FreelancerProfileView> createState() => _FreelancerProfileViewState();
}

class _FreelancerProfileViewState extends State<FreelancerProfileView> {
  final c = FreelancerProfileController();
  final _formKey = GlobalKey<FormState>();

  static const Color kPurple = Color(0xFF4F378B);
  static const Color kSoftBg = Color(0xFFF4F1FA);
  static const Color kBorder = Color(0x66B8A9D9);

  @override
  void initState() {
    super.initState();
    c.init();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (!c.isEditing) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    c.setPickedImage(File(x.path));
  }

  Future<void> _pickPortfolioImages() async {
    if (!c.isEditing) return;
    final picker = ImagePicker();
    final xs = await picker.pickMultiImage(imageQuality: 85);
    if (xs.isEmpty) return;
    c.addPortfolioFiles(xs.map((e) => File(e.path)).toList());
  }

  Future<ExperienceModel?> _experienceDialog({ExperienceModel? initial}) async {
    final fieldCtrl = TextEditingController(text: initial?.field ?? "Graphic Design");
    final orgCtrl = TextEditingController(text: initial?.org ?? "King Saud University");
    final periodCtrl = TextEditingController(text: initial?.period ?? "Sep 2019 - Jun 2022");

    final res = await showDialog<ExperienceModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(initial == null ? "Add Experience" : "Edit Experience"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: fieldCtrl,
                decoration: const InputDecoration(labelText: "Field", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: orgCtrl,
                decoration: const InputDecoration(labelText: "Organization", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: periodCtrl,
                decoration: const InputDecoration(labelText: "Period", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kPurple),
            onPressed: () {
              Navigator.pop(
                ctx,
                ExperienceModel(
                  field: fieldCtrl.text.trim(),
                  org: orgCtrl.text.trim(),
                  period: periodCtrl.text.trim(),
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    fieldCtrl.dispose();
    orgCtrl.dispose();
    periodCtrl.dispose();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final fixedMq = mq.copyWith(textScaler: const TextScaler.linear(1.0));

    return MediaQuery(
      data: fixedMq,
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.black),
              actions: [
                // ✅ Logout فوق على الجنب
                IconButton(
                  tooltip: "Log out",
                  onPressed: () => c.logout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                ),
                const SizedBox(width: 6),
              ],
            ),
            body: c.isLoading
                ? const Center(child: CircularProgressIndicator())
                : (c.profile == null)
                    ? Center(child: Text(c.error ?? "Failed to load profile"))
                    : Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            _Header(
                              purple: kPurple,
                              profile: c.profile!,
                              isEditing: c.isEditing,
                              pickedImageFile: c.pickedImageFile,
                              onPickImage: _pickProfileImage,
                              nameCtrl: c.nameCtrl,
                              titleCtrl: c.titleCtrl,
                              onEditTap: c.isEditing ? null : c.startEdit,
                              nameValidator: c.validateName,
                              titleValidator: c.validateTitle,
                            ),

                            const SizedBox(height: 10),

                            // Bio
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _SectionCard(
                                borderColor: kBorder,
                                child: _EditableField(
                                  label: "Bio",
                                  enabled: c.isEditing,
                                  controller: c.bioCtrl,
                                  maxLength: FreelancerProfileController.bioMax,
                                  maxLines: 4,
                                  validator: c.validateBio,
                                  counterText:
                                      "${c.bioLen.clamp(0, FreelancerProfileController.bioMax)}/${FreelancerProfileController.bioMax}",
                                  hintText: "Write your bio...",
                                  purple: kPurple,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Info + options + experience
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _SectionCard(
                                borderColor: kBorder,
                                background: kSoftBg,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _ReadOnlyBlock(
                                      title: "National ID / Iqama",
                                      value: c.profile!.nationalId,
                                      purple: kPurple,
                                    ),
                                    const SizedBox(height: 12),

                                    _EditableField(
                                      label: "Email Address",
                                      enabled: c.isEditing,
                                      controller: c.emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: c.validateGmail,
                                      hintText: "name@gmail.com",
                                      purple: kPurple,
                                    ),

                                    const SizedBox(height: 12),

                                    // ✅ IBAN field + bank icon (يدخلك صفحة البنك إذا عندك route)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: _EditableField(
                                            label: "IBAN (optional)",
                                            enabled: c.isEditing,
                                            controller: c.ibanCtrl,
                                            validator: c.validateIban,
                                            hintText: "SA00 0000 0000 0000 0000 0000",
                                            purple: kPurple,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          tooltip: "Bank account",
                                          onPressed: () {
                                            // لو عندك صفحة bank_account.dart اربطيها بالراوت
                                            Navigator.pushNamed(context, '/bankAccount');
                                          },
                                          icon: Icon(Icons.account_balance, color: kPurple),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    Text(
                                      "Service Type",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _SegmentBar(
                                      options: FreelancerProfileController.serviceTypeOptions,
                                      value: c.profile!.serviceType,
                                      enabled: c.isEditing,
                                      onChanged: c.setServiceType,
                                      purple: kPurple,
                                    ),

                                    const SizedBox(height: 14),

                                    Text(
                                      "Working Mode",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _SegmentBar(
                                      options: FreelancerProfileController.workingModeOptions,
                                      value: c.profile!.workingMode,
                                      enabled: c.isEditing,
                                      onChanged: c.setWorkingMode,
                                      purple: kPurple,
                                    ),

                                    const SizedBox(height: 16),

                                    Row(
                                      children: [
                                        Text(
                                          "Experience",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (c.isEditing)
                                          TextButton.icon(
                                            onPressed: () async {
                                              final res = await _experienceDialog();
                                              if (res == null) return;
                                              c.addExperience(res);
                                            },
                                            icon: const Icon(Icons.add, size: 18),
                                            label: const Text("Add"),
                                            style: TextButton.styleFrom(foregroundColor: kPurple),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    ...List.generate(c.profile!.experiences.length, (i) {
                                      final e = c.profile!.experiences[i];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: _ExperienceCard(
                                          purple: kPurple,
                                          experience: e,
                                          editable: c.isEditing,
                                          onEdit: () async {
                                            final res = await _experienceDialog(initial: e);
                                            if (res == null) return;
                                            c.editExperience(i, res);
                                          },
                                          onDelete: () => c.deleteExperience(i),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Portfolio (local only)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _SectionCard(
                                borderColor: kBorder,
                                background: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Portfolio",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (c.isEditing)
                                          TextButton.icon(
                                            onPressed: _pickPortfolioImages,
                                            icon: const Icon(Icons.add, size: 18),
                                            label: const Text("Add"),
                                            style: TextButton.styleFrom(foregroundColor: kPurple),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: c.pickedPortfolioFiles.isEmpty
                                          ? 4
                                          : c.pickedPortfolioFiles.length,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemBuilder: (ctx, i) {
                                        if (c.pickedPortfolioFiles.isEmpty) {
                                          return _PlaceholderTile(purple: kPurple);
                                        }
                                        final f = c.pickedPortfolioFiles[i];
                                        return Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.file(
                                                f,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            ),
                                            if (c.isEditing)
                                              Positioned(
                                                top: 6,
                                                right: 6,
                                                child: IconButton(
                                                  onPressed: () => c.removePortfolioAt(i),
                                                  icon: const Icon(Icons.close, color: Colors.red),
                                                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ✅ Rating (UI only ثابت زي الصورة)
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _SectionCard(
                                borderColor: kBorder,
                                background: kSoftBg,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rating",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const _StarsReadOnly(value: 0.0, size: 22),
                                        const SizedBox(width: 10),
                                        Text(
                                          "0.0",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ✅ Reviews (UI only ثابت)
                            const SizedBox(height: 14),
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
                              child: _SectionCard(
                                borderColor: kBorder,
                                background: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: Center(
                                    child: Text(
                                      "No reviews yet.",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _SectionCard(
                                borderColor: kBorder,
                                background: kSoftBg,
                                child: Column(
                                  children: [
                                    if (c.isEditing) ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: c.isSaving ? null : c.cancelEdit,
                                              child: const Text("Cancel"),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: FilledButton(
                                              style: FilledButton.styleFrom(backgroundColor: kPurple),
                                              onPressed: c.isSaving
                                                  ? null
                                                  : () async {
                                                      final ok = _formKey.currentState?.validate() ?? false;
                                                      if (!ok) return;

                                                      final saved = await c.save();
                                                      if (!mounted) return;

                                                      if (saved) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Saved successfully ✅")),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text("Save failed: ${c.error ?? ''}")),
                                                        );
                                                      }
                                                    },
                                              child: c.isSaving
                                                  ? const SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    )
                                                  : const Text("Done"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      _ActionBtn(
                                        text: "Reset password",
                                        color: const Color(0xFF2F7BFF),
                                        onPressed: () => c.goResetPassword(context),
                                      ),
                                      const SizedBox(height: 12),
                                      _ActionBtn(
                                        text: "Delete account",
                                        color: Colors.red,
                                        onPressed: () => c.deleteAccount(context),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }
}

// ---------- Widgets ----------
class _Header extends StatelessWidget {
  const _Header({
    required this.purple,
    required this.profile,
    required this.isEditing,
    required this.pickedImageFile,
    required this.onPickImage,
    required this.nameCtrl,
    required this.titleCtrl,
    required this.onEditTap,
    required this.nameValidator,
    required this.titleValidator,
  });

  final Color purple;
  final FreelancerProfileModel profile;
  final bool isEditing;
  final File? pickedImageFile;
  final VoidCallback onPickImage;

  final TextEditingController nameCtrl;
  final TextEditingController titleCtrl;
  final VoidCallback? onEditTap;

  final String? Function(String?) nameValidator;
  final String? Function(String?) titleValidator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            color: const Color(0xFFF2EAFB),
            border: Border.all(color: purple.withOpacity(0.25)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -160,
                right: -160,
                child: Container(
                  width: 420,
                  height: 420,
                  decoration: const BoxDecoration(color: Color(0xFFE7DDF8), shape: BoxShape.circle),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                backgroundImage: pickedImageFile != null
                                    ? FileImage(pickedImageFile!)
                                    : (profile.photoUrl != null
                                        ? NetworkImage(profile.photoUrl!) as ImageProvider
                                        : null),
                                child: (pickedImageFile == null && profile.photoUrl == null)
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
                      const SizedBox(height: 12),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 240,
                            child: TextFormField(
                              controller: nameCtrl,
                              enabled: isEditing,
                              validator: nameValidator,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: purple, fontSize: 28, fontWeight: FontWeight.w800),
                              decoration: const InputDecoration(
                                hintText: 'Enter your job title (e.g., Graphic Designer)', 
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (!isEditing)
                            IconButton(
                              onPressed: onEditTap,
                              icon: Icon(Icons.edit, color: purple, size: 20),
                            ),
                        ],
                      ),

                      SizedBox(
                        width: 260,
                        child: TextFormField(
                          controller: titleCtrl,
                          enabled: isEditing,
                          validator: titleValidator,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            isDense: true,
                          ),
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
  const _SectionCard({required this.child, required this.borderColor, this.background});

  final Widget child;
  final Color borderColor;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6)),
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
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w700)),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: purple, width: 1.4)),
            disabledBorder: border.copyWith(borderSide: BorderSide(color: purple.withOpacity(0.18), width: 1.2)),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyBlock extends StatelessWidget {
  const _ReadOnlyBlock({required this.title, required this.value, required this.purple});

  final String title;
  final String value;
  final Color purple;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: purple, fontSize: 22, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.purple,
    required this.experience,
    required this.editable,
    required this.onEdit,
    required this.onDelete,
  });

  final Color purple;
  final ExperienceModel experience;
  final bool editable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: purple.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF2EAFB),
            child: Icon(Icons.school, color: purple),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(experience.field, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(experience.org, style: TextStyle(color: purple, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(experience.period, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]),
          ),
          if (editable) ...[
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 18)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, size: 18, color: Colors.red)),
          ],
        ],
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({required this.purple});
  final Color purple;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Icon(Icons.image, color: purple),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.text, required this.color, required this.onPressed});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white.withOpacity(0.6),
      ),
      child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _StarsReadOnly extends StatelessWidget {
  const _StarsReadOnly({required this.value, this.size = 20});
  final double value;
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

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.options,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.purple,
  });

  final List<String> options;
  final String value;
  final bool enabled;
  final void Function(String v) onChanged;
  final Color purple;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: purple.withOpacity(0.25)),
      ),
      child: Row(
        children: options.map((o) {
          final selected = o == value;
          return Expanded(
            child: InkWell(
              onTap: enabled ? () => onChanged(o) : null,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? purple.withOpacity(0.14) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    o,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? purple : Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}