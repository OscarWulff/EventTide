// add_image.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddImage extends StatefulWidget {
  final Function(String) onImageUploaded;

  const AddImage({Key? key, required this.onImageUploaded}) : super(key: key);

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  String imageUrl = '';
  File? _selectedImage;

  Future<void> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(_selectedImage!);
      String downloadUrl = await referenceImageToUpload.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
      widget.onImageUploaded(downloadUrl);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
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
          ) else
            Image.asset(
              'assets/NoPhoto_new.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Select Image', style: TextStyle(fontSize: 12, color: Colors.black)),
          style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(222, 121, 46, 1)),
        ),
      ],
    );
  }
}
