import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neovote/features/auth/presentation/theme/theme.dart';
import 'package:neovote/features/elections/presentation/pages/elections_page.dart';
import 'custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'package:neovote/features/auth/presentation/widgets/auth_header.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //global form key for field validation
  final _formSignUpKey = GlobalKey<FormState>();
  //text controllers for voter data fields
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //Async process
  bool _isLoading = false;

  //firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Register voters
  Future<void> _signUpWithEmail() async {
    if (!_formSignUpKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        //set display name on Firebase User record
        await user.updateDisplayName(_nameController.text.trim());

        //Initialize voter profile in Cloud Firestore with National ID
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': _nameController.text.trim(),
          'nationalId': _nationalIdController.text.trim(),
          'role': 'voter',
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'last_login_at': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Welcome to NeoVote.'),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ElectionsPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Signup failed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          //Top Spacer
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignUpKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'Join NeoVote',
                        subtitle:
                            'Register your verified voter account to participate in upcoming institutional ballots.',
                        showBadge: true,
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _nationalIdController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please Enter your National ID';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'National ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your Email',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Create a strong password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signUpWithEmail,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              )
                            : const Text('Sign up & Enter Elections'),
                      ),

                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
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
        ],
      ),
    );
  }
}
