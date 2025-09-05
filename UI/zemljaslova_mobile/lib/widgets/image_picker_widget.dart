import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final Uint8List? initialImage;
  final Function(Uint8List?)? onImageSelected;
  final String? label;
  final double width;
  final double height;
  final bool isRequired;

  const ImagePickerWidget({
    Key? key,
    this.initialImage,
    this.onImageSelected,
    this.label,
    this.width = 200,
    this.height = 250,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  Uint8List? _currentImage;
  String? _errorMessage;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentImage = widget.initialImage;
  }

  @override
  void didUpdateWidget(ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImage != oldWidget.initialImage) {
      setState(() {
        _currentImage = widget.initialImage;
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Show image source selection dialog
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        
        // Validate image
        final validationError = _validateImage(imageBytes, image.name);
        if (validationError != null) {
          setState(() {
            _errorMessage = validationError;
            _isProcessing = false;
          });
          return;
        }

        setState(() {
          _currentImage = imageBytes;
          _errorMessage = null;
        });

        widget.onImageSelected?.call(imageBytes);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Greška prilikom odabira slike: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Odaberite izvor slike'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerija'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateImage(Uint8List imageBytes, String fileName) {
    // Check file size (5MB limit)
    if (imageBytes.length > 5 * 1024 * 1024) {
      return 'Slika je prevelika. Maksimalna veličina je 5MB.';
    }

    // Check file extension
    final extension = fileName.toLowerCase().split('.').last;
    const supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
    if (!supportedFormats.contains(extension)) {
      return 'Nepodržan format slike. Podržani formati: ${supportedFormats.join(', ')}';
    }

    // Check if it starts with image file signature
    if (imageBytes.length < 8) {
      return 'Fajl nije validna slika.';
    }

    final header = imageBytes.take(8).toList();
    bool isValidImage = false;

    // JPEG
    if (header.length >= 2 && header[0] == 0xFF && header[1] == 0xD8) {
      isValidImage = true;
    }
    // PNG
    else if (header.length >= 8 && 
             header[0] == 0x89 && header[1] == 0x50 && 
             header[2] == 0x4E && header[3] == 0x47 &&
             header[4] == 0x0D && header[5] == 0x0A &&
             header[6] == 0x1A && header[7] == 0x0A) {
      isValidImage = true;
    }
    // WebP
    else if (header.length >= 4 && 
             header[0] == 0x52 && header[1] == 0x49 &&
             header[2] == 0x46 && header[3] == 0x46) {
      isValidImage = true;
    }

    if (!isValidImage) {
      return 'Fajl nije validna slika.';
    }

    return null; // Valid image
  }

  void _removeImage() {
    setState(() {
      _currentImage = null;
      _errorMessage = null;
    });
    widget.onImageSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: _errorMessage != null ? Colors.red : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _currentImage != null
                ? Stack(
                    children: [
                      Image.memory(
                        _currentImage!,
                        width: widget.width,
                        height: widget.height,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _removeImage,
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildPlaceholder(),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Action buttons
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickImage,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate),
              label: Text(_currentImage != null ? 'Promijeni sliku' : 'Odaberi sliku'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            if (_currentImage != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete),
                label: const Text('Ukloni'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ],
        ),
        
        if (_errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Odaberite sliku',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
