// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/constansts/routes.dart';
import 'package:my_app/services/auth/auth_exceptions.dart';
import 'package:my_app/services/auth/auth_service.dart';

import 'package:my_app/utilities/show_error_dialog.dart';

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
      future: AuthService.firebase().initialize(),
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
                        await AuthService.firebase().createUser(
                          email: email,
                          password: password,
                        );
                        AuthService.firebase().sendEmailVerification();
                        Navigator.of(context).pushNamed(verifyEmailRoute);
                      } on WeakPasswordAuthException {
                        await showErrorDialog(context, 'Weak Password');
                      } on EmailAlreadyInUseAuthException {
                        showErrorDialog(context, 'User already exist');
                      } on InvalidEmailAuthException {
                        showErrorDialog(context, 'Invalid Email Address');
                      } on GenericAuthException {
                        await showErrorDialog(context, 'Failed to register');
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
