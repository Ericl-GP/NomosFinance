import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept':
              'application/json', // Importante para o Laravel entender que é API
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'] ?? data['token'];
        final user = data['user'];

        if (token is! String || token.isEmpty) {
          print('Token ausente na resposta de login: ${response.body}');
          return false;
        }

        await _saveToken(token);

        if (user is Map<String, dynamic>) {
          final name = user['name'] as String?;
          final email = user['email'] as String?;
          if (name != null && name.isNotEmpty) {
            await _saveUserName(name);
          }
          if (email != null && email.isNotEmpty) {
            await _saveEmail(email);
          }
        }

        return true;
      } else {
        print('Erro no login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return false;
    }
  }

  // Persistindo o Token com Shared Preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Recuperando o token para futuras requisições autenticadas
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Recuperando o nome do usuário salvo localmente
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  // Recuperando o email do usuário salvo localmente
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // Logout
  Future<void> logout() async {
    final token = await getToken();

    if (token != null && token.isNotEmpty) {
      try {
        final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}',
        );
        await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        print('Erro ao chamar logout na API: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
