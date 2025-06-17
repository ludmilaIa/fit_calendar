import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

class AuthService {
  final String _baseUrl = Env.apiBaseUrl;
  static const String _tokenKey = 'auth_token';

  // Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> register({
    required String name, 
    required String email, 
    required String password, 
    required String passwordConfirmation,
    required String role,
  }) async {
    try {
      final requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        'language': 'es',
      };
      
      developer.log('Enviando solicitud de registro: $requestBody');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      developer.log('Respuesta del servidor (${response.statusCode}): ${response.body}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save token if available
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Error de registro',
        };
      }
    } catch (e) {
      developer.log('Error en el registro: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final requestBody = {
        'email': email,
        'password': password,
      };
      
      developer.log('Enviando solicitud de login: $requestBody');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      developer.log('Respuesta del servidor (${response.statusCode}): ${response.body}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Save token if available
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Error de inicio de sesión',
        };
      }
    } catch (e) {
      developer.log('Error en el inicio de sesión: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      // Get the stored token
      final token = await getToken();
      
      if (token == null) {
        developer.log('No hay token de autenticación para cerrar sesión');
        await clearToken(); // Clear any remnant data
        return {
          'success': true,
          'message': 'No session to logout'
        };
      }
      
      developer.log('Enviando solicitud de logout con token');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Respuesta del servidor (${response.statusCode}): ${response.body}');
      
      // Clear the token regardless of response
      await clearToken();
      
      if (response.statusCode == 200 || response.statusCode == 401) {
        // Consider 401 as "already logged out"
        return {
          'success': true,
        };
      } else {
        dynamic data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          data = {'message': 'Error al procesar la respuesta'};
        }
        
        return {
          'success': false,
          'error': data['message'] ?? 'Error al cerrar sesión',
        };
      }
    } catch (e) {
      developer.log('Error al cerrar sesión: $e', error: e);
      // Clear token on error as well
      await clearToken();
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      // Get the stored token
      final token = await getToken();
      
      if (token == null) {
        developer.log('No hay token para obtener información del usuario');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }
      
      developer.log('Obteniendo información del usuario con token');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Respuesta del servidor (${response.statusCode}): ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        dynamic data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          data = {'message': 'Error al procesar la respuesta'};
        }
        
        return {
          'success': false,
          'error': data['message'] ?? 'Error al obtener información del usuario',
        };
      }
    } catch (e) {
      developer.log('Error al obtener información del usuario: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
} 