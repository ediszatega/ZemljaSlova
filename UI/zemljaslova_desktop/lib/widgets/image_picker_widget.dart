import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/image_utils.dart';

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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ImageUtils.supportedFormats,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final PlatformFile file = result.files.first;
        final Uint8List fileBytes = file.bytes!;
        
        // Validate the image
        final validationError = ImageUtils.validateImage(fileBytes, file.name);
        if (validationError != null) {
          setState(() {
            _errorMessage = validationError;
          });
          return;
        }

        // Process the image
        final processedImage = ImageUtils.processImage(fileBytes);
        if (processedImage == null) {
          setState(() {
            _errorMessage = 'Greška prilikom procesiranja slike.';
          });
          return;
        }

        setState(() {
          _currentImage = processedImage;
        });

        // Notify parent widget
        if (widget.onImageSelected != null) {
          widget.onImageSelected!(_currentImage);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Greška prilikom izbora slike.';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _currentImage = null;
      _errorMessage = null;
    });

    // Notify parent widget
    if (widget.onImageSelected != null) {
      widget.onImageSelected!(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: _errorMessage != null 
                  ? Colors.red 
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isProcessing
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _currentImage != null
                  ? _buildImagePreview()
                  : _buildImagePlaceholder(),
        ),
        
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_currentImage != null ? 'Promijeni sliku' : 'Dodaj sliku'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            
            if (_currentImage != null) ...[
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _isProcessing ? null : _removeImage,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Ukloni',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 8),
        Text(
          'Podržani formati: ${ImageUtils.supportedFormats.join(', ').toUpperCase()}\n'
          'Maksimalna veličina: 5MB\n',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Image.memory(
              _currentImage!,
              fit: BoxFit.cover,
            ),
          ),
          
          // Overlay with zoom icon
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => _showImagePreview(context),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return InkWell(
      onTap: _isProcessing ? null : _pickImage,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
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
              'Kliknite da dodate sliku',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context) {
    if (_currentImage == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.memory(_currentImage!),
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
