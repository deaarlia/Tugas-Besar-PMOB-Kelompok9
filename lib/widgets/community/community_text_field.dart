import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';

OutlineInputBorder _border(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  borderSide: BorderSide(color: c),
);

class CommunityTextField extends StatelessWidget {
  const CommunityTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.maxLength,
    this.hint,
    this.helper,
    this.errorText,
    this.required = false,
    this.trailing,
    this.maxLines = 1,
    this.minLines,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int maxLength;
  final String? hint;
  final String? helper;
  final String? errorText;
  final bool required;
  final String? trailing;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: AppTextStyles.fieldLabel,
                  children: [
                    if (required)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.error),
                      ),
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: AppTextStyles.helper)
            else
              ListenableBuilder(
                listenable: controller,
                builder: (_, __) => Text(
                  '${controller.text.length}/$maxLength',
                  style: AppTextStyles.helper,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: maxLines,
          style: AppTextStyles.input,
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.hint,
            filled: true,
            fillColor: hasError
                ? AppColors.errorSurface
                : AppColors.surfaceTint,
            suffixIcon: hasError
                ? const Icon(Icons.error_outline, color: AppColors.error)
                : null,
            border: _border(AppColors.outline),
            enabledBorder: _border(
              hasError ? AppColors.error : AppColors.outline,
            ),
            focusedBorder: _border(
              hasError ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(errorText!, style: AppTextStyles.error)),
              ],
            ),
          )
        else if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(helper!, style: AppTextStyles.helper),
          ),
      ],
    );
  }
}
