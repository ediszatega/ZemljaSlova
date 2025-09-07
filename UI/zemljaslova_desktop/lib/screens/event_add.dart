import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_date_picker.dart';
import '../widgets/image_picker_widget.dart';

class EventAddScreen extends StatefulWidget {
  const EventAddScreen({super.key});

  @override
  State<EventAddScreen> createState() => _EventAddScreenState();
}

class _EventAddScreenState extends State<EventAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Event details controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startAtController = TextEditingController();
  final TextEditingController _endAtController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _lecturersController = TextEditingController();
  final TextEditingController _maxPeopleController = TextEditingController();
  
  // List to store ticket types
  final List<Map<String, dynamic>> _ticketTypes = [];
  
  // Controllers for temporary ticket type form
  final TextEditingController _ticketNameController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _ticketDescriptionController = TextEditingController();
  final TextEditingController _ticketInitialQuantityController = TextEditingController();
  
  bool _isLoading = false;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  
  Uint8List? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startAtController.dispose();
    _endAtController.dispose();
    _organizerController.dispose();
    _lecturersController.dispose();
    _maxPeopleController.dispose();
    _ticketNameController.dispose();
    _ticketPriceController.dispose();
    _ticketDescriptionController.dispose();
    _ticketInitialQuantityController.dispose();
    super.dispose();
  }

  // Add a ticket type to the list
  void _addTicketType() {
    if (_ticketNameController.text.isEmpty || _ticketPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unesite naziv i cijenu karte'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Try parsing the price
    double? price = double.tryParse(_ticketPriceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cijena mora biti broj'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Try parsing the initial quantity
    int? initialQuantity;
    if (_ticketInitialQuantityController.text.isNotEmpty) {
      initialQuantity = int.tryParse(_ticketInitialQuantityController.text);
      if (initialQuantity == null || initialQuantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Početna količina mora biti pozitivan broj'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    setState(() {
      _ticketTypes.add({
        'name': _ticketNameController.text,
        'price': price,
        'description': _ticketDescriptionController.text.isEmpty 
            ? null 
            : _ticketDescriptionController.text,
        'initialQuantity': initialQuantity,
      });
      
      // Clear the form
      _ticketNameController.clear();
      _ticketPriceController.clear();
      _ticketDescriptionController.clear();
      _ticketInitialQuantityController.clear();
    });
  }
  
  // Remove a ticket type from the list
  void _removeTicketType(int index) {
    setState(() {
      _ticketTypes.removeAt(index);
    });
  }
  
  // Date picker helpers
  void _selectStartDate(DateTime date) {
    setState(() {
      _startDateTime = date;
      _startAtController.text = '${date.day}.${date.month}.${date.year}';
    });
  }
  
  void _selectEndDate(DateTime date) {
    setState(() {
      _endDateTime = date;
      _endAtController.text = '${date.day}.${date.month}.${date.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          const SidebarWidget(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/events',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Nazad na pregled događaja'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Dodavanje novog događaja',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Form
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Event basic info section
                                  const Text(
                                    'Osnovni podaci o događaju',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Title field
                                  ZSInput(
                                    label: 'Naslov*',
                                    controller: _titleController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite naslov događaja';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Description field
                                  ZSInput(
                                    label: 'Opis*',
                                    controller: _descriptionController,
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite opis događaja';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Location field
                                  ZSInput(
                                    label: 'Lokacija',
                                    controller: _locationController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Start date field with date picker
                                  ZSDatePicker(
                                    label: 'Početak događaja*',
                                    controller: _startAtController,
                                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                    onDateSelected: _selectStartDate,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite početak događaja';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // End date field with date picker
                                  ZSDatePicker(
                                    label: 'Kraj događaja*',
                                    controller: _endAtController,
                                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                    onDateSelected: _selectEndDate,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite kraj događaja';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Organizer field
                                  ZSInput(
                                    label: 'Organizator',
                                    controller: _organizerController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Lecturers field
                                  ZSInput(
                                    label: 'Predavači',
                                    controller: _lecturersController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Max number of people field
                                  ZSInput(
                                    label: 'Maksimalan broj učesnika',
                                    controller: _maxPeopleController,
                                    keyboardType: TextInputType.number,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Cover image picker
                                  ImagePickerWidget(
                                    label: 'Naslovna slika',
                                    onImageSelected: (imageBytes) {
                                      setState(() {
                                        _selectedImage = imageBytes;
                                      });
                                    },
                                    width: 200,
                                    height: 150,
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Ticket types section
                                  const Text(
                                    'Tipovi ulaznica (opcionalno)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Ulaznice su opcionalne. Možete kreirati događaj bez ulaznica ili dodati ih kasnije. Događaj koji nema ulaznice bit će označen kao besplatan događaj.',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Display existing ticket types
                                  if (_ticketTypes.isNotEmpty) ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _ticketTypes.length,
                                        separatorBuilder: (context, index) => Divider(
                                          color: Colors.grey.shade300,
                                        ),
                                        itemBuilder: (context, index) {
                                          final ticketType = _ticketTypes[index];
                                          return ListTile(
                                            title: Text(ticketType['name']),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(ticketType['description'] ?? 'Bez opisa'),
                                                if (ticketType['initialQuantity'] != null)
                                                  Text(
                                                    'Početna količina: ${ticketType['initialQuantity']}',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${ticketType['price']} KM',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _removeTicketType(index),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  
                                  // Form for adding a new ticket type
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Ticket name
                                      Expanded(
                                        flex: 3,
                                        child: ZSInput(
                                          label: 'Naziv ulaznice',
                                          controller: _ticketNameController,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      
                                      // Ticket price
                                      Expanded(
                                        flex: 2,
                                        child: ZSInput(
                                          label: 'Cijena (KM)',
                                          controller: _ticketPriceController,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      
                                      // Initial quantity
                                      Expanded(
                                        flex: 2,
                                        child: ZSInput(
                                          label: 'Početna količina (opciono)',
                                          controller: _ticketInitialQuantityController,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Ticket description
                                  ZSInput(
                                    label: 'Opis ulaznice',
                                    controller: _ticketDescriptionController,
                                  ),
        
                                  // Add button
                                  ZSButton(
                                    text: 'Dodaj ulaznicu',
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue,
                                    borderColor: Colors.grey.shade300,
                                    onPressed: _addTicketType,
                                  ),

                                  const SizedBox(height: 10),
                                  
                                  // Submit buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ZSButton(
                                        text: 'Spremi događaj',
                                        backgroundColor: Colors.green.shade50,
                                        foregroundColor: Colors.green,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: _submitEvent,
                                      ),
                                      
                                      const SizedBox(width: 20),
                                      
                                      ZSButton(
                                        text: 'Odustani',
                                        backgroundColor: Colors.grey.shade100,
                                        foregroundColor: Colors.grey.shade700,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: () {
                                          Navigator.of(context).pushNamedAndRemoveUntil(
                                            '/events',
                                            (route) => false,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _submitEvent() {
    if (_formKey.currentState!.validate()) {
      // Validate event dates
      if (_startDateTime == null || _endDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unesite datum početka i kraja događaja'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_startDateTime!.isAfter(_endDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datum početka ne može biti nakon datuma završetka'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Get max people count (if provided)
      int? maxPeople;
      if (_maxPeopleController.text.isNotEmpty) {
        maxPeople = int.tryParse(_maxPeopleController.text);
      }
      
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
      });
      
      eventProvider.addEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        startAt: _startDateTime!,
        endAt: _endDateTime!,
        organizer: _organizerController.text.isEmpty ? null : _organizerController.text,
        lecturers: _lecturersController.text.isEmpty ? null : _lecturersController.text,
        maxNumberOfPeople: maxPeople,
        ticketTypes: _ticketTypes.isNotEmpty ? _ticketTypes : null,
        imageBytes: _selectedImage,
      ).then((event) {
        setState(() {
          _isLoading = false;
        });
        
        if (event != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(eventProvider.error != null 
                ? 'Događaj je kreiran, ali: ${eventProvider.error}'
                : 'Događaj je uspješno kreiran!'),
              backgroundColor: eventProvider.error != null ? Colors.orange : Colors.green,
            ),
          );
          
          // Navigate back to events list
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/events',
            (route) => false,
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom kreiranja događaja: ${eventProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 