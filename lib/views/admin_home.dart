import 'package:flutter/material.dart';
import '../controlles/admin_controller.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const _primaryPurple = Color(0xFF4F378B);
  static const _cardPink = Color(0xFFF6C6C8);

  @override
  Widget build(BuildContext context) {
    final c = AdminController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        // ✅ يسار: أيقونة البروفايل داخل دائرة (مثل UX)
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => c.openProfile(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primaryPurple, width: 1.5),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 18,
                color: _primaryPurple,
              ),
            ),
          ),
        ),

        // ✅ العنوان في المنتصف (من Firebase)
        title: FutureBuilder<String>(
          future: c.getAdminFullName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                "Welcome back...",
                style: TextStyle(
                  color: _primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              );
            }

            final name = (snapshot.data ?? '').trim();
            final safeName = name.isEmpty ? "Admin" : name;

            return Text(
              "Welcome back, $safeName!",
              style: const TextStyle(
                color: _primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),

        // ✅ يمين: الشعار
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/LOGO.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        itemCount: c.items.length,
        itemBuilder: (context, index) {
          final item = c.items[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ✅ الكرت الوردي
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: _cardPink,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),

                      // ✅ دائرة كبيرة فيها أيقونة شخص
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // ✅ الاسم
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      // ✅ زر الحذف يمين
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => c.deleteItem(context, item),
                      ),

                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // ✅ دائرة الرقم الصغيرة فوق يسار
                Positioned(
                  left: -6,
                  top: -10,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFB8A9D9), width: 1.2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${item.number}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: _primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}