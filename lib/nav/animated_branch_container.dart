import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Cross-fades the shell branches instead of swapping them instantly, so
/// tapping the bottom navigation bar reads as a transition and not as a jump.
///
/// Every branch stays alive (like an [IndexedStack] would keep it), only the
/// inactive ones are faded out, made non-interactive and have their tickers
/// paused.
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children.mapIndexed((index, branchNavigator) {
        final isActive = index == currentIndex;

        return AnimatedOpacity(
          opacity: isActive ? 1 : 0,
          duration: _duration,
          curve: Curves.easeOut,
          child: IgnorePointer(
            ignoring: !isActive,
            child: TickerMode(enabled: isActive, child: branchNavigator),
          ),
        );
      }).toList(),
    );
  }
}
