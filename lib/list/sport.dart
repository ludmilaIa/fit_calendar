// Lista de deportes disponibles en el backend con sus IDs correspondientes
final List<Map<String, dynamic>> availableSports = [
  {'id': 1, 'name': 'Fútbol'},
  {'id': 2, 'name': 'Baloncesto'},
  {'id': 3, 'name': 'Tenis'},
  {'id': 4, 'name': 'Natación'},
  {'id': 5, 'name': 'Yoga'},
  {'id': 6, 'name': 'Pilates'},
  {'id': 7, 'name': 'Boxeo'},
  {'id': 8, 'name': 'Ciclismo'},
  {'id': 9, 'name': 'Atletismo'},
  {'id': 10, 'name': 'Padel'},
];

// Función helper para obtener solo los nombres cuando sea necesario
List<String> get availableSportsNames => 
    availableSports.map((sport) => sport['name'] as String).toList();