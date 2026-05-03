import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.navBg,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _navItem(0, Icons.home_rounded),
            _navItem(1, Icons.search_rounded),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: onCenterTap,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.accentPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
            _navItem(2, Icons.location_on_rounded),
            _navItem(3, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon) {
    final selected = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? AppColors.accentYellow : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: selected ? AppColors.textPrimary : Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
