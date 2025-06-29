// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/constansts/routes.dart';
import 'package:my_app/services/auth/auth_exceptions.dart';
import 'package:my_app/services/auth/auth_service.dart';

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
        children: [
          const Text(
            'A verification email has been sent to your email address. Kindly check your inbox and click on the verification link to continue.',
          ),
          const Text(
            "If you don't see the email, Press the button below to resend it.",
          ),
          TextButton(
            onPressed: () async {
              try {
                await AuthService.firebase().sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent!')),
                );
              } on GenericAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
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
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
