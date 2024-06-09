import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'select_weekdays.dart';

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
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  List<DayInWeek> _days = [
    DayInWeek("Lø", isSelected: false),
    DayInWeek("Sø", isSelected: false),
    DayInWeek("Ma", isSelected: false),
    DayInWeek("Ti", isSelected: false),
    DayInWeek("On", isSelected: false),
    DayInWeek("To", isSelected: false),
    DayInWeek("Fr", isSelected: false),
  ];

  void _showIOSDatePicker(BuildContext ctx, bool isStart) {
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
        height: 250,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              height: 200,
              child: CupertinoDatePicker(
                use24hFormat: true,
                initialDateTime: DateTime.now(),
                mode: CupertinoDatePickerMode.time,
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

  Future<void> _showAndroidTimePicker(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() {
        if (isStart) {
          _selectedStartTime = selectedDateTime;
        } else {
          _selectedEndTime = selectedDateTime;
        }
      });
    }
  }

  void _showDatePicker(BuildContext context, bool isStart) {
    if (Platform.isIOS) {
      _showIOSDatePicker(context, isStart);
    } else {
      _showAndroidTimePicker(context, isStart);
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Not selected';
    final DateFormat formatter = DateFormat.Hm();
    return formatter.format(time);
  }

  Future<void> _saveEvent() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final int? maxPeople = int.tryParse(_maxPeopleController.text);
    final String campName = _campNameController.text;
    final String startTime = _selectedStartTime != null ? _selectedStartTime!.toIso8601String() : '';
    final String endTime = _selectedEndTime != null ? _selectedEndTime!.toIso8601String() : '';
    final List<String> selectedDays = _days.where((day) => day.isSelected).map((day) => day.name).toList();

    // Get the current user
    final user = FirebaseAuth.instance.currentUser;
    final String submittedBy = user != null ? user.email ?? 'Unknown' : 'Unknown'; // Use the user's email or 'Unknown' if not available

    if (title.isEmpty || description.isEmpty || campName.isEmpty || _selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (maxPeople == null || maxPeople <= 0 || maxPeople > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum number of people must be between 1 and 1000')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('Events').add({
      'EventTitle': title,
      'EventDescription': description,
      'MaxPeople': maxPeople,
      'StartTime': startTime,
      'EndTime': endTime,
      'Days': selectedDays,
      'CampName': campName,
      'SubmittedBy': submittedBy, // Include the submitted by information
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
      _days.forEach((day) => day.isSelected = false);
    });
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
                        keyboardType: TextInputType.number, // Only numbers as input
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
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ), 
                                style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(222, 121, 46, 1))
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showDatePicker(context, false),
                                child: Text(
                                  'Select End Time',
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(222, 121, 46, 1))
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
                                style: TextStyle(color: const Color.fromARGB(255, 131, 131, 131)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'End time: ${_formatTime(_selectedEndTime)}',
                                style: TextStyle(color: const Color.fromARGB(255, 131, 131, 131)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SelectWeekDays(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        days: _days,
                        border: false,
                        boxDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            colors: [Colors.orange, const Color.fromARGB(255, 204, 127, 12)],
                            tileMode: TileMode.repeated, // repeats the gradient over the canvas
                          ),
                        ),
                        onSelect: (values) {
                          print(values);
                        },
                      ),
                      ElevatedButton(
                        onPressed: _saveEvent,
                        child: Text('Save Event'),
                      ),
                      SizedBox(height: 5), // Add this SizedBox to prevent bottom overflow
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/preview_event');
                  },
                  child: const Text('Preview Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

