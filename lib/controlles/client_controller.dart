import 'package:flutter/material.dart';
import '../models/client_model.dart';

class ClientController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  List<Freelancer> topRated = [
    Freelancer(
      name: "Lina Alharbi",
      role: "Marketing",
      rating: 4.5,
      image: "https://i.pravatar.cc/150?img=1",
    ),
    Freelancer(
      name: "Ahmed Ali",
      role: "Graphic Designer",
      rating: 3.5,
      image: "https://i.pravatar.cc/150?img=2",
    ),
    Freelancer(
      name: "Khalid Fahad",
      role: "Software Developer",
      rating: 2.5,
      image: "https://i.pravatar.cc/150?img=3",
    ),
  ];

  void onSearchChanged(String value) {
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
