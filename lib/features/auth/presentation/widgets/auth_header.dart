import 'package:flutter/material.dart';
import 'package:neovote/features/auth/presentation/theme/theme.dart';

//Reusable branded header widget for authentication screens
//Displays the NeoVote logo, stylized typograpy, subtitle, and a cryptographic security badge

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBadge;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [lightColorScheme.primary, const Color(0xFF1E2A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: lightColorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.how_to_vote_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: lightColorScheme.primary,
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
        if (showBadge) ...[
          const SizedBox(height: 14.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0XFF10B981).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                SizedBox(width: 6),
                Text(
                  'End-to-End Solana Verifiable',

                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0XFF059669),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
