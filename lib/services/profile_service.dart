import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_service.dart';

class ProfileService {
  final String _baseUrl = Env.apiBaseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> updateProfile({
    int? age,
    String? description,
    String? token,
    // Remove sports parameter for now
    // List<String>? sports,
  }) async {
    try {
      // Get the token from parameter or stored preferences
      final String? authToken = token ?? await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para actualizar el perfil');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }
      
      // Create request body with only provided values
      final Map<String, dynamic> requestBody = {};
      
      if (age != null) {
        requestBody['age'] = age;
      }
      
      if (description != null) {
        requestBody['description'] = description;
      }
      
      // Remove sports handling for now
      // if (sports != null && sports.isNotEmpty) {
      //   requestBody['sports'] = sports;
      // }
      
      developer.log('Enviando solicitud de actualización de perfil: $requestBody');
      developer.log('Token usado: ${authToken.substring(0, 10)}...');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
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
          'error': data['message'] ?? 'Error al actualizar el perfil',
        };
      }
    } catch (e) {
      developer.log('Error al actualizar el perfil: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
} 