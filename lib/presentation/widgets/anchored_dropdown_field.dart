import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AnchoredDropdownField<T> extends StatelessWidget {
  const AnchoredDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.prefixIcon,
    this.labelText,
    this.prefixIconColor,
    this.enabled = true,
  });

  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  final IconData prefixIcon;
  final String? labelText;
  final Color? prefixIconColor;
  final bool enabled;

  Future<void> _showMenu(BuildContext context) async {
    final fieldBox = context.findRenderObject() as RenderBox;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final fieldOffset = fieldBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final fieldSize = fieldBox.size;
    final anchor = Rect.fromLTWH(
      fieldOffset.dx,
      fieldOffset.dy + fieldSize.height + 8,
      fieldSize.width,
      0,
    );
    final maxHeight = (items.length * 52.0 + 16).clamp(68.0, 280.0);

    final selected = await showMenu<T>(
      context: context,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlayBox.size),
      constraints: BoxConstraints(
        minWidth: fieldSize.width,
        maxWidth: fieldSize.width,
        maxHeight: maxHeight,
      ),
      color: AppColors.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: items.entries
          .map(
            (item) => PopupMenuItem<T>(
              value: item.key,
              height: 52,
              child: Row(
                children: [
                  Expanded(child: Text(item.value)),
                  if (item.key == value)
                    const Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: AppColors.lime,
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );

    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (fieldContext) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => _showMenu(fieldContext) : null,
          borderRadius: BorderRadius.circular(18),
          child: InputDecorator(
            isEmpty: false,
            decoration: InputDecoration(
              labelText: labelText,
              prefixIcon: Icon(prefixIcon, color: prefixIconColor),
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              enabled: enabled,
            ),
            child: Text(
              items[value] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
