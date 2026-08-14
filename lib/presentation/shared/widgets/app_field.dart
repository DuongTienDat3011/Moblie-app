import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// TextFormField chuẩn — dùng trong tất cả form của app
class AppField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool area;            // textarea multi-line
  final IconData? prefixIcon;
  final String? suffix;
  final String? error;
  final String? hintText;
  final bool required;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AppField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.area = false,
    this.prefixIcon,
    this.suffix,
    this.error,
    this.hintText,
    this.required = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(widget.label!, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              )),
              if (widget.required)
                const Text(' *', style: TextStyle(color: AppColors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller:     widget.controller,
          initialValue:   widget.controller == null ? widget.initialValue : null,
          validator:      widget.validator,
          keyboardType:   widget.keyboardType,
          obscureText:    widget.obscureText && _obscure,
          readOnly:       widget.readOnly,
          maxLines:       widget.obscureText ? 1 : (widget.area ? 4 : 1),
          minLines:       widget.area ? 3 : 1,
          onTap:          widget.onTap,
          onChanged:      widget.onChanged,
          inputFormatters:widget.inputFormatters,
          focusNode:      widget.focusNode,
          textInputAction:widget.textInputAction,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText:     widget.hintText ?? widget.hint,
            hintStyle:    const TextStyle(fontSize: 14, color: AppColors.textHint),
            prefixIcon:   widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20, color: AppColors.textSecondary) : null,
            suffixIcon:   widget.obscureText
                ? IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20, color: AppColors.textSecondary),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : (widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Text(widget.suffix!, style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                      )
                    : null),
            suffixIconConstraints: const BoxConstraints(),
            errorText: widget.error,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14, vertical: widget.area ? 14 : 0,
            ),
            alignLabelWithHint: widget.area,
          ),
        ),
        if (widget.hint != null && widget.label != null) ...[
          const SizedBox(height: 4),
          Text(widget.hint!, style: const TextStyle(
            fontSize: 12, color: AppColors.textHint,
          )),
        ],
      ],
    );
  }
}
