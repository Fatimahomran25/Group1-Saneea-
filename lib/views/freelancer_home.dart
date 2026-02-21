import 'package:flutter/material.dart';

class FreelancerHomeScreen extends StatelessWidget {
  const FreelancerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Freelancer Home')),
      body: const Center(child: Text('Welcome Freelancer 👋')),
    );
  }
}
