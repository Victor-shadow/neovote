import 'package:flutter/material.dart';
import 'package:neovote/features/auth/presentation/pages/login_page.dart';
import 'package:neovote/features/auth/presentation/pages/signup_page.dart';
import 'package:neovote/features/auth/presentation/theme/theme.dart';
import 'custom_scaffold.dart';
import '../widgets/screen_button.dart';
class ScreenPage extends StatelessWidget{
  const ScreenPage({super.key});

  @override
  Widget build(BuildContext context){
    return CustomScaffold(
      child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints){
          return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Center(
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome to NeoVote!\n',
                                  style: TextStyle(
                                    fontSize: 38.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: '\nEnter personal details to your NeoVote Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                            child: ScreenButton(
                              buttonText: 'Log In',
                              onTap: const LoginPage(),
                              color: Colors.transparent,
                              textColor: Colors.white,
                            ),
                        ),
                        Expanded(
                            child: ScreenButton(
                              buttonText: 'Sign Up',
                              onTap: const SignUpPage(),
                              color: Colors.white,
                              textColor: lightColorScheme.primary,
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
       ),
      ),
    );
  }
}