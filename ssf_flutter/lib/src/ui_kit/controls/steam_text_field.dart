import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ssf_flutter/src/localization/generated/l10n.dart';

/// Shared editing behavior for search, credentials, filters and numeric inputs.
class const SteamTextField({
  required final TextEditingController controller,
  final FocusNode? focusNode,
  final bool enabled = true,
  final bool autofocus = false,
  final bool obscureText = false,
  final bool autocorrect = true,
  final bool enableSuggestions = true,
  final TextInputType? keyboardType,
  final TextInputAction? textInputAction,
  final TextAlignVertical? textAlignVertical,
  final TextStyle? style,
  final int? minLines,
  final int? maxLines = 1,
  final List<TextInputFormatter>? inputFormatters,
  final InputDecoration decoration = const InputDecoration(),
  final ValueChanged<String>? onChanged,
  final ValueChanged<String>? onSubmitted,
  final String? Function(String?)? validator,
  final bool form = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<TextEditingValue>(
    valueListenable: controller,
    builder: (context, value, _) {
      final InputDecoration inputDecoration = decoration.copyWith(
        suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 24),
        suffixIcon: value.text.isEmpty
            ? null
            : SteamClearButton(
                enabled: enabled,
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
              ),
      );
      if (form) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: autofocus,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: inputDecoration,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
        );
      }
      return TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        autofocus: autofocus,
        obscureText: obscureText,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textAlignVertical: textAlignVertical,
        style: style,
        minLines: minLines,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        decoration: inputDecoration,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
    },
  );
}

class const SteamClearButton({required final VoidCallback onPressed, final bool enabled = true, super.key})
    extends StatefulWidget {
  @override
  State<SteamClearButton> createState() => _SteamClearButtonState();
}

class _SteamClearButtonState() extends State<SteamClearButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: IconButton(
      tooltip: GeneratedLocalizations.of(context).clearText,
      onPressed: widget.enabled ? widget.onPressed : null,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints.tightFor(width: 32, height: 28),
      icon: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _hovered && widget.enabled ? 1.15 : 1,
        child: Icon(
          Icons.close,
          size: 16,
          color: !widget.enabled
              ? const Color(0xFF60666F)
              : _hovered
              ? Colors.white
              : const Color(0xFF9CA4A7),
        ),
      ),
    ),
  );
}
