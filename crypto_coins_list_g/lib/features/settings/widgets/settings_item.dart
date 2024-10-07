import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),
      value: value,
      onChanged: onChanged,
    );
  }
}