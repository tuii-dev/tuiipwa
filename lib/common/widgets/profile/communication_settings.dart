import 'package:flutter/material.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';

class CommunicationSettingsWidget extends StatefulWidget {
  const CommunicationSettingsWidget({super.key});

  @override
  State<CommunicationSettingsWidget> createState() =>
      _CommunicationSettingsWidgetState();
}

class _CommunicationSettingsWidgetState
    extends State<CommunicationSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Communication Settings".i18n));
  }
}
