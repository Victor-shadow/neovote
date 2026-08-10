import 'package:flutter/material.dart';
import 'package:neovote/features/auth/presentation/pages/login_page.dart';
import 'package:neovote/features/auth/presentation/pages/signup_page.dart';
import 'package:neovote/features/auth/presentation/theme/theme.dart';
import 'custom_scaffold.dart';
import 'screen_button.dart';


class ScreenPage extends StatelessWidget{
  const ScreenPage({super.key});

  @override
  Widget build(BuildContext context){
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center( 
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan( 
                        text: 'Welcome to NeoVote!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        )), 
                     TextSpan(
                    text: 
                    '\nEnter personal details to your NeoVote Account',
                    style: TextStyle(
                      fontSize: 20,
                    ))
                    ],
                  ), 
                ),
              ),
            ),),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: ScreenButton(
                      buttonText: 'Log In',
                      onTap: const LoginPage(),
                      color: Colors.white,
                      textColor: const Color(0xFF416FDF)
                    ),
                    ),
                  Expanded(
                    child: ScreenButton(
                      buttonText: 'Sign up',
                      onTap: const SignUpPage(),
                      color: lightColorScheme.primary,
                      textColor: Colors.white,
                    ),
                    ),
                 ],
              ),
            )
          )  
        ],
      ),
    );
  }


}