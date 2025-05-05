// import 'package:flutter/material.dart';
//
// class ItemActionBar extends StatelessWidget {
//   final VoidCallback onShare;
//   final VoidCallback onDelete;
//   final bool isVisible;
//   final bool compact;
//
//   const ItemActionBar({
//     super.key,
//     required this.onShare,
//     required this.onDelete,
//     this.isVisible = true,
//     this.compact = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (!isVisible) return const SizedBox.shrink();
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: onShare,
//             tooltip: 'Chia sẻ',
//             iconSize: compact ? 20 : 24,
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_outline),
//             onPressed: onDelete,
//             tooltip: 'Xóa khỏi yêu thích',
//             iconSize: compact ? 20 : 24,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ItemActionBar extends StatelessWidget {
  final VoidCallback onLeftAction;
  final VoidCallback onRightAction;
  final IconData leftIcon;
  final IconData rightIcon;
  final String leftTooltip;
  final String rightTooltip;
  final bool isVisible;
  final bool compact;

  const ItemActionBar({
    super.key,
    required this.onLeftAction,
    required this.onRightAction,
    required this.leftIcon,
    required this.rightIcon,
    required this.leftTooltip,
    required this.rightTooltip,
    this.isVisible = true,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(leftIcon),
            onPressed: onLeftAction,
            tooltip: leftTooltip,
            iconSize: compact ? 20 : 24,
          ),
          IconButton(
            icon: Icon(rightIcon),
            onPressed: onRightAction,
            tooltip: rightTooltip,
            iconSize: compact ? 20 : 24,
          ),
        ],
      ),
    );
  }
}
