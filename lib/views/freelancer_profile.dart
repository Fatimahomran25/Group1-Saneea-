import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FreelancerProfilePage extends StatefulWidget {
  const FreelancerProfilePage({super.key});

  @override
  State<FreelancerProfilePage> createState() => _FreelancerProfilePageState();
}

class _FreelancerProfilePageState extends State<FreelancerProfilePage> {
  // ===== ثابتات (غير قابلة للتعديل) =====
  final String nationalId = "1110000000";
  final double rating = 4.0;

  // ===== بيانات قابلة للتعديل =====
  bool isEditing = false;

  late final TextEditingController nameC;
  late final TextEditingController titleC;
  late final TextEditingController emailC;
  late final TextEditingController bioC;

  // خيارات مثل مشروعكم
  static const List<String> serviceTypeOptions = ["one-time", "part-time", "full-time"];
  static const List<String> workingModeOptions = ["in person", "remote", "hybrid"];

  // مجالات الفريلانس (مثل اللي في تقريركم)
  static const List<String> domainOptions = [
    "Graphic Design",
    "Software Development",
    "Marketing",
    "Accounting",
    "Tutoring",
    "UI/UX",
    "Illustration",
    "Branding",
  ];

  String serviceType = "one-time";
  String workingMode = "in person";

  // Bio validation
  String? emailError;
  static const int bioMax = 140;

  // صور
  File? profileImageFile;
  final List<File> portfolioFiles = [];

  // Experience list (ممكن أكثر من واحد)
  final List<ExperienceItem> experiences = [];

  late _Snapshot snapshot;

  // ========= Styles =========
  static const Color kCardBg = Color(0xFFF6F4F9);
  static const Color kCardBorder = Color(0xFFE6E0EF);
  static const Color kAccent = Colors.deepPurple;
  static const Color kMuted = Colors.grey;

  @override
  void initState() {
    super.initState();

    nameC = TextEditingController(text: "Manar Alrazin");
    titleC = TextEditingController(text: "Graphic Designer");
    emailC = TextEditingController(text: "ma.alrazin@gmail.com");
    bioC = TextEditingController(text: "bio bio bio bio ...");

    experiences.add(
      ExperienceItem(
        title: "Graphic Design",
        org: "King Saud University",
        period: "Sep 2019 - Jun 2022",
      ),
    );

    snapshot = _takeSnapshot();
  }

  @override
  void dispose() {
    nameC.dispose();
    titleC.dispose();
    emailC.dispose();
    bioC.dispose();
    super.dispose();
  }

  // ========= Snapshot =========
  _Snapshot _takeSnapshot() => _Snapshot(
        name: nameC.text,
        title: titleC.text,
        email: emailC.text,
        bio: bioC.text,
        serviceType: serviceType,
        workingMode: workingMode,
        profileImageFile: profileImageFile,
        portfolioFiles: List<File>.from(portfolioFiles),
        experiences: experiences.map((e) => e.copy()).toList(),
      );

  void _restoreSnapshot(_Snapshot s) {
    nameC.text = s.name;
    titleC.text = s.title;
    emailC.text = s.email;
    bioC.text = s.bio;

    serviceType = s.serviceType;
    workingMode = s.workingMode;

    profileImageFile = s.profileImageFile;

    portfolioFiles
      ..clear()
      ..addAll(s.portfolioFiles);

    experiences
      ..clear()
      ..addAll(s.experiences.map((e) => e.copy()));

    emailError = null;
  }

  // ========= Validation =========
  bool _validateEmail(String v) {
    final emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    return emailRegex.hasMatch(v.trim());
  }

  void _onEdit() {
    setState(() {
      snapshot = _takeSnapshot();
      isEditing = true;
    });
  }

  void _onCancel() {
    setState(() {
      _restoreSnapshot(snapshot);
      isEditing = false;
    });
  }

  void _onSave() {
    setState(() {
      emailError = null;

      // enforce bio length
      if (bioC.text.length > bioMax) {
        bioC.text = bioC.text.substring(0, bioMax);
      }

      if (!_validateEmail(emailC.text)) {
        emailError = "Invalid email";
        return;
      }

      // TODO: هنا مكان حفظك الحقيقي (Firebase/Provider/Controller)
      isEditing = false;
    });
  }

  // ========= Pickers =========
  Future<void> _pickProfileImage() async {
    if (!isEditing) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return;
    setState(() => profileImageFile = File(x.path));
  }

  Future<void> _addPortfolioImages() async {
    if (!isEditing) return;
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;

    setState(() {
      for (final f in files) {
        portfolioFiles.add(File(f.path));
      }
    });
  }

  void _removePortfolioAt(int i) {
    if (!isEditing) return;
    setState(() => portfolioFiles.removeAt(i));
  }

  // ========= UI Helpers =========
  Future<void> _pickFromOptions({
    required String title,
    required List<String> options,
    required String current,
    required void Function(String v) onPicked,
  }) async {
    if (!isEditing) return;

    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              ...options.map((o) {
                final selected = o == current;
                return ListTile(
                  title: Text(o),
                  trailing: selected ? const Icon(Icons.check, color: kAccent) : null,
                  onTap: () => Navigator.pop(ctx, o),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (picked == null) return;
    setState(() => onPicked(picked));
  }

  // Experience add/edit dialog
  Future<void> _editExperience({ExperienceItem? item, int? index}) async {
    if (!isEditing) return;

    final title = TextEditingController(text: item?.title ?? domainOptions.first);
    final org = TextEditingController(text: item?.org ?? "King Saud University");
    final period = TextEditingController(text: item?.period ?? "Sep 2019 - Jun 2022");

    final result = await showDialog<ExperienceItem>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(item == null ? "Add Experience" : "Edit Experience"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: title.text,
                  items: domainOptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => title.text = v ?? title.text,
                  decoration: const InputDecoration(labelText: "Field", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: org,
                  decoration: const InputDecoration(labelText: "Organization", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: period,
                  decoration: const InputDecoration(labelText: "Period", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  ExperienceItem(title: title.text.trim(), org: org.text.trim(), period: period.text.trim()),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result == null) return;
    setState(() {
      if (item == null) {
        experiences.add(result);
      } else {
        experiences[index!] = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bioCount = bioC.text.length.clamp(0, bioMax);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Freelancer Profile"),
        actions: [
          if (!isEditing) IconButton(icon: const Icon(Icons.edit), onPressed: _onEdit),
          if (isEditing) ...[
            TextButton(onPressed: _onCancel, child: const Text("Cancel")),
            TextButton(onPressed: _onSave, child: const Text("Save")),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _headerCard(),
            const SizedBox(height: 12),

            // Bio (مثل تصميمكم: عنوان + نص + قلم)
            _sectionCard(
              title: "Bio",
              onEdit: isEditing
                  ? () async {
                      // focus on bio field
                    }
                  : null,
              child: isEditing
                  ? TextField(
                      controller: bioC,
                      maxLength: bioMax,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write a short bio...",
                        counterText: "$bioCount/$bioMax",
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    )
                  : Text(bioC.text),
            ),

            const SizedBox(height: 12),
            _informationCard(),

            const SizedBox(height: 12),
            _portfolioCard(),

            const SizedBox(height: 12),
            _ratingCard(),

            const SizedBox(height: 12),
            _reviewsCard(),

            const SizedBox(height: 18),
            if (!isEditing) ...[
              TextButton(onPressed: () {}, child: const Text("Reset password")),
              TextButton(
                onPressed: () {},
                child: const Text("Log out", style: TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ========= Cards =========

  Widget _headerCard() {
    return _card(
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFEFEAFB),
                  backgroundImage: profileImageFile != null ? FileImage(profileImageFile!) : null,
                  child: profileImageFile == null ? const Icon(Icons.person, color: kAccent) : null,
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 16, color: kAccent),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isEditing
                    ? TextField(
                        controller: nameC,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      )
                    : Text(nameC.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                isEditing
                    ? TextField(
                        controller: titleC,
                        decoration: const InputDecoration(
                          labelText: "Job Title",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      )
                    : Text(titleC.text, style: const TextStyle(color: kMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _informationCard() {
    return _sectionCard(
      title: "Information",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kvRow("National ID / Iqama", nationalId, editable: false),

          const SizedBox(height: 10),

          // Email (editable)
          _kvRow(
            "Email Address",
            emailC.text,
            editable: isEditing,
            editor: isEditing
                ? TextField(
                    controller: emailC,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText: emailError,
                    ),
                    onChanged: (v) {
                      setState(() {
                        emailError = null;
                        if (v.isNotEmpty && !_validateEmail(v)) {
                          emailError = "Invalid email";
                        }
                      });
                    },
                  )
                : null,
          ),

          const SizedBox(height: 12),

          // Service Type (options)
          _optionRow(
            label: "Service Type",
            value: serviceType,
            onTap: () => _pickFromOptions(
              title: "Service Type",
              options: serviceTypeOptions,
              current: serviceType,
              onPicked: (v) => serviceType = v,
            ),
          ),

          const SizedBox(height: 10),

          // Working Mode (options)
          _optionRow(
            label: "Working Mode",
            value: workingMode,
            onTap: () => _pickFromOptions(
              title: "Working Mode",
              options: workingModeOptions,
              current: workingMode,
              onPicked: (v) => workingMode = v,
            ),
          ),

          const SizedBox(height: 14),

          // Experience (مثل تصميمكم + add/edit/delete)
          Row(
            children: [
              const Text("Experience", style: TextStyle(color: kMuted)),
              const Spacer(),
              if (isEditing)
                TextButton.icon(
                  onPressed: () => _editExperience(),
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Column(
            children: List.generate(experiences.length, (i) {
              final e = experiences[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i == experiences.length - 1 ? 0 : 10),
                child: _experienceTile(
                  item: e,
                  onEdit: isEditing ? () => _editExperience(item: e, index: i) : null,
                  onDelete: isEditing
                      ? () => setState(() => experiences.removeAt(i))
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _portfolioCard() {
    return _sectionCard(
      title: "Portfolio",
      trailing: isEditing
          ? TextButton.icon(onPressed: _addPortfolioImages, icon: const Icon(Icons.add), label: const Text("Add"))
          : TextButton(onPressed: () {}, child: const Text("View")),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: portfolioFiles.isEmpty ? 4 : portfolioFiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, i) {
          if (portfolioFiles.isEmpty) return _placeholderTile();

          final f = portfolioFiles[i];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(f, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              ),
              if (isEditing)
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    onPressed: () => _removePortfolioAt(i),
                    icon: const Icon(Icons.close, color: Colors.red),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _ratingCard() {
    return _sectionCard(
      title: "Rating",
      child: Row(
        children: [
          Row(
            children: List.generate(5, (i) {
              final filled = i < rating.floor();
              return Icon(filled ? Icons.star : Icons.star_border, color: Colors.amber);
            }),
          ),
          const SizedBox(width: 10),
          Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          const Text("(fixed)", style: TextStyle(color: kMuted)),
        ],
      ),
    );
  }

  Widget _reviewsCard() {
    return _sectionCard(
      title: "Reviews",
      child: Column(
        children: const [
          _ReviewTile(name: "Lina Alharbi", stars: 4, text: "Very good work and fast delivery."),
          SizedBox(height: 10),
          _ReviewTile(name: "Lina Alharbi", stars: 4, text: "Professional and responsive."),
          SizedBox(height: 10),
          _ReviewTile(name: "Lina Alharbi", stars: 4, text: "Loved the design!"),
        ],
      ),
    );
  }

  // ========= Widgets =========

  Widget _experienceTile({
    required ExperienceItem item,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEFEAFB),
            child: const Icon(Icons.school, color: kAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(item.org, style: const TextStyle(color: kAccent, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.period, style: const TextStyle(color: kMuted, fontSize: 12)),
              ],
            ),
          ),
          if (isEditing) ...[
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 18)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, size: 18, color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Widget _placeholderTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: const Icon(Icons.image, color: kAccent),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
    VoidCallback? onEdit,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              if (trailing != null) trailing,
              if (trailing == null && onEdit != null)
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 18)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _optionRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: kMuted)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
        ),
        if (isEditing)
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.edit, size: 18),
          ),
      ],
    );
  }

  Widget _kvRow(String label, String value, {required bool editable, Widget? editor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kMuted)),
        const SizedBox(height: 6),
        if (!editable) Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (editable && editor != null) editor,
        if (editable && editor == null) Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: child,
    );
  }
}

// ============ Models ============
class ExperienceItem {
  final String title;
  final String org;
  final String period;

  ExperienceItem({required this.title, required this.org, required this.period});

  ExperienceItem copy() => ExperienceItem(title: title, org: org, period: period);
}

class _Snapshot {
  final String name;
  final String title;
  final String email;
  final String bio;
  final String serviceType;
  final String workingMode;
  final File? profileImageFile;
  final List<File> portfolioFiles;
  final List<ExperienceItem> experiences;

  _Snapshot({
    required this.name,
    required this.title,
    required this.email,
    required this.bio,
    required this.serviceType,
    required this.workingMode,
    required this.profileImageFile,
    required this.portfolioFiles,
    required this.experiences,
  });
}

// ============ Review Tile ============
class _ReviewTile extends StatelessWidget {
  final String name;
  final int stars;
  final String text;

  const _ReviewTile({required this.name, required this.stars, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < stars;
                    return Icon(filled ? Icons.star : Icons.star_border, size: 18, color: Colors.amber);
                  }),
                ),
                const SizedBox(height: 6),
                Text(text),
              ],
            ),
          )
        ],
      ),
    );
  }
}