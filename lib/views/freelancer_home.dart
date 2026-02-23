import 'package:flutter/material.dart';

import 'freelancer_profile.dart'; // نفس مجلد views

class FreelancerHomeView extends StatelessWidget {
  const FreelancerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Freelancer Home"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        // ✅ زر البروفايل هنا
        actions: [
          IconButton(
            tooltip: "Profile",
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FreelancerProfileView()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: const Center(
        child: Text("Welcome Freelancer 👋"),
      ),
    );
  }
}