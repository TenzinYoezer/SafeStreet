import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _hidePassword = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final specialKeyController = TextEditingController();

  String selectedRole = 'Resident';

  // SPECIAL ACCESS KEYS
  final String securityOfficerKey = "SECURE123";
  final String councilStaffKey = "COUNCIL456";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add_alt_1, size: 70),

              const SizedBox(height: 14),

              const Text(
                'Join SafeStreet',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 24),

              // FULL NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your full name'
                    : null,
              ),

              const SizedBox(height: 16),

              // EMAIL
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),

              const SizedBox(height: 16),

              // PASSWORD
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
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                validator: (value) {
                  List<String> errors = [];

                  if (value == null || value.isEmpty) {
                    return 'Password required';
                  }

                  if (value.length < 8) {
                    errors.add('• Minimum 8 characters');
                  }

                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    errors.add('• 1 uppercase letter');
                  }

                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                    errors.add('• 1 lowercase letter');
                  }

                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    errors.add('• 1 number');
                  }

                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    errors.add('• 1 special character');
                  }

                  if (errors.isNotEmpty) {
                    return errors.join('\n');
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // USER TYPE DROPDOWN
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

              // SPECIAL KEY FIELD
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

              const SizedBox(height: 24),

              // REGISTER BUTTON
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      print("STEP 1");

                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      print("STEP 2");

                      await userCredential.user!.updateDisplayName(
                        nameController.text.trim(),
                      );

                      print("STEP 3");

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .set({
                        'name': nameController.text.trim(),
                        'email': emailController.text.trim(),
                        'password': passwordController.text.trim(),
                        'role': selectedRole,
                        'createdAt': Timestamp.now(),
                      });

                      print("STEP 4");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Account created successfully",
                          ),
                        ),
                      );

                      Navigator.pushReplacementNamed(
                        context,
                        HomeScreen.routeName,
                      );
                    } catch (e) {
                      print("ERROR:");
                      print(e);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString(),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
