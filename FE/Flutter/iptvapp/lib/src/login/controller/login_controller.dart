import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _loginService = LoginService();

  Future<void> login() async {
    try {
      final response = await _loginService.login(
        usernameController.text,
        passwordController.text,
      );

      // Store tokens securely (use flutter_secure_storage in production)
      final accessToken = response['accessToken'];
      final refreshToken = response['refreshToken'];

      // Navigate to home page or handle success
      print('Login successful: $accessToken');
    } catch (e) {
      // Handle error
      print('Login failed: $e');
    }
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}

class LoginService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
    contentType: 'application/json',
  ));

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/api/login', data: {
        'username': username,
        'password': password,
      });

      return response.data;
    } catch (e) {
      throw Exception('Login failed');
    }
  }
}
