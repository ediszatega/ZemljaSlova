import 'package:flutter/material.dart';
import '../models/event.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => [..._events];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 50));
      
      final List<Map<String, dynamic>> eventsData = [
        {
          'id': 1,
          'title': 'Na Drini ćuprija',
          'organizer': 'Naziv organizatora',
          'date': '21.12.2024.',
          'price': 10.0,
          'imageUrl': 'https://knjige.ba/media/catalog/product/cache/e4d64343b1bc593f1c5348fe05efa4a6/i/v/ivo-andri---na-drini-uprija.jpg',
        },
        {
          'id': 2,
          'title': 'Naslov događaja sa duzim tekstom da vidimo kako se to prikazuje',
          'organizer': 'Naziv organizatora sa duzim tekstom da vidimo kako se to prikazuje',
          'date': '21.12.2024.',
          'price': 0.0,
          'imageUrl': null,
        },
        {
          'id': 3,
          'title': 'Naslov događaja',
          'organizer': 'Naziv organizatora',
          'date': '21.12.2024.',
          'price': 0.0,
          'imageUrl': null,
        },
        {
          'id': 4,
          'title': 'Naslov događaja',
          'organizer': 'Naziv organizatora',
          'date': '21.12.2024.',
          'price': 25.0,
          'imageUrl': null,
        },
        {
          'id': 5,
          'title': 'Naslov događaja',
          'organizer': 'Naziv organizatora',
          'date': '21.12.2024.',
          'price': 0.0,
          'imageUrl': null,
        },
        {
          'id': 6,
          'title': 'Naslov događaja',
          'organizer': 'Naziv organizatora',
          'date': '21.12.2024.',
          'price': 15.0,
          'imageUrl': null,
        },
        {
          'id': 7,
          'title': 'Naslov događaja',
          'organizer': 'Naziv organizatora',
          'date': '21.12.2024.',
          'price': 0.0,
          'imageUrl': null,
        },
        {
          'id': 8,
          'title': 'Naslov događaja',
          'organizer': 'Naziv organizatora',
          'date': '21.12.2024.',
          'price': 10.0,
          'imageUrl': null,
        },
      ];
      
      _events = eventsData.map((data) => Event.fromJson(data)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 