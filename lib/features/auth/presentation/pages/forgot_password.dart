import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neovote/features/auth/presentation/theme/theme.dart';
import 'custom_scaffold.dart';


class ForgotPasswordScreen extends StatefulWidget{
  const ForgotPasswordScreen({super.key});

  @override 
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();

}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>{
final _formResetPasswordKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final FirebaseAuth _auth = FirebaseAuth.instance;
bool _isLoading = false;

Future<void> _resetPassword() async{
  if(!_formResetPasswordKey.currentState!.validate()) return;

  setState((){
    _isLoading = true;
  });

  try{
    await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset link sent! Check your email inbox.'),
      ),
    );
    Navigator.pop(context);
  } on FirebaseAuthException catch(e){
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Failed to send reset email')),
    );
  } finally {
    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }
}

@override 
void dispose(){
  _emailController.dispose();
  super.dispose();
}

@override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 15),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 40.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formResetPasswordKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Reset Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      const Text(
                        'Enter your account Email below. We will send you a verification link to reset your password!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 14),
                        ),
                        const SizedBox(height: 35.0),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator:(value){
                            if(value == null || value.trim().isEmpty){
                              return 'Please enter your email!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading ? null: _resetPassword,
                          child: _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          ) 
                          : const Text('Send Verification link!'),
                          ),
                          const SizedBox(height: 20.0),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text( 
                              'Back to Login',
                              style: TextStyle(
                                color: lightColorScheme.primary,
                                fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  