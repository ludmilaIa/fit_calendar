import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_service.dart';
import 'sports_service.dart';

class ScheduleService {
  final String _baseUrl = Env.apiBaseUrl;
  final AuthService _authService = AuthService();
  final SportsService _sportsService = SportsService();
  Map<String, int> _sportsNameToId = {}; // Cache for name-to-ID mapping

  // Map sport names to IDs using the sports service
  Future<int> _getSportId(String sportName) async {
    // Load mapping if not cached
    if (_sportsNameToId.isEmpty) {
      await _loadSportsMapping();
    }
    
    // Find sport ID by name
    final sportId = _sportsNameToId[sportName];
    if (sportId != null) {
      developer.log('Sport mapping: "$sportName" -> ID $sportId');
      return sportId;
    }
    
    // Fallback: try partial matching for common variations
    for (final entry in _sportsNameToId.entries) {
      if (entry.key.toLowerCase().contains(sportName.toLowerCase()) ||
          sportName.toLowerCase().contains(entry.key.toLowerCase())) {
        developer.log('Sport partial match: "$sportName" -> "${entry.key}" -> ID ${entry.value}');
        return entry.value;
      }
    }
    
    developer.log('Warning: Sport "$sportName" not found, defaulting to ID 1');
    return 1; // Default fallback
  }

  Future<void> _loadSportsMapping() async {
    try {
      final result = await _sportsService.getAllSports();
      
      if (result['success']) {
        final data = result['data'];
        if (data is List) {
          _sportsNameToId.clear();
          for (var sport in data) {
            final id = sport['id'] as int?;
            final nameEs = sport['name_es'] as String?;
            final name = sport['name'] as String?;
            
            if (id != null) {
              // Add both name_es and name as keys
              if (nameEs != null) {
                _sportsNameToId[nameEs] = id;
              }
              if (name != null && name != nameEs) {
                _sportsNameToId[name] = id;
              }
            }
          }
          developer.log('Sports name-to-ID mapping loaded: $_sportsNameToId');
        }
      }
    } catch (e) {
      developer.log('Error loading sports mapping: $e');
    }
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

      // Get user info to obtain coach ID
      final userInfoResult = await _authService.getUserInfo();
      if (!userInfoResult['success']) {
        developer.log('Error obteniendo información del usuario: ${userInfoResult['error']}');
        return {
          'success': false,
          'error': 'Error obteniendo información del usuario: ${userInfoResult['error']}'
        };
      }

      final userData = userInfoResult['data'];
      final userId = userData['id'];
      
      if (userId == null) {
        developer.log('No se pudo obtener el ID del usuario');
        return {
          'success': false,
          'error': 'No se pudo obtener el ID del usuario'
        };
      }

      developer.log('User ID obtenido: $userId');

      // Get coach info using the coach profile endpoint to get the actual coach_id
      developer.log('Obteniendo información del coach...');
      final coachResponse = await http.get(
        Uri.parse('$_baseUrl/api/coach/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      developer.log('Respuesta del perfil del coach (${coachResponse.statusCode}): ${coachResponse.body}');

      if (coachResponse.statusCode != 200) {
        return {
          'success': false,
          'error': 'Error obteniendo perfil del coach'
        };
      }

      final coachData = jsonDecode(coachResponse.body);
      final coachId = coachData['id'];

      if (coachId == null) {
        developer.log('No se pudo obtener el ID del coach del perfil');
        return {
          'success': false,
          'error': 'No se pudo obtener el ID del coach'
        };
      }

      developer.log('Coach ID obtenido para crear disponibilidad: $coachId');

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
        'coach_id': coachId,
        'sport_id': await _getSportId(sport),
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

      developer.log('Obteniendo todas las disponibilidades específicas...');
      
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

  Future<Map<String, dynamic>> getOwnCoachAvailabilities() async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para obtener disponibilidades');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }

      // Get user info to obtain coach ID
      final userInfoResult = await _authService.getUserInfo();
      if (!userInfoResult['success']) {
        developer.log('Error obteniendo información del usuario: ${userInfoResult['error']}');
        return {
          'success': false,
          'error': 'Error obteniendo información del usuario: ${userInfoResult['error']}'
        };
      }

      final userData = userInfoResult['data'];
      final userId = userData['id'];
      
      if (userId == null) {
        developer.log('No se pudo obtener el ID del usuario');
        return {
          'success': false,
          'error': 'No se pudo obtener el ID del usuario'
        };
      }

      developer.log('User ID obtenido: $userId');

      // Get coach info using the coach profile endpoint to get the actual coach_id
      developer.log('Obteniendo información del coach...');
      final coachResponse = await http.get(
        Uri.parse('$_baseUrl/api/coach/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      developer.log('Respuesta del perfil del coach (${coachResponse.statusCode}): ${coachResponse.body}');

      if (coachResponse.statusCode != 200) {
        return {
          'success': false,
          'error': 'Error obteniendo perfil del coach'
        };
      }

      final coachData = jsonDecode(coachResponse.body);
      final coachId = coachData['id'];

      if (coachId == null) {
        developer.log('No se pudo obtener el ID del coach del perfil');
        return {
          'success': false,
          'error': 'No se pudo obtener el ID del coach'
        };
      }

      developer.log('Obteniendo disponibilidades específicas del coach ID: $coachId');
      
      // Add coach_id as query parameter
      final uri = Uri.parse('$_baseUrl/api/specific-availabilities').replace(
        queryParameters: {'coach_id': coachId.toString()}
      );
      
      developer.log('URL completa para consultar disponibilidades: $uri');
      
      final response = await http.get(
        uri,
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

  // Método temporal para debug - consultar todas las disponibilidades sin filtro
  Future<Map<String, dynamic>> getAllAvailabilitiesForDebug() async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para obtener disponibilidades');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }

      developer.log('DEBUG: Obteniendo TODAS las disponibilidades sin filtro...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/specific-availabilities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      developer.log('DEBUG: Respuesta del servidor (${response.statusCode}): ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          developer.log('DEBUG: Total de disponibilidades encontradas: ${data.length}');
          for (var item in data) {
            developer.log('DEBUG: Disponibilidad ID ${item['id']}, coach_id: ${item['coach_id']}, fecha: ${item['date']}');
          }
        }
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Error al obtener disponibilidades para debug',
        };
      }
    } catch (e) {
      developer.log('DEBUG: Error al obtener disponibilidades: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
} 