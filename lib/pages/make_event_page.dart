import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:eventtide/add_image.dart'; // Import the AddImage component
import 'map_page.dart';

class MakeEventPage extends StatefulWidget {
  const MakeEventPage({Key? key}) : super(key: key);

  @override
  _MakeEventPageState createState() => _MakeEventPageState();
}

class _MakeEventPageState extends State<MakeEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxPeopleController = TextEditingController();
  final TextEditingController _campNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  String imageUrl = '';
  Offset? _selectedLocation;

  void _showIOSDatePicker(BuildContext ctx, bool isStart) {
    DateTime initialDateTime = DateTime.now().isBefore(DateTime(2024, 6, 30))
        ? DateTime(2024, 6, 30)
        : DateTime.now().isAfter(DateTime(2024, 7, 6))
            ? DateTime(2024, 7, 6)
            : DateTime.now();

    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
        height: 250,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Expanded(
              child: CupertinoDatePicker(
                use24hFormat: true,
                initialDateTime: initialDateTime,
                mode: CupertinoDatePickerMode.dateAndTime,
                minimumDate: DateTime(2024, 6, 30),
                maximumDate: DateTime(2024, 7, 6),
                onDateTimeChanged: (val) {
                  setState(() {
                    if (isStart) {
                      _selectedStartTime = val;
                    } else {
                      _selectedEndTime = val;
                    }
                  });
                },
              ),
            ),
            CupertinoButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAndroidDatePicker(
      BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(2024, 6, 30);
    final DateTime lastDate = DateTime(2024, 7, 6);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.isBefore(firstDate)
          ? firstDate
          : (now.isAfter(lastDate) ? lastDate : now),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (time != null) {
        final DateTime selectedDateTime = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
        setState(() {
          if (isStart) {
            _selectedStartTime = selectedDateTime;
          } else {
            _selectedEndTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _showDatePicker(BuildContext context, bool isStart) {
    if (Platform.isIOS) {
      _showIOSDatePicker(context, isStart);
    } else {
      _showAndroidDatePicker(context, isStart);
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not selected';
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  Future<void> _saveEvent() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final int? maxPeople = int.tryParse(_maxPeopleController.text);
    final String campName = _campNameController.text;
    final String startTime =
        _selectedStartTime != null ? _selectedStartTime!.toIso8601String() : '';
    final String endTime =
        _selectedEndTime != null ? _selectedEndTime!.toIso8601String() : '';

    // Get the current user
    final user = FirebaseAuth.instance.currentUser;
    final String submittedBy = user != null
        ? user.email ?? 'Unknown'
        : 'Unknown'; // Use the user's email or 'Unknown' if not available

    if (title.isEmpty ||
        description.isEmpty ||
        campName.isEmpty ||
        _selectedStartTime == null ||
        _selectedEndTime == null ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (maxPeople == null || maxPeople <= 0 || maxPeople > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Maximum number of people must be between 1 and 1000')),
      );
      return;
    }

    // Save the event details to Firestore
    await FirebaseFirestore.instance.collection('Events').add({
      'EventTitle': title,
      'EventDescription': description,
      'MaxPeople': maxPeople,
      'StartTime': startTime,
      'EndTime': endTime,
      'CampName': campName,
      'Location': {
        'dx': _selectedLocation!.dx,
        'dy': _selectedLocation!.dy,
      }, // Include the location
      'SubmittedBy': submittedBy, // Include the submitted by information
      'imageUrl': imageUrl, // Include the image URL
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event created successfully')),
    );

    _titleController.clear();
    _descriptionController.clear();
    _maxPeopleController.clear();
    _campNameController.clear();
    setState(() {
      _selectedStartTime = null;
      _selectedEndTime = null;
      _selectedLocation = null; // Reset the location
      imageUrl = ''; // Reset the image URL
    });
  }

  void _selectLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoomableMapPage(
          onLocationSelected: (Offset location) {
            setState(() {
              _selectedLocation = location;
              _locationController.text = 'X: ${location.dx}, Y: ${location.dy}';
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AddImage(
                        onImageUploaded: (url) {
                          setState(() {
                            imageUrl = url;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _titleController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Title of event',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _campNameController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Camp Name',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _descriptionController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Describe your event',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _maxPeopleController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Maximum number of people',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType:
                            TextInputType.number, // Only numbers as input
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _locationController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Location (Tap map to select)',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.map),
                            onPressed: _selectLocation,
                          ),
                        ),
                        readOnly: true, // Make the field read-only
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showDatePicker(context, true),
                                child: Text(
                                  'Select Start Time',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(222, 121, 46, 1)),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _showDatePicker(context, false),
                                child: Text(
                                  'Select End Time',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(222, 121, 46, 1)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: Text(
                                'Start time: ${_formatDateTime(_selectedStartTime)}',
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'End time: ${_formatDateTime(_selectedEndTime)}',
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _saveEvent,
                        child: Text('Save Event',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(222, 121, 46, 1)),
                      ),
                      SizedBox(
                          height:
                              5), // Add this SizedBox to prevent bottom overflow
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/preview_event');
                  },
                  child: const Text('Preview Event',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(222, 121, 46, 1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
