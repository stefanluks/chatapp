import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final usernameController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  Future<void> register() async {
    final username =
        usernameController.text.trim();

    final password =
        passwordController.text;

    final confirm =
        confirmPasswordController.text;

    if (username.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      showMessage(
        'Preencha todos os campos',
      );

      return;
    }

    if (password != confirm) {
      showMessage(
        'As senhas não são iguais',
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.instance.register(
        username: username,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Usuário cadastrado com sucesso',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      showMessage(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Criar conta'),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.person_add_alt_1,
              size: 70,
              color: Color(0xFF1565C0),
            ),

            const SizedBox(height: 30),

            TextField(
              controller:
                  usernameController,
              decoration:
                  const InputDecoration(
                labelText: 'Username',
                prefixIcon:
                    Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  passwordController,
              obscureText: hidePassword,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon:
                    Icon(Icons.lock_outline),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  confirmPasswordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText:
                    'Confirmar senha',
                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      hidePassword =
                          !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility
                        : Icons
                            .visibility_off,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed:
                  loading ? null : register,
              child: loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Cadastrar',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}