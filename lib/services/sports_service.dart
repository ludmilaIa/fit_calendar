import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_service.dart';

class Sport {
  final int? id;
  final int? sportId;
  final double specificPrice;
  final String specificLocation;
  final int sessionDurationMinutes;

  Sport({
    this.id,
    this.sportId,
    required this.specificPrice,
    required this.specificLocation,
    required this.sessionDurationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? sportId,
      if (sportId != null) 'sport_id': sportId,
      'specific_price': specificPrice,
      'specific_location': specificLocation,
      'session_duration_minutes': sessionDurationMinutes,
    };
  }

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'],
      sportId: json['sport_id'],
      specificPrice: json['specific_price']?.toDouble() ?? 0.0,
      specificLocation: json['specific_location'] ?? '',
      sessionDurationMinutes: json['session_duration_minutes'] ?? 0,
    );
  }
}

class SportsService {
  final String _baseUrl = Env.apiBaseUrl;
  final AuthService _authService = AuthService();

  /// Creates or updates sports for a coach
  /// POST /api/coach/sports
  Future<Map<String, dynamic>> createSports(List<Sport> sports) async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para crear deportes');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }

      final requestBody = {
        'sports': sports.map((sport) => sport.toJson()).toList(),
      };

      developer.log('Enviando solicitud de creación de deportes: $requestBody');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/coach/sports'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      developer.log('Respuesta del servidor (${response.statusCode}): ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
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
          'error': data['message'] ?? 'Error al crear deportes',
        };
      }
    } catch (e) {
      developer.log('Error al crear deportes: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Gets all available sports from the system
  /// GET /api/sports
  Future<Map<String, dynamic>> getAllSports() async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para obtener todos los deportes');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/sports'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      developer.log('Respuesta del servidor getAllSports (${response.statusCode}): ${response.body}');
      
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
          'error': data['message'] ?? 'Error al obtener todos los deportes',
        };
      }
    } catch (e) {
      developer.log('Error al obtener todos los deportes: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
} 