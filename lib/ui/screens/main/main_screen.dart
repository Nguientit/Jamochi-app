import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mood/mood_screen.dart';
import '../ai/ai_screen.dart';
import '../chat/chat_screen.dart';
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
  int _currentIndex = 2;

  final List<Widget> _screens = const [
    MoodScreen(),
    AiScreen(),
    ChatScreen(),
    VaultScreen(),
    SettingsScreen(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      Future.microtask(() => ref.read(chatProvider.notifier).clearUnreadBadge());
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final chatState = ref.watch(chatProvider);
    final hasUnread = chatState.hasUnreadMessages;

    final backgroundColor = palette.primary.withOpacity(0.4);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          _buildThemeSyncNavBar(palette, hasUnread),
        ],
      ),
    );
  }

  Widget _buildThemeSyncNavBar(dynamic palette, bool hasUnread) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 10),
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: palette.accent, 
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: palette.accent.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildElasticItem(Icons.wb_sunny_rounded, 'Mood', 0, palette),
              _buildElasticItem(Icons.smart_toy_rounded, 'Mochi', 1, palette),
              _buildElasticItem(
                Icons.forum_rounded, 
                'Chat', 
                2, 
                palette, 
                showBadge: hasUnread && _currentIndex != 2
              ),
              _buildElasticItem(Icons.favorite_rounded, 'Vault', 3, palette),
              _buildElasticItem(Icons.settings_rounded, 'Setting', 4, palette),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElasticItem(IconData icon, String label, int index, dynamic palette, {bool showBadge = false}) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic, 
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12, 
          vertical: 10
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
                  color: isActive ? palette.accent : Colors.white,
                ),
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: isActive ? Colors.white : palette.accent, width: 2),
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
                          maxLines: 1, 
                          softWrap: false,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.nunito(
                            color: palette.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w900, 
                          ),
                        ),
                      )
                    : const SizedBox(width: 0, height: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}