import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  final Function(File?) onImageSelected;

  const AddImage({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    try {
      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        // User canceled the picker
        return;
      }

      setState(() {
        _selectedImage = File(file.path);
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
          Image.file(
            _selectedImage!,
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
            _selectedImage != null ? 'Change Image' : 'Select Image',
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
