import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TopicDialog extends StatefulWidget {
  final List<String> existing;

  const TopicDialog({super.key, required this.existing});

  @override
  State<TopicDialog> createState() => _TopicDialogState();
}

class _TopicDialogState extends State<TopicDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text
        .replaceAll('#', '')
        .replaceAll(RegExp(r'\s+'), '');
    if (value.isEmpty) {
      setState(() => _error = 'Topik tidak boleh kosong');
      return;
    }
    final duplicate = widget.existing.any(
      (topic) => topic.toLowerCase() == value.toLowerCase(),
    );
    if (duplicate) {
      setState(() => _error = 'Topik sudah ditambahkan');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Topik'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          prefixText: '#',
          hintText: 'contoh: PraktikumSI',
          errorText: _error,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Tambah')),
      ],
    );
  }
}
