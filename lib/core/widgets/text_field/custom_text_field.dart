import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';

class CustomTextField extends StatefulWidget {
  /// null이면 라벨 없이 입력창만 렌더링한다 (예: 채팅 입력창).
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final AutovalidateMode autovalidateMode;
  final Color fillColor;
  final double borderRadius;
  final bool showBorder;
  final EdgeInsetsGeometry contentPadding;

  const CustomTextField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.fillColor = AppColors.white,
    this.borderRadius = 10,
    this.showBorder = true,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 16,
    ),
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured = widget.obscureText;

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = widget.showBorder
        ? AppColors.divider
        : Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyle.mainText.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          autovalidateMode: widget.autovalidateMode,
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          textAlignVertical: TextAlignVertical.center,
          style: AppTextStyle.mainText.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyle.mainText.copyWith(
              color: AppColors.placeholder,
            ),
            filled: true,
            fillColor: widget.fillColor,
            isDense: true,
            contentPadding: widget.contentPadding,
            suffixIcon: widget.obscureText
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.placeholder,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
            border: _border(borderColor),
            enabledBorder: _border(borderColor),
            focusedBorder: _border(
              widget.showBorder ? AppColors.primary : Colors.transparent,
            ),
            errorBorder: _border(AppColors.danger),
            focusedErrorBorder: _border(AppColors.danger),
          ),
        ),
      ],
    );
  }
}
