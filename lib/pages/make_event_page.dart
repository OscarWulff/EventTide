import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform, File;
import 'package:intl/intl.dart';
import 'package:eventtide/Services/add_image.dart'; // Import the AddImage component
import 'map_page.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage

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
  File? _selectedImageFile; // Add a variable to hold the selected image file

  @override
  void initState() {
    super.initState();
    if (widget.eventData != null) {
      _eventId = widget.eventData!['id'];
      _titleController.text = widget.eventData!['EventTitle'];
      _descriptionController.text = widget.eventData!['EventDescription'];
      _maxPeopleController.text = widget.eventData!['MaxPeople'].toString();
      _campNameController.text = widget.eventData!['CampName'];
      _selectedStartTime = DateTime.tryParse(widget.eventData!['StartTime']);
      _selectedEndTime = DateTime.tryParse(widget.eventData!['EndTime']);
      imageUrl = widget.eventData!['imageUrl'] ?? '';
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
    if (value.length > 30) {
      return 'Title cannot exceed 30 characters';
    }
    return null;
  }

  String? _validateCampName(String value) {
    if (value.length > 30) {
      return 'Camp name cannot exceed 30 characters';
    }
    return null;
  }

  String? _validateDescription(String value) {
    if (value.length > 200) {
      return 'Description cannot exceed 200 characters';
    }
    return null;
  }

  void _showIOSDatePicker(BuildContext ctx, bool isStart) {
    DateTime now = DateTime.now();
    DateTime initialDateTime = isStart
        ? (now.isBefore(DateTime(2024, 6, 29))
            ? DateTime(2024, 6, 29, 0, 0)
            : (now.isAfter(DateTime(2024, 7, 6))
                ? DateTime(2024, 7, 6, 0, 0)
                : DateTime(now.year, now.month, now.day, now.hour, now.minute)))
        : (_selectedStartTime ?? DateTime(2024, 6, 29, 0, 0));

    DateTime minimumDate = isStart
        ? DateTime(2024, 6, 29, 0, 0)
        : _selectedStartTime ?? DateTime(2024, 6, 29, 0, 0);
    DateTime maximumDate = isStart
        ? DateTime(2024, 7, 6, 23, 59)
        : (_selectedStartTime ?? DateTime(2024, 6, 29, 0, 0))
            .add(Duration(days: 1));

    if (!isStart && _selectedStartTime == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Please select a start time first')),
        );
      });
      return;
    }

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
                initialDateTime: initialDateTime.isBefore(minimumDate)
                    ? minimumDate
                    : initialDateTime,
                mode: CupertinoDatePickerMode.dateAndTime,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                onDateTimeChanged: (val) {
                  try {
                    setState(() {
                      if (isStart) {
                        _selectedStartTime = val;
                        if (_selectedEndTime != null &&
                            _selectedEndTime!.isBefore(val)) {
                          _selectedEndTime = val;
                        }
                      } else {
                        _selectedEndTime = val;
                      }
                    });
                  } catch (e) {
                    print('Error: $e');
                  }
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
    if (!isStart && _selectedStartTime == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a start time first')),
        );
      });
      return;
    }

    try {
      final DateTime now = DateTime.now();
      final DateTime firstDate = DateTime(2024, 6, 29);
      final DateTime lastDate = DateTime(2024, 7, 6);
      DateTime? initialDate = isStart
          ? (now.isBefore(firstDate)
              ? firstDate
              : (now.isAfter(lastDate) ? lastDate : now))
          : (_selectedStartTime ?? firstDate);

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: isStart
            ? lastDate
            : (_selectedStartTime ?? firstDate).add(Duration(days: 1)),
      );

      if (picked != null) {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: 0, minute: 0),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (time != null) {
          final DateTime selectedDateTime = DateTime(
              picked.year, picked.month, picked.day, time.hour, time.minute);
          setState(() {
            if (isStart) {
              print('Selected start time is: $selectedDateTime');
              _selectedStartTime = selectedDateTime;
              if (_selectedEndTime != null &&
                  _selectedEndTime!.isBefore(selectedDateTime)) {
                _selectedEndTime = selectedDateTime;
              }
            } else {
              print('Selected end time is: $selectedDateTime');
              _selectedEndTime = selectedDateTime;
            }
          });
        }
      }
    } catch (e) {
      print('Error: $e');
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

  Future<String> _uploadImage(File imageFile) async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(imageFile);
      String downloadUrl = await referenceImageToUpload.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
      return '';
    }
  }

  Future<int> _getUserEventCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Events')
        .where('SubmittedBy', isEqualTo: user.email)
        .get();

    return querySnapshot.docs.length;
  }

  Future<void> _joinEvent(BuildContext context, String eventId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .collection('Join_Registry')
            .add({
          'email': user.email,
          'eventId': eventId,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully joined the event')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join the event')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is logged in')),
      );
    }
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

    // Check the number of events created by the user
    final eventCount = await _getUserEventCount();
    if (eventCount >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'You can create a maximum of 4 events. Please delete an old event to create a new one.')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Saving..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      if (_selectedImageFile != null) {
        imageUrl = await _uploadImage(_selectedImageFile!);
      }

      Map<String, dynamic> eventData = {
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
      };

      if (imageUrl.isNotEmpty) {
        eventData['imageUrl'] = imageUrl;
      }

      if (_eventId != null) {
        // Update existing event
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(_eventId)
            .update(eventData);
        await _joinEvent(context, _eventId!); // Join the updated event
      } else {
        // Save new event
        DocumentReference newEventRef = await FirebaseFirestore.instance
            .collection('Events')
            .add(eventData);
        await _joinEvent(context, newEventRef.id); // Join the new event
      }
    } catch (e) {
      print('Error saving event: $e');
    }

    // Hide loading dialog
    Navigator.of(context).pop();

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
      _selectedImageFile = null;
    });

    Navigator.pushNamed(context, '/main');
  }

  void _selectLocation() {
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.push(
      // Unfocus the keyboard
      context,
      MaterialPageRoute(
        builder: (context) => ZoomableMapPage(
          onLocationSelected: (Offset location) {
            setState(() {
              _selectedLocation = location;
              _locationController.text = 'X: ${location.dx}, Y: ${location.dy}';
            });
          },
          initialLocation: _selectedLocation ?? Offset(0, 0),
          enableZoom: false, // Disable zoom for the MakeEventPage
          editable: true, // Make the location editable
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.eventData != null
          ? AppBar(
              title: Text('Edit Event'),
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
            )
          : null,
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
                      const SizedBox(height: 20),
                      AddImage(
                        onImageSelected: (File? image) {
                          setState(() {
                            _selectedImageFile = image;
                          });
                        },
                        initialImageUrl:
                            imageUrl, // Pass initial image URL if editing
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
                          counterText: '${_titleController.text.length}/30',
                        ),
                        textAlign: TextAlign.center,
                        maxLength: 30,
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
                          counterText: '${_campNameController.text.length}/30',
                        ),
                        textAlign: TextAlign.center,
                        maxLength: 30,
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
                              '${_descriptionController.text.length}/200',
                        ),
                        textAlign: TextAlign.center,
                        maxLength: 200,
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
