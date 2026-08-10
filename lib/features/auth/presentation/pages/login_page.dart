import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:neovote/features/auth/presentation/theme/theme.dart';
import 'signup_page.dart';
import 'custom_scaffold.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formLoginKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool rememberPassword = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();


  @override
  void initState(){
    super.initState();
    _initializeGoogleSignIn();

  }

  Future<void>_initializeGoogleSignIn() async{
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: '405081086950-2fefn9ck71ji4q4iui6r2rji02482056.apps.googleusercontent.com'
      );
    } catch(e){
      debugPrint('Error initializing Google Sign-In: $e');
    }
  }
  

  Future<void> _signInWithEmail() async {
    if(!_formLoginKey.currentState!.validate()) return;

    try{
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        );

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
    } on FirebaseAuthException catch (e){
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login Failed')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try{
      debugPrint('Starting Google Sign-In flow...');
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      debugPrint('Google authentication token required. Signing into Firebase...');
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      debugPrint('Firebase sign-in with Google successful...');

      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in with Google')),
      );
    } catch(e){
      final errorMessage = e.toString().toLowerCase();
      if(errorMessage.contains('cancel') || errorMessage.contains('aborted') || errorMessage.contains('sign_in_canceled') || errorMessage.contains('network_error')){
        return;
      }
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Failed: $e')),
      );
    }
  }

  Future<void>_signInWithBiometrics() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if(!canCheckBiometrics || !isDeviceSupported){
        if(!mounted)return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometrics is not available on this device!')),
        );
        return;
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access NeoVote securely',
        persistAcrossBackgrounding: true,
        biometricOnly: true,
        authMessages: const<AuthMessages>[
        AndroidAuthMessages(
          signInTitle: 'NeoVote Biometric Login',
          cancelButton: 'Cancel',
        ),
      ],
      );

     
      if(authenticated){
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric Login successful')),
        );
      }
    } catch(e){
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric Login Failed: $e')),
      );
    }
  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 15,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
             child: Form(
             key: _formLoginKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Log in to Vote',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight:FontWeight.w900,
                    color: lightColorScheme.primary,
                    ),
                ),
                const SizedBox(
                  height: 40.0
                  ),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value){
                    if(value == null || value.trim().isEmpty){
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Email'),
                    hintText: 'Enter Email',
                    hintStyle: const TextStyle(
                      color: Colors.black26
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                ),

                const SizedBox(
                  height: 25.0,
                  ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  obscuringCharacter: '*',
                  validator: (value){
                    if(value == null || value.trim().isEmpty){
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Password'),
                    hintText: 'Enter Password',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25.0,
                  ),
               ElevatedButton(
                  onPressed: _signInWithEmail,
                  child: const Text('Login'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                    Checkbox(
                      value: rememberPassword, 
                      onChanged: (bool? value){
                        setState(() {
                          rememberPassword =value!;
                        });
                      },
                      activeColor: lightColorScheme.primary,
                         ),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                    ),   
                  ],
                  ),
                  GestureDetector(
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: lightColorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ), 
              const SizedBox(
                height: 25.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.7,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 0, 
                      horizontal: 10,
                  ),
                  child: Text (
                    'Sign up with',
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
              ),
              Expanded(
                child: Divider(
                  thickness: 0.7,
                  color: Colors.grey.withValues(alpha: 0.5),
                   ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _signInWithGoogle,
                    child: Brand(Brands.google),
                  ),
                  GestureDetector(
                    onTap: _signInWithBiometrics,
                    child: Icon(Icons.fingerprint)
                  ),
                ],
              ),
              const SizedBox(
                height: 25.0,
              ),
              //don't have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          )
                        );
                      },
                      child: Text(
                        'Sign Up',
                          style: TextStyle(
                          color: lightColorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ]
  )
);
 }
}