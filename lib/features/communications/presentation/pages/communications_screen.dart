import 'package:flutter/material.dart';
import 'package:tuiipwa/features/communications/presentation/widgets/stream_chat_form.dart';

class CommunicationsScreen extends StatefulWidget {
  const CommunicationsScreen({super.key});

  @override
  State<CommunicationsScreen> createState() => _CommunicationsScreenState();
}

class _CommunicationsScreenState extends State<CommunicationsScreen> {
  @override
  Widget build(BuildContext context) {
    return const StreamChatForm();
  }
}
