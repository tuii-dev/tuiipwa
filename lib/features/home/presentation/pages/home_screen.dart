import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _BookinfsScreenState();
}

class _BookinfsScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Home Screen"));
  }
}
