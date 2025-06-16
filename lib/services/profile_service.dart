import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_service.dart';

class ProfileService {
  final String _baseUrl = Env.apiBaseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getCoachProfile() async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para obtener perfil del coach');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }

      developer.log('Obteniendo perfil del coach...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/coach/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
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
          'error': data['message'] ?? 'Error al obtener el perfil del coach',
        };
      }
    } catch (e) {
      developer.log('Error al obtener perfil del coach: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getCoachProfileWithUser() async {
    try {
      // Get both coach profile and user data
      final coachResult = await getCoachProfile();
      final userResult = await _authService.getUserInfo();
      
      if (!coachResult['success']) {
        return coachResult;
      }
      
      if (!userResult['success']) {
        return userResult;
      }
      
      // Combine the data
      final coachData = coachResult['data'];
      final userData = userResult['data'];
      
      // Merge user data into coach data
      final combinedData = Map<String, dynamic>.from(coachData);
      combinedData['user'] = userData;
      combinedData['name'] = userData['name'];
      
      developer.log('Combined coach and user data: $combinedData');
      
      return {
        'success': true,
        'data': combinedData,
      };
    } catch (e) {
      developer.log('Error al obtener perfil completo del coach: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Updates the coach profile with the provided data
  /// PUT /api/coach/profile
  Future<Map<String, dynamic>> updateCoachProfile({
    int? age,
    String? description,
  }) async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para actualizar el perfil del coach');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }
      
      // Create request body with provided values
      final Map<String, dynamic> requestBody = {};
      
      if (age != null) {
        requestBody['age'] = age;
      }
      
      if (description != null) {
        requestBody['description'] = description;
      }
      
      developer.log('Enviando solicitud de actualización de perfil del coach: $requestBody');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/api/coach/profile'),
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
          'error': data['message'] ?? 'Error al actualizar el perfil del coach',
        };
      }
    } catch (e) {
      developer.log('Error al actualizar el perfil del coach: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Updates the user profile (for students/fitters) with the provided data
  /// PUT /api/user/profile
  Future<Map<String, dynamic>> updateUserProfile({
    int? age,
    String? description,
  }) async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para actualizar el perfil del usuario');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }
      
      // Create request body with provided values
      final Map<String, dynamic> requestBody = {};
      
      if (age != null) {
        requestBody['age'] = age;
      }
      
      if (description != null) {
        requestBody['description'] = description;
      }
      
      developer.log('Enviando solicitud de actualización de perfil del usuario: $requestBody');
      
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
          'error': data['message'] ?? 'Error al actualizar el perfil del usuario',
        };
      }
    } catch (e) {
      developer.log('Error al actualizar el perfil del usuario: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Legacy method - kept for backward compatibility
  /// Uses /api/user/profile endpoint
  @deprecated
  Future<Map<String, dynamic>> updateProfile({
    int? age,
    String? description,
    String? token,
  }) async {
    return updateUserProfile(
      age: age,
      description: description,
    );
  }
} 