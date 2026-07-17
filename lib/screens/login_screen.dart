import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final specialKeyController = TextEditingController();

  bool _hidePassword = true;

  String selectedRole = 'Resident';

  // SPECIAL ACCESS KEYS
  final String securityOfficerKey = "SECURE123";
  final String councilStaffKey = "COUNCIL456";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 36),

                const AppLogo(),

                const SizedBox(height: 34),

                // EMAIL FIELD
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Enter a valid email address'
                      : null,
                ),

                const SizedBox(height: 16),

                // PASSWORD FIELD
                TextFormField(
                  controller: passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your password'
                      : null,
                ),

                const SizedBox(height: 16),

                // USER ROLE DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'User Type',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Resident',
                      child: Text('Resident'),
                    ),
                    DropdownMenuItem(
                      value: 'Security Officer',
                      child: Text('Security Officer'),
                    ),
                    DropdownMenuItem(
                      value: 'Council Staff',
                      child: Text('Council Staff'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // SPECIAL ACCESS KEY
                if (selectedRole == 'Security Officer' ||
                    selectedRole == 'Council Staff')
                  Column(
                    children: [
                      TextFormField(
                        controller: specialKeyController,
                        decoration: InputDecoration(
                          labelText: 'Special Access Key',
                          prefixIcon: const Icon(Icons.key),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (selectedRole == 'Security Officer') {
                            if (value != securityOfficerKey) {
                              return 'Invalid Security Officer key';
                            }
                          }

                          if (selectedRole == 'Council Staff') {
                            if (value != councilStaffKey) {
                              return 'Invalid Council Staff key';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // FORGOT PASSWORD
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        ForgotPasswordScreen.routeName,
                      );
                    },
                    child: const Text(
                      'Forgot password?',
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // LOGIN BUTTON
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // FIREBASE LOGIN
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );

                        // GET USER DATA
                        DocumentSnapshot userDoc = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .get();

                        String firestoreRole = userDoc['role'];

                        // CHECK ROLE
                        if (firestoreRole != selectedRole) {
                          await FirebaseAuth.instance.signOut();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Incorrect role selected",
                              ),
                            ),
                          );

                          return;
                        }

                        // ROLE-BASED REDIRECTION
                        if (firestoreRole == 'Resident') {
                          Navigator.pushReplacementNamed(
                            context,
                            HomeScreen.routeName,
                          );
                        } else if (firestoreRole == 'Security Officer') {
                          Navigator.pushReplacementNamed(
                            context,
                            '/securityDashboard',
                          );
                        } else if (firestoreRole == 'Council Staff') {
                          Navigator.pushReplacementNamed(
                            context,
                            '/councilDashboard',
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        String message = "Login failed";

                        if (e.code == 'user-not-found') {
                          message = "No user found";
                        } else if (e.code == 'wrong-password') {
                          message = "Wrong password";
                        } else if (e.code == 'invalid-email') {
                          message = "Invalid email";
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Login'),
                ),

                const SizedBox(height: 12),

                // REGISTER BUTTON
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RegisterScreen.routeName,
                    );
                  },
                  child: const Text(
                    'Create New Account',
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Frontend prototype: authentication is mocked until Firebase is connected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
