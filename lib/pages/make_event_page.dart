import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _durationController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<DayInWeek> _days = [
    DayInWeek("Sun", isSelected: false),
    DayInWeek("Mon", isSelected: false),
    DayInWeek("Tue", isSelected: false),
    DayInWeek("Wed", isSelected: false),
    DayInWeek("Thu", isSelected: false),
    DayInWeek("Fri", isSelected: false),
    DayInWeek("Sat", isSelected: false),
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final int? maxPeople = int.tryParse(_maxPeopleController.text);
    final String campName = _campNameController.text;
    final int? duration = int.tryParse(_durationController.text);
    final String startTime = _selectedTime.format(context);
    final List<String> selectedDays = _days.where((day) => day.isSelected).map((day) => day.name).toList();

    if (title.isEmpty || description.isEmpty || maxPeople == null || campName.isEmpty || duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('Events').add({
      'EventTitle': title,
      'EventDescription': description,
      'MaxPeople': maxPeople,
      'StartTime': startTime,
      'Days': selectedDays,
      'CampName': campName,
      'Duration': duration,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event created successfully')),
    );

    _titleController.clear();
    _descriptionController.clear();
    _maxPeopleController.clear();
    _campNameController.clear();
    _durationController.clear();
    setState(() {
      _selectedTime = TimeOfDay.now();
      _days.forEach((day) => day.isSelected = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(222, 121, 46, 1),
        title: const Text('Make Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Upload image to describe your event or camp',
                      style: TextStyle(color: Colors.black),
                    ),
                    Image.asset('assets/Roskilde_logo.png'), // Your image
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Title of event',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text('Select Time'),
                    ),
                    Text(
                      'Selected Time: ${_selectedTime.format(context)}',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextField(
                      controller: _descriptionController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Describe your event',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: _maxPeopleController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Maximum number of people',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      keyboardType: TextInputType.number, // Only numbers as input
                    ),
                    TextField(
                      controller: _campNameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Camp Name',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: _durationController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Duration in hours',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      keyboardType: TextInputType.number, // Only numbers as input
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MakeEventPage(),
  ));
}
