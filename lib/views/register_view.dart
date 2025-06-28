import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/constansts/routes.dart';
import 'package:my_app/firebase_options.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Register')),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email here',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;

                      try {
                        final userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                        devtools.log(
                          'Registered: ${userCredential.user?.uid}'.toString(),
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          devtools.log('Weak Password');
                        } else if (e.code == ' email-is-already-in-use') {
                          devtools.log('User already exist');
                        } else if (e.code == 'invalid-email') {
                          devtools.log('Invalid Email Address');
                        } else {
                          devtools.log(e.code);
                        }
                      }
                    },
                    child: const Text('Register'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                    },
                    child: Text('Already registered? Login here!'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('Loading...'));
        }
      },
    );
  }
}
