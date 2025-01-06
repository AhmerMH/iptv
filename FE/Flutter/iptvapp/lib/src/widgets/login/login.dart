import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:iptvapp/src/services/credentials_service.dart';
import 'package:iptvapp/src/styles/app_style.dart';
import 'package:iptvapp/src/widgets/tvscreen/tvscreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  final _formKey = GlobalKey<FormState>();
  final _serverFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _loginButtonFocus = FocusNode();

  void _fillTestCredentials() {
    _controller.serverUrlController.text = 'http://webhop.xyz:8080';
    _controller.usernameController.text = '96298742369872';
    _controller.passwordController.text = '98726894723642';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.appBackground, // Deep blue background
      floatingActionButton: FloatingActionButton(
        onPressed: _fillTestCredentials,
        backgroundColor: AppStyles.colorInputBackground, // Bright blue accent
        child: const Icon(Icons.data_array, color: AppStyles.colorIcon),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.tv,
                    size: 64,
                    color: AppStyles.appBarBackground, // Bright blue accent
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _controller.serverUrlController,
                    focusNode: _serverFocus,
                    style: const TextStyle(color: AppStyles.colorInputText),
                    decoration: InputDecoration(
                      labelText: 'Server URL',
                      labelStyle: const TextStyle(color: AppStyles.colorIcon), // Soft blue-grey
                      prefixIcon: const Icon(Icons.dns, color: AppStyles.colorIcon),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppStyles.colorIcon), // Medium blue-grey
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppStyles.appBarBackground), // Bright blue accent
                      ),
                      filled: true,
                      fillColor: AppStyles.colorInputBackground, // Slightly lighter blue background
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_usernameFocus);
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _controller.usernameController,
                    focusNode: _usernameFocus,
                    style: const TextStyle(color: AppStyles.colorInputText),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: AppStyles.colorIcon),
                      prefixIcon: const Icon(Icons.person_outline, color: AppStyles.colorIcon),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF526D82)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppStyles.appBarBackground),
                      ),
                      filled: true,
                      fillColor: AppStyles.colorInputBackground,
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _controller.passwordController,
                    focusNode: _passwordFocus,
                    style: const TextStyle(color: AppStyles.colorInputText),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: AppStyles.colorIcon),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppStyles.colorIcon),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF526D82)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppStyles.appBarBackground),
                      ),
                      filled: true,
                      fillColor: AppStyles.colorInputBackground,
                    ),
                    obscureText: true,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_loginButtonFocus);
                    },
                  ),
                  const SizedBox(height: 32),
                  Focus(
                    focusNode: _loginButtonFocus,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _controller.login(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.appBarBackground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _serverFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _loginButtonFocus.dispose();
    super.dispose();
  }
}

class LoginController {
  final TextEditingController serverUrlController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _loginService = LoginService();

  Future<void> login(BuildContext context) async {
    try {
      await _loginService.login(
        serverUrlController.text,
        usernameController.text,
        passwordController.text,
      );

      await CredentialsService.saveCredentials(
        serverUrl: serverUrlController.text,
        username: usernameController.text,
        password: passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TVScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  void dispose() {
    serverUrlController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }
}

class LoginService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(
      String serverUrl, String username, String password) async {
    try {
      final response = await _dio.post(
        '$serverUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
        },
      );

      return response.data;
    } catch (e) {
      throw Exception('Login failed');
    }
  }
}
