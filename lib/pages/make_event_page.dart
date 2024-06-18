import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:eventtide/Services/add_image.dart'; // Import the AddImage component
import 'map_page.dart';
import 'event_detail_page.dart'; // Import EventDetailPage

class MakeEventPage extends StatefulWidget {
  final Map<String, dynamic>? eventData; // Optional event data for editing mode

  const MakeEventPage({Key? key, this.eventData}) : super(key: key);

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
  String? _eventId;

  @override
  void initState() {
    super.initState();
    if (widget.eventData != null) {
      _eventId = widget.eventData!['id'];
      _titleController.text = widget.eventData!['EventTitle'];
      _descriptionController.text = widget.eventData!['EventDescription'];
      _maxPeopleController.text = widget.eventData!['MaxPeople'].toString();
      _campNameController.text = widget.eventData!['CampName'];
      _selectedStartTime = DateTime.parse(widget.eventData!['StartTime']);
      _selectedEndTime = DateTime.parse(widget.eventData!['EndTime']);
      imageUrl = widget.eventData!['imageUrl'];
      if (widget.eventData!['Location'] != null) {
        _selectedLocation = Offset(
          widget.eventData!['Location']['dx'],
          widget.eventData!['Location']['dy'],
        );
        _locationController.text =
            'X: ${_selectedLocation!.dx}, Y: ${_selectedLocation!.dy}';
      }
    }
  }

  String? _validateTitle(String value) {
    if (value.length > 50) {
      return 'Title cannot exceed 50 characters';
    }
    return null;
  }

  String? _validateCampName(String value) {
    if (value.length > 50) {
      return 'Camp name cannot exceed 50 characters';
    }
    return null;
  }

  String? _validateDescription(String value) {
    if (value.length > 300) {
      return 'Description cannot exceed 300 characters';
    }
    return null;
  }

  void _showIOSDatePicker(BuildContext ctx, bool isStart) {
    DateTime now = DateTime.now();
    DateTime initialDateTime = now.isBefore(DateTime(2024, 6, 30))
        ? DateTime(2024, 6, 30, 7, 0)
        : now.isAfter(DateTime(2024, 7, 6))
            ? DateTime(2024, 7, 6, 7, 0)
            : DateTime(now.year, now.month, now.day, now.hour, 0);

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
                minimumDate: DateTime(2024, 6, 30, 7, 0),
                maximumDate: DateTime(2024, 7, 6, 23, 59),
                onDateTimeChanged: (val) {
                  if (val.hour < 7) {
                    val = DateTime(val.year, val.month, val.day, 7, val.minute);
                  } else if (val.hour >= 24) {
                    val = DateTime(val.year, val.month, val.day, 23, 59);
                  }
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
        initialTime: TimeOfDay(hour: 7, minute: 0),
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
        if (time.hour < 7 || time.hour >= 24) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Please select a time between 07:00 and 24:00')),
          );
        } else {
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
  }

  void _showDatePicker(BuildContext context, bool isStart) {
    if (Platform.isIOS) {
      _showIOSDatePicker(context, isStart);
    } else {
      _showAndroidDatePicker(context, isStart);
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not selected';
    final DateFormat formatter = DateFormat('E MMM d, HH:mm');
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

    if (_selectedStartTime!.day != _selectedEndTime!.day) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please keep events within the same day')),
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

    if (_eventId != null) {
      // Update existing event
      await FirebaseFirestore.instance
          .collection('Events')
          .doc(_eventId)
          .update({
        'EventTitle': title,
        'EventDescription': description,
        'MaxPeople': maxPeople,
        'StartTime': startTime,
        'EndTime': endTime,
        'CampName': campName,
        'Location': {
          'dx': _selectedLocation!.dx,
          'dy': _selectedLocation!.dy,
        },
        'SubmittedBy': submittedBy,
        'imageUrl': imageUrl,
      });
    } else {
      // Save new event
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
        },
        'SubmittedBy': submittedBy,
        'imageUrl': imageUrl,
        'Published_TF': false
      });
    }

    _titleController.clear();
    _descriptionController.clear();
    _maxPeopleController.clear();
    _campNameController.clear();
    _locationController.clear();
    setState(() {
      _selectedStartTime = null;
      _selectedEndTime = null;
      _selectedLocation = null;
      imageUrl = '';
    });

    // Navigate to the EventDetailPage in Publishing mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EventDetailPage(eventId: _eventId ?? '', mode: 'Publishing'),
      ),
    );
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
                      SizedBox(height: 10), // Reduce spacing
                      TextField(
                        controller: _titleController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Title of Event',
                          hintStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(222, 121, 46, 1)),
                          ),
                          errorText: _validateTitle(_titleController.text),
                          counterText: '${_titleController.text.length}/50',
                        ),
                        textAlign: TextAlign.center,
                        maxLength: 50,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 10), // Reduce spacing
                      TextField(
                        controller: _campNameController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Camp Name',
                          hintStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(222, 121, 46, 1)),
                          ),
                          errorText:
                              _validateCampName(_campNameController.text),
                          counterText: '${_campNameController.text.length}/50',
                        ),
                        textAlign: TextAlign.center,
                        maxLength: 50,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 10), // Reduce spacing
                      TextField(
                        controller: _descriptionController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Describe your event',
                          hintStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(222, 121, 46, 1)),
                          ),
                          errorText:
                              _validateDescription(_descriptionController.text),
                          counterText:
                              '${_descriptionController.text.length}/300',
                        ),
                        textAlign: TextAlign.center,
                        maxLength: 300,
                        maxLines: 3, // Allow up to 3 lines of text
                        minLines: 1,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 10), // Reduce spacing
                      TextField(
                        controller: _maxPeopleController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Maximum number of people',
                          hintStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(222, 121, 46, 1)),
                          ),
                        ),
                        keyboardType:
                            TextInputType.number, // Only numbers as input
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10), // Reduce spacing
                      TextField(
                        controller: _locationController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Location (Tap map to select)',
                          hintStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(222, 121, 46, 1)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.map, color: Colors.black),
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
                                'Start time: ${_formatTime(_selectedStartTime)}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'End time: ${_formatTime(_selectedEndTime)}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150, // Set the desired width
                            child: ElevatedButton(
                              onPressed: _saveEvent,
                              child: Text('Save Event',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(222, 121, 46, 1)),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
