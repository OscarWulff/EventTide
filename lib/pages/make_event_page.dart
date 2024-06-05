import 'package:flutter/material.dart';
import 'select_weekdays.dart';

class MakeEventPage extends StatefulWidget {
  const MakeEventPage({Key? key}) : super(key: key);

  @override
  _MakeEventPageState createState() => _MakeEventPageState();
}

class _MakeEventPageState extends State<MakeEventPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(222, 121, 46, 1),
        title: const Text('Make Event'),
      ),
      body: Center(
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
                    style: TextStyle(color: Colors.white),
                  ),
                  TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Describe your event',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Maximum number of people',
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
    );
  }
}
