import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _iconBox = 40.0;
const _iconSize = 20.0;
const _rowHeight = 56.0;
const _rowPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const _iconGap = 12.0;
const _dangerTint = 0.08;

/// Row used inside [ProfileGroup]: leading icon in a tinted circle, title,
/// optional muted value and chevron. Destructive rows use the error color and
/// drop the chevron.
class ProfileNavRow extends StatelessWidget {
  const ProfileNavRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final foreground = danger ? error : context.accent;
    final label = danger ? error : null;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowHeight),
        child: Padding(
          padding: _rowPadding,
          child: Row(
            children: [
              Container(
                width: _iconBox,
                height: _iconBox,
                decoration: BoxDecoration(
                  color: danger
                      ? error.withValues(alpha: _dangerTint)
                      : AppDesign.tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: _iconSize, color: foreground),
              ),
              const SizedBox(width: _iconGap),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: label,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
              if (onTap != null && !danger)
                const Icon(
                  Symbols.chevron_right,
                  size: _iconSize,
                  color: AppDesign.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
