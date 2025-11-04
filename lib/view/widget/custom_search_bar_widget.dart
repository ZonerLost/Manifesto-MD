import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  /// NEW: optional clear callback (e.g., to reset filters)
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText,
    this.onClear,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _ctrl;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ctrl = widget.controller ?? TextEditingController();

    // Rebuild on text change so suffix (clear/search) updates
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      _ctrl.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _ctrl.clear();
    // Propagate both "cleared" and "changed" to parent
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {}); // refresh suffix icon
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _ctrl.text.isNotEmpty;

    return TextFormField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText:
        widget.hintText ?? 'Type your main clinical manifestations here',
        hintStyle: const TextStyle(color: kHintColor, fontSize: 14),
        filled: true,
        fillColor: kBorderColor,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Image.asset(Assets.imagesSearchIcon, height: 20),
        ),
        prefixIconConstraints:
        const BoxConstraints(minHeight: 20, minWidth: 20),
        suffixIcon: hasText
            ? IconButton(
          tooltip: 'Clear',
          onPressed: _handleClear,
          icon: const Icon(Icons.close, size: 18, color: kHintColor),
        )
            : null,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:  BorderSide(color: kBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:  BorderSide(color: kBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kSecondaryColor, width: 1),
        ),
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
