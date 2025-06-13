import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_service.dart';

class ScheduleService {
  final String _baseUrl = Env.apiBaseUrl;
  final AuthService _authService = AuthService();

  // Map sport names to IDs (for now using index + 1 as ID)
  int _getSportId(String sportName) {
    // Simple mapping: using 1 as default for "Futbol"
    // This can be enhanced with a proper mapping from backend
    if (sportName.toLowerCase().contains('futbol') || sportName.toLowerCase().contains('fútbol')) {
      return 1;
    }
    return 1; // Default to 1 for now
  }

  Future<Map<String, dynamic>> createSpecificAvailability({
    required String sport,
    required DateTime date,
    required String startTime,
    required String endTime,
    required bool isOnline,
    required String location,
  }) async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para crear disponibilidad');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }

      // Convert time format from "9:00 AM" to "09:00"
      String convertTimeFormat(String timeStr) {
        if (timeStr.isEmpty) return '';
        
        try {
          // Remove extra spaces and normalize
          timeStr = timeStr.trim();
          
          // Handle formats like "9:00 AM" or "10:30 PM"
          final parts = timeStr.split(' ');
          if (parts.length == 2) {
            final timePart = parts[0];
            final period = parts[1].toUpperCase();
            
            final timeParts = timePart.split(':');
            if (timeParts.length == 2) {
              int hour = int.parse(timeParts[0]);
              int minute = int.parse(timeParts[1]);
              
              // Convert to 24-hour format
              if (period == 'PM' && hour != 12) {
                hour += 12;
              } else if (period == 'AM' && hour == 12) {
                hour = 0;
              }
              
              return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
            }
          }
          
          // If already in HH:MM format, return as is
          return timeStr;
        } catch (e) {
          developer.log('Error converting time format: $e');
          return timeStr;
        }
      }

      final requestBody = {
        'sport_id': _getSportId(sport),
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'start_time': convertTimeFormat(startTime),
        'end_time': convertTimeFormat(endTime),
        'is_online': isOnline,
        'location': location,
        'capacity': 4, // Default capacity as per user requirement
      };
      
      developer.log('Enviando solicitud de crear disponibilidad: $requestBody');
      developer.log('Token usado: ${authToken.substring(0, 10)}...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/specific-availabilities'),
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
          'error': data['message'] ?? 'Error al crear la disponibilidad',
        };
      }
    } catch (e) {
      developer.log('Error al crear disponibilidad: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getCoachAvailabilities() async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para obtener disponibilidades');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }

      developer.log('Obteniendo disponibilidades específicas del coach...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/specific-availabilities'),
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
          'error': data['message'] ?? 'Error al obtener las disponibilidades',
        };
      }
    } catch (e) {
      developer.log('Error al obtener disponibilidades: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
} 