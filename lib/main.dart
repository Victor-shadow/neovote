import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neovote/features/auth/presentation/pages/screen_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NeoVoteApp());
}

class NeoVoteApp extends StatelessWidget {
  const NeoVoteApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoVote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
      ),
      home: const ScreenPage(),
    );
  }
}