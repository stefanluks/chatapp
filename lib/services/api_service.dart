import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  /*
    IMPORTANTE:

    Troque pela URL da sua API no Render.

    Exemplo:
    https://slchat-api.onrender.com
  */

  static const String baseUrl = 'https://chat-api-g2fe.onrender.com';

  String? token;
  int? userId;
  String? username;

  bool get isLoggedIn => token != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    userId = prefs.getInt('userId');
    username = prefs.getString('username');
  }

  Future<void> _saveSession({
    required String newToken,
    required int newUserId,
    required String newUsername,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', newToken);
    await prefs.setInt('userId', newUserId);
    await prefs.setString('username', newUsername);

    token = newToken;
    userId = newUserId;
    username = newUsername;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    token = null;
    userId = null;
    username = null;
  }

  Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token',
    };
  }

  String _getErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}

    return 'Erro na requisição';
  }

  // =================================================
  // CADASTRO
  // =================================================

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        _getErrorMessage(response),
      );
    }
  }

  // =================================================
  // LOGIN
  // =================================================

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(response),
      );
    }

    final data = jsonDecode(response.body);

    final String newToken = data['token'];

    final int id = data['user']['id'];

    final String name = data['user']['username'];

    await _saveSession(
      newToken: newToken,
      newUserId: id,
      newUsername: name,
    );
  }

  // =================================================
  // BUSCAR USUÁRIOS
  // =================================================

  Future<List<dynamic>> searchUsers(
    String search,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/users/search',
    ).replace(
      queryParameters: {
        'username': search,
      },
    );

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(response),
      );
    }

    return jsonDecode(response.body);
  }

  // =================================================
  // LISTAR CONVERSAS
  // =================================================

  Future<List<dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(response),
      );
    }

    return jsonDecode(response.body);
  }

  // =================================================
  // CRIAR CONVERSA
  // =================================================

  Future<Map<String, dynamic>> createConversation(
    int otherUserId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: headers,
      body: jsonEncode({
        'userId': otherUserId,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        _getErrorMessage(response),
      );
    }

    return jsonDecode(response.body);
  }

  // =================================================
  // LISTAR MENSAGENS
  // =================================================

  Future<List<dynamic>> getMessages(
    int conversationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/messages/$conversationId',
      ),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        _getErrorMessage(response),
      );
    }

    return jsonDecode(response.body);
  }

  // =================================================
  // ENVIAR MENSAGEM
  // =================================================

  Future<Map<String, dynamic>> sendMessage(
    int conversationId,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/messages/$conversationId',
      ),
      headers: headers,
      body: jsonEncode({
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        _getErrorMessage(response),
      );
    }

    return jsonDecode(response.body);
  }
}