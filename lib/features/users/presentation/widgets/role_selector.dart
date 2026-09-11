import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Rol',
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      items: [
        for (final role in UserRole.values)
          DropdownMenuItem<String>(
            value: role.label,
            child: Text(role.label),
          ),
      ],
      onChanged: enabled
          ? (v) {
              if (v != null) onChanged(v);
            }
          : null,
    );
  }
}