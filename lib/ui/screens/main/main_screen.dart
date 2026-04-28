// ui/screens/main/main_screen.dart
// 📁 JAMOCHI_APP/lib/ui/screens/main/main_screen.dart
// 🛡️ FIX: ChatListScreen show ở giữa, tap vào chat mới navigate tới ChatScreen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mood/mood_screen.dart';
import '../achievement/achievement_screen.dart';
import '../chat/chat_list_screen.dart';
import '../vault/vault_screen.dart';
import '../settings/settings_screen.dart';
import '../../../data/providers/mood_provider.dart';
import '../../../data/providers/chat_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  // 🎯 ChatListScreen ở giữa thay vì ChatScreen
  final List<Widget> _screens = const [
    MoodScreen(),
    AchievementScreen(),
    ChatListScreen(),
    VaultScreen(),
    SettingsScreen(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);

    if (index == 2) {
      ref.read(chatProvider.notifier).clearUnread();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final chatState = ref.watch(chatProvider);
    final hasUnread = chatState.hasUnread;

    return Scaffold(
      backgroundColor: palette.primary.withValues(alpha: 0.25),
      extendBody: true,

      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildNavBar(palette, hasUnread),
    );
  }

  Widget _buildNavBar(dynamic palette, bool hasUnread) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 10),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: palette.accent.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.wb_sunny_rounded,
                label: 'Mood',
                navIndex: 0,
                currentIndex: _currentIndex,
                palette: palette,
                onTap: _onTap,
              ),
              _NavItem(
                icon: Icons.emoji_events_rounded,
                label: 'Thành tựu',
                navIndex: 1,
                currentIndex: _currentIndex,
                palette: palette,
                onTap: _onTap,
              ),
              _NavItem(
                icon: Icons.forum_rounded,
                label: 'Chat',
                navIndex: 2,
                currentIndex: _currentIndex,
                palette: palette,
                onTap: _onTap,
                showBadge: hasUnread,
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'Vault',
                navIndex: 3,
                currentIndex: _currentIndex,
                palette: palette,
                onTap: _onTap,
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Setting',
                navIndex: 4,
                currentIndex: _currentIndex,
                palette: palette,
                onTap: _onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int navIndex;
  final int currentIndex;
  final dynamic palette;
  final void Function(int) onTap;
  final bool showBadge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.navIndex,
    required this.currentIndex,
    required this.palette,
    required this.onTap,
    this.showBadge = false,
  });

  bool get isActive => navIndex == currentIndex;

  @override
  Widget build(BuildContext context) {
    final accentColor = palette.accent as Color;
    final inactiveColor = Colors.white.withValues(alpha: 0.65);

    return GestureDetector(
      onTap: () => onTap(navIndex),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? accentColor : inactiveColor,
                ),
                if (showBadge)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? Colors.white : accentColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                child: isActive
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          label,
                          style: GoogleFonts.nunito(
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
