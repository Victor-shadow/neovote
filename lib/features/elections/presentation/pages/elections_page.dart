import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neovote/features/auth/presentation/theme/theme.dart';

class ElectionsPage extends StatefulWidget {
  const ElectionsPage({super.key});

  @override
  State<ElectionsPage> createState() => _ElectionsPageState();
}
class _ElectionsPageState extends State<ElectionsPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAdaptiveAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homeTab(),
          _communityTab(),
          _activityTab(),
          _resultTab(),
          _profileTab(),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  ///Adaptive App Bar with voter profile badge and alert notifications
  PreferredSizeWidget _buildAdaptiveAppBar() {
    final user = FirebaseAuth.instance.currentUser;
    final titles = [
      'Home',
      'Community',
      'Voting Activity',
      'Result',
      'Profile',
    ];

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[_currentIndex],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0XFF0F172A),
            ),
          ),
          if (_currentIndex == 0)
            Text(
              'Welcome, ${user?.displayName ?? 'Verified Voter'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
        ],
      ),
      actions: [
        if (_currentIndex == 0) ...[
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 4),
                Text(
                  'Solana Secured',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],

        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF334155),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No unread election notifications.'),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ========================================
  // TAB 1: HOME
  Widget _homeTab() {
    return const SizedBox.shrink();
  }

  // ==========================================
  // TAB 2: COMMUNITY
  Widget _communityTab() {
    return const SizedBox.shrink();
  }

  // ===========================================
  // TAB 3: MY ACTIVITY
  Widget _activityTab() {
    return const SizedBox.shrink();
  }

  // ============================================
  // TAB 4: RESULT
  Widget _resultTab() {
    return const SizedBox.shrink();
  }

  // ============================================
  // TAB 5: PROFILE
  Widget _profileTab() {
    return const SizedBox.shrink();
  }

  //Adaptive Bottom Navigation Bar
  Widget _bottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),

      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: lightColorScheme.primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.group_outlined),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote_outlined),
            activeIcon: Icon(Icons.how_to_vote_outlined),
            label: 'My Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Result',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
