import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final String? email;

  const ForgotPasswordScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Enter your email to reset your password'),
            TextFormField(
              initialValue: email, // Предварительно заполняем поле email
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Логика сброса пароля
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}