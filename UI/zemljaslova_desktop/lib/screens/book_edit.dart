import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../providers/book_provider.dart';
import '../providers/author_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_date_picker.dart';
import '../widgets/image_picker_widget.dart';
import '../utils/image_utils.dart';

class BookEditScreen extends StatefulWidget {
  final Book book;
  
  const BookEditScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends State<BookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _dateOfPublishController;
  late TextEditingController _editionController;
  late TextEditingController _publisherController;
  late TextEditingController _bookPurposeController;
  late TextEditingController _numberOfPagesController;
  late TextEditingController _weightController;
  late TextEditingController _dimensionsController;
  late TextEditingController _genreController;
  late TextEditingController _bindingController;
  late TextEditingController _languageController;
  
  // Replace single author ID with a list of selected author IDs
  final List<int> _selectedAuthorIds = [];
  bool _isLoading = true;
  List<Author> _authors = [];
  Uint8List? _selectedImage;
  Uint8List? _initialImage;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with book data
    _titleController = TextEditingController(text: widget.book.title);
    _descriptionController = TextEditingController(text: widget.book.description);
    _priceController = TextEditingController(text: widget.book.price.toString());
    _dateOfPublishController = TextEditingController(text: widget.book.dateOfPublish);
    _editionController = TextEditingController(text: widget.book.edition?.toString() ?? '');
    _publisherController = TextEditingController(text: widget.book.publisher);
    _bookPurposeController = TextEditingController(text: widget.book.bookPurpose == BookPurpose.sell ? 'sell' : 'rent');
    _numberOfPagesController = TextEditingController(text: widget.book.numberOfPages.toString());
    _weightController = TextEditingController(text: widget.book.weight?.toString() ?? '');
    _dimensionsController = TextEditingController(text: widget.book.dimensions);
    _genreController = TextEditingController(text: widget.book.genre);
    _bindingController = TextEditingController(text: widget.book.binding);
    _languageController = TextEditingController(text: widget.book.language);
    
    if (widget.book.authorIds.isNotEmpty) {
      _selectedAuthorIds.addAll(widget.book.authorIds);
    }
    
    // Initialize image if available
    if (widget.book.coverImageUrl != null) {
      _initialImage = ImageUtils.base64ToImage(widget.book.coverImageUrl!);
      _selectedImage = _initialImage;
    }
    
