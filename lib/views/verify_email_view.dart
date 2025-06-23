// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Please verify your email address:'),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              try {
                await user?.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent!')),
                );
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('An unexpected error occurred.'),
                  ),
                );
              }
            },
            child: const Text('Send email verification'),
          ),
        ],
      ),
    );
  }
}
