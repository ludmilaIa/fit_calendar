import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_service.dart';

class BookingService {
  final String _baseUrl = Env.apiBaseUrl;
  final AuthService _authService = AuthService();

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
} 