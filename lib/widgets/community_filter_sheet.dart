import 'package:flutter/material.dart';

import '../data/placeholder_data.dart';
import '../theme/app_theme.dart';

/// Bottom sheet pilih komunitas. `null` berarti "Semua Komunitas".
Future<void> showCommunityFilterSheet(
  BuildContext context, {
  required String? selectedId,
  required ValueChanged<String?> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext sheetContext) {
      void pick(String? id) {
        onSelected(id);
        Navigator.of(sheetContext).pop();
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Pilih Komunitas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            _CommunityTile(
              label: 'Semua Komunitas',
              selected: selectedId == null,
              onTap: () => pick(null),
            ),
            for (final DemoCommunityOption c in kCommunityOptions)
              _CommunityTile(
                label: c.name,
                selected: selectedId == c.id,
                onTap: () => pick(c.id),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label,
          style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.primary : null)),
      trailing:
          selected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}