    // Load authors for dropdown after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAuthors();
    });
  }
  
  Future<void> _loadAuthors() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      await authorProvider.fetchAuthors(refresh: true);
      
      setState(() {
        _authors = authorProvider.authors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _dateOfPublishController.dispose();
    _editionController.dispose();
    _publisherController.dispose();
    _bookPurposeController.dispose();
    _numberOfPagesController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _genreController.dispose();
    _bindingController.dispose();
    _languageController.dispose();
    super.dispose();
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
                    label: const Text('Nazad na pregled knjige'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  Text(
                    'Uređivanje knjige: ${widget.book.title}',
                    style: const TextStyle(
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
                                  // Title field
                                  ZSInput(
                                    label: 'Naslov*',
                                    controller: _titleController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite naslov knjige';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Description field
                                  ZSInput(
                                    label: 'Opis',
                                    controller: _descriptionController,
                                    maxLines: 3,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Image picker
                                  ImagePickerWidget(
                                    label: 'Slika knjige',
                                    initialImage: _initialImage,
                                    onImageSelected: (imageBytes) {
                                      setState(() {
                                        _selectedImage = imageBytes;
                                      });
                                    },
                                    width: 200,
                                    height: 250,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Price field - only show for books for sale
                                  if (widget.book.bookPurpose != BookPurpose.rent)
                                    ZSInput(
                                      label: 'Cijena*',
                                      controller: _priceController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Unesite cijenu knjige';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Cijena mora biti broj';
                                        }
                                        return null;
                                      },
                                    ),
                                  
                                  if (widget.book.bookPurpose != BookPurpose.rent)
                                    const SizedBox(height: 20),
                                  
                                  // Date of publish field with datepicker
                                  ZSDatePicker(
                                    label: 'Datum izdavanja',
                                    controller: _dateOfPublishController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Edition field
                                  ZSInput(
                                    label: 'Izdanje',
                                    controller: _editionController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Publisher field
                                  ZSInput(
                                    label: 'Izdavač',
                                    controller: _publisherController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Book purpose field
                                  ZSInput(
                                    label: 'Namjena knjige*',
                                    controller: _bookPurposeController,
                                    enabled: false,
                                    validator: null,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Number of pages field
                                  ZSInput(
                                    label: 'Broj stranica*',
                                    controller: _numberOfPagesController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite broj stranica';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Broj stranica mora biti cijeli broj';
                                      }
                                      final pages = int.parse(value);
                                      if (pages < 0) {
                                        return 'Broj stranica ne može biti negativan';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Weight field
                                  ZSInput(
                                    label: 'Težina (g)',
                                    controller: _weightController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Dimensions field
                                  ZSInput(
                                    label: 'Dimenzije',
                                    controller: _dimensionsController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Genre field
                                  ZSInput(
                                    label: 'Žanr',
                                    controller: _genreController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Binding field
                                  ZSInput(
                                    label: 'Tip korica',
                                    controller: _bindingController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Language field
                                  ZSInput(
                                    label: 'Jezik',
                                    controller: _languageController,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Authors selection
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Autori',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 600,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: _selectedAuthorIds.map((authorId) {
                                                final author = _authors.firstWhere(
                                                  (a) => a.id == authorId,
                                                  orElse: () => Author(id: 0, firstName: 'Autor', lastName: 'nepoznat'),
                                                );
                                                return Chip(
                                                  label: Text(author.fullName),
                                                  deleteIcon: const Icon(Icons.close, size: 16),
                                                  onDeleted: () {
                                                    setState(() {
                                                      _selectedAuthorIds.remove(authorId);
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 16),
                                            DropdownButton<int>(
                                              hint: const Text('Dodaj autora'),
                                              isExpanded: true,
                                              items: _authors
                                                  .where((author) => !_selectedAuthorIds.contains(author.id))
                                                  .map((author) => DropdownMenuItem(
                                                        value: author.id,
                                                        child: Text(author.fullName),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    _selectedAuthorIds.add(value);
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Submit button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ZSButton(
                                        text: 'Spremi promjene',
                                        backgroundColor: Colors.green.shade50,
                                        foregroundColor: Colors.green,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: _updateBook,
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
                                  
                                  const SizedBox(height: 20),
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
  
  void _updateBook() {
    if (_formKey.currentState!.validate()) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      
      double? price = widget.book.bookPurpose == BookPurpose.rent 
          ? null 
          : double.parse(_priceController.text);
      
      bookProvider.updateBook(
        widget.book.id,
        _titleController.text,
        _descriptionController.text.isEmpty ? null : _descriptionController.text,
        price,
        _dateOfPublishController.text.isEmpty ? null : _dateOfPublishController.text,
        _editionController.text.isEmpty ? null : int.parse(_editionController.text),
        _publisherController.text.isEmpty ? null : _publisherController.text,
        _bookPurposeController.text == 'sell' ? BookPurpose.sell : BookPurpose.rent,
        int.parse(_numberOfPagesController.text),
        _weightController.text.isEmpty ? null : double.parse(_weightController.text),
        _dimensionsController.text.isEmpty ? null : _dimensionsController.text,
        _genreController.text.isEmpty ? null : _genreController.text,
        _bindingController.text.isEmpty ? null : _bindingController.text,
        _languageController.text.isEmpty ? null : _languageController.text,
        _selectedAuthorIds,
        imageBytes: _selectedImage,
      ).then((success) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Knjiga uspješno ažurirana!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Get the updated book and return to the previous screen
          bookProvider.getBookById(widget.book.id).then((updatedBook) {
            // Navigate back with the updated book
            Navigator.pop(context, updatedBook);
          });
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom ažuriranja knjige: ${bookProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 