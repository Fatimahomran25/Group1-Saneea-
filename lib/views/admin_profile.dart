import 'package:flutter/material.dart';
import '../controlles/admin_controller.dart';
import '../models/admin_model.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  static const _primaryPurple = Color.fromRGBO(79, 55, 139, 1);

  final c = AdminController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<AdminModel>(
        future: c.getAdminFromFirebase(),
        builder: (context, snapshot) {

          // ✅ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load admin data.",
                style: TextStyle(color: Colors.red.shade400),
              ),
            );
          }

          // ✅ Data (or fallback if null for any reason)
          final AdminModel admin = snapshot.data ?? c.getAdmin();

          return Stack(
            children: [

              // 🔵 الدائرة البنفسجية الكبيرة + الدائرتين داخلها
              Positioned(
                top: -140,
                right: -140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    // الخلفية البنفسجية
                    Container(
                      width: 380,
                      height: 380,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7DDF8),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // الدائرة الأولى
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _primaryPurple.withOpacity(0.35),
                          width: 1.5,
                        ),
                      ),
                    ),

                    // الدائرة الثانية
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _primaryPurple.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SafeArea(
                child: Column(
                  children: [

                    // 🔙 زر الرجوع
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => c.back(context),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // 👤 صورة البروفايل + زر (+)
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [

                          // الدائرة الرئيسية (Firebase photoUrl أو asset)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _primaryPurple,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: admin.photoUrl != null
                                  ? Image.network(
                                      admin.photoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      admin.photoAssetPath,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),

                          // زر (+) أسفل يمين الصورة
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () async {
                                await c.pickAndUploadAdminPhoto(context);
                                setState(() {}); // ✅ يحدث الصورة بعد الرفع
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primaryPurple,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      admin.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: _primaryPurple,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      admin.role,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 🟣 الكارد الكبير
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F1FA),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 14,
                              color: Colors.black.withOpacity(0.10),
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "National ID / Iqama",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              admin.nationalId,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: _primaryPurple,
                              ),
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              "Email Address",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              admin.email,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: _primaryPurple,
                              ),
                            ),

                            const Spacer(),

                            // 🔘 Reset password
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFB8A9D9),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () => c.resetPassword(context),
                                child: const Text(
                                  "Reset password",
                                  style: TextStyle(
                                    color: Color(0xFF2F7BFF),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 🔘 Log out
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFB8A9D9),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () => c.logout(context),
                                child: const Text(
                                  "Log out",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}