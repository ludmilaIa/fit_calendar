import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_service.dart';

class BookingService {
  final String _baseUrl = Env.apiBaseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> createBooking({
    required int coachId,
    required int sportId,
    required int specificAvailabilityId,
    required DateTime sessionAt,
  }) async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para crear reserva');
        return {
          'success': false,
          'error': 'No authentication token',
        };
      }

      final requestBody = {
        'coach_id': coachId,
        'sport_id': sportId,
        'specific_availability_id': specificAvailabilityId,
        'session_at': sessionAt.toUtc().toIso8601String(),
      };

      developer.log('Creando reserva: $requestBody');
      developer.log('Token usado: ${authToken.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/bookings'),
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
          'error': data['message'] ?? 'Error al crear la reserva',
        };
      }
    } catch (e) {
      developer.log('Error al crear reserva: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getBookings() async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para obtener reservas');
        return {
          'success': false,
          'error': 'No authentication token'
        };
      }

      developer.log('Obteniendo reservas del usuario...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/bookings'),
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
          'error': data['message'] ?? 'Error al obtener las reservas',
        };
      }
    } catch (e) {
      developer.log('Error al obtener reservas: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId, {String? cancelledReason}) async {
    try {
      final String? authToken = await _authService.getToken();
      
      if (authToken == null) {
        developer.log('No hay token para cancelar reserva');
        return {
          'success': false,
          'error': 'No authentication token',
        };
      }

      developer.log('Cancelando reserva con ID: $bookingId');

      final requestBody = {
        'cancelled_reason': cancelledReason ?? 'Cancelado por el usuario',
      };

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/bookings/$bookingId/cancel'),
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
          'error': data['message'] ?? 'Error al cancelar la reserva',
        };
      }
    } catch (e) {
      developer.log('Error al cancelar reserva: $e', error: e);
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
} 