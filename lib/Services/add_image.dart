import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  final Function(File?) onImageSelected;
  final String? initialImageUrl;

  const AddImage(
      {Key? key, required this.onImageSelected, this.initialImageUrl})
      : super(key: key);

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File? _selectedImage;
  String? _displayImageUrl;
  bool _isFromCamera = false;
  bool _isImageSelected = false;

  @override
  void initState() {
    super.initState();
    _displayImageUrl = widget.initialImageUrl;
    _isImageSelected = _displayImageUrl != null && _displayImageUrl!.isNotEmpty;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  _pickImageFromSource(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  _pickImageFromSource(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    try {
      XFile? file = await imagePicker.pickImage(source: source);
      if (file == null) {
        // User canceled the picker
        return;
      }

      setState(() {
        _selectedImage = File(file.path);
        _displayImageUrl =
            null; // Clear the display URL since a new image is selected
        _isFromCamera = source == ImageSource.camera;
        _isImageSelected =
            true; // Update the flag to indicate an image is selected
      });

      widget.onImageSelected(_selectedImage);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null)
          Transform(
            alignment: Alignment.center,
            transform:
                _isFromCamera ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
            child: Image.file(
              _selectedImage!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          )
        else if (_displayImageUrl != null && _displayImageUrl!.isNotEmpty)
          Image.network(
            _displayImageUrl!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          )
        else
          Image.asset(
            'assets/NoPhoto_new.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text(
            _isImageSelected ? 'Change Image' : 'Select Image',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(222, 121, 46, 1),
          ),
        ),
      ],
    );
  }
}
