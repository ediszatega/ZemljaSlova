import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import '../models/ticket_type.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_datetime_picker.dart';

class EventEditScreen extends StatefulWidget {
  final int eventId;
  
  const EventEditScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startAtController = TextEditingController();
  final TextEditingController _endAtController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _lecturersController = TextEditingController();
  final TextEditingController _maxPeopleController = TextEditingController();
  
  final List<Map<String, dynamic>> _ticketTypes = [];
  final List<int> _ticketTypesToDelete = [];
  
  final TextEditingController _ticketNameController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _ticketDescriptionController = TextEditingController();
  
  bool _isLoading = true;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  Event? _event;
  
  // Used to track which ticket type is being edited, null means adding a new one
  int? _editingTicketIndex;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }
  
  Future<void> _loadEventData() async {
    setState(() {
      _isLoading = true;
    });
    
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    try {
      final event = await eventProvider.getEventById(widget.eventId);
      
      if (event != null) {
        setState(() {
          _event = event;
          
          _titleController.text = event.title;
          _descriptionController.text = event.description;
          _locationController.text = event.location ?? '';
          _startDateTime = event.startAt;
          _endDateTime = event.endAt;
          _startAtController.text = '${event.startAt.day}.${event.startAt.month}.${event.startAt.year} ${event.startAt.hour}:${event.startAt.minute.toString().padLeft(2, '0')}';
          _endAtController.text = '${event.endAt.day}.${event.endAt.month}.${event.endAt.year} ${event.endAt.hour}:${event.endAt.minute.toString().padLeft(2, '0')}';
          _organizerController.text = event.organizer ?? '';
          _lecturersController.text = event.lecturers ?? '';
          _maxPeopleController.text = event.maxNumberOfPeople?.toString() ?? '';
          
          if (event.ticketTypes != null && event.ticketTypes!.isNotEmpty) {
            for (var ticketType in event.ticketTypes!) {
              _ticketTypes.add({
                'id': ticketType.id,
                'name': ticketType.name,
                'price': ticketType.price,
                'description': ticketType.description,
              });
            }
          }
          
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Događaj nije pronađen'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška prilikom učitavanja događaja: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

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
    
    setState(() {
      // If editing an existing ticket type
      if (_editingTicketIndex != null) {
        // Update the existing ticket type while preserving its ID
        final existingTicket = _ticketTypes[_editingTicketIndex!];
        _ticketTypes[_editingTicketIndex!] = {
          'id': existingTicket.containsKey('id') ? existingTicket['id'] : null,
          'name': _ticketNameController.text,
          'price': price,
          'description': _ticketDescriptionController.text.isEmpty 
              ? null 
              : _ticketDescriptionController.text,
        };
        _editingTicketIndex = null;
      } else {
        // Add a new ticket type
        _ticketTypes.add({
          'name': _ticketNameController.text,
          'price': price,
          'description': _ticketDescriptionController.text.isEmpty 
              ? null 
              : _ticketDescriptionController.text,
        });
      }
      
      _ticketNameController.clear();
      _ticketPriceController.clear();
      _ticketDescriptionController.clear();
    });
  }
  
  void _editTicketType(int index) {
    final ticket = _ticketTypes[index];
    setState(() {
      _editingTicketIndex = index;
      _ticketNameController.text = ticket['name'];
      _ticketPriceController.text = ticket['price'].toString();
      _ticketDescriptionController.text = ticket['description'] ?? '';
    });
  }
  
  void _cancelEditing() {
    setState(() {
      _editingTicketIndex = null;
      _ticketNameController.clear();
      _ticketPriceController.clear();
      _ticketDescriptionController.clear();
    });
  }
  
  void _removeTicketType(int index) {
    setState(() {
      final ticketType = _ticketTypes[index];
      
      // If this is an existing ticket type, add it to the delete list
      if (ticketType.containsKey('id') && ticketType['id'] != null) {
        _ticketTypesToDelete.add(ticketType['id']);
      }
      
      _ticketTypes.removeAt(index);
    });
  }
  
  void _selectStartDateTime(DateTime dateTime) {
    setState(() {
      _startDateTime = dateTime;
      _startAtController.text = '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    });
  }
  
  void _selectEndDateTime(DateTime dateTime) {
    setState(() {
      _endDateTime = dateTime;
      _endAtController.text = '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
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
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Nazad na pregled događaja'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Uređivanje događaja',
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
                                  
                                  // Start date and time field with datetime picker
                                  ZSDatetimePicker(
                                    label: 'Početak događaja*',
                                    controller: _startAtController,
                                    onDateTimeSelected: _selectStartDateTime,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite početak događaja';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // End date and time field with datetime picker
                                  ZSDatetimePicker(
                                    label: 'Kraj događaja*',
                                    controller: _endAtController,
                                    onDateTimeSelected: _selectEndDateTime,
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
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Ticket types section
                                  const Text(
                                    'Tipovi ulaznica',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
                                            subtitle: Text(
                                              ticketType['description'] ?? 'Bez opisa',
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
                                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                                  onPressed: () => _editTicketType(index),
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
                                  Row(
                                    children: [
                                      ZSButton(
                                        text: _editingTicketIndex != null 
                                            ? 'Spremi promjene' 
                                            : 'Dodaj ulaznicu',
                                        backgroundColor: Colors.blue.shade50,
                                        foregroundColor: Colors.blue,
                                        borderColor: Colors.grey.shade300,
                                        onPressed: _addTicketType,
                                      ),
                                      if (_editingTicketIndex != null) ...[
                                        const SizedBox(width: 10),
                                        ZSButton(
                                          text: 'Odustani',
                                          backgroundColor: Colors.grey.shade100,
                                          foregroundColor: Colors.grey.shade700,
                                          borderColor: Colors.grey.shade300,
                                          onPressed: _cancelEditing,
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  
                                  // Submit buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ZSButton(
                                        text: 'Spremi promjene',
                                        backgroundColor: Colors.green.shade50,
                                        foregroundColor: Colors.green,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: _submitEventUpdate,
                                      ),
                                      
                                      const SizedBox(width: 20),
                                      
                                      ZSButton(
                                        text: 'Odustani',
                                        backgroundColor: Colors.grey.shade100,
                                        foregroundColor: Colors.grey.shade700,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: () {
                                          Navigator.pop(context);
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
  
  void _submitEventUpdate() {
    if (_formKey.currentState!.validate()) {
      // Validate event times
      if (_startDateTime == null || _endDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unesite vrijeme početka i kraja događaja'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_startDateTime!.isAfter(_endDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vrijeme početka ne može biti nakon vremena završetka'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Validate that at least one ticket type is added
      if (_ticketTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dodajte barem jedan tip ulaznice'),
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
      
      // Update the event with ticket types
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
      });
      
      eventProvider.updateEventWithTicketTypes(
        eventId: widget.eventId,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        startAt: _startDateTime!,
        endAt: _endDateTime!,
        organizer: _organizerController.text.isEmpty ? null : _organizerController.text,
        lecturers: _lecturersController.text.isEmpty ? null : _lecturersController.text,
        maxNumberOfPeople: maxPeople,
        ticketTypes: _ticketTypes,
        ticketTypesToDelete: _ticketTypesToDelete,
      ).then((event) {
        setState(() {
          _isLoading = false;
        });
        
        if (event != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(eventProvider.error != null 
                ? 'Događaj je ažuriran, ali: ${eventProvider.error}'
                : 'Događaj je uspješno ažuriran!'),
              backgroundColor: eventProvider.error != null ? Colors.orange : Colors.green,
            ),
          );
          
          // Navigate back with the updated event
          Navigator.pop(context, event);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom ažuriranja događaja: ${eventProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 