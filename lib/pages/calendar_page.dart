import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import for Firebase Auth
import 'package:eventtide/pages/event_detail_page.dart';

/////////// BACK_END ////////////
class Event {
  final String id;
  final String startTime;
  final String endTime;
  final String title;
  final String description;
  final String campName;
  

  Event(this.id, this.startTime, this.endTime, this.title, this.description,
      this.campName); 
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class _CalendarPageState extends State<CalendarPage> {
  List<Appointment> _appointments = [];
  DateTime _startDate = DateTime(2024, 6, 29);
  DateTime _endDate = DateTime(2024, 7, 6);
  CalendarView _calendarView = CalendarView.day;

  Future<List<Event>> fetchEvents() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Fetch joined events
      QuerySnapshot joinSnapshot = await FirebaseFirestore.instance
          .collectionGroup('Join_Registry')
          .where('email', isEqualTo: user.email)
          .get();

      List<String> joinedEventIds = joinSnapshot.docs.map((doc) => doc['eventId'] as String).toList();

      if (joinedEventIds.isEmpty) {
        return [];
      }

      // Fetch event details for joined events
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where(FieldPath.documentId, whereIn: joinedEventIds)
          .get();

      List<Event> events = [];
      for (var doc in eventSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('StartTime') &&
            data.containsKey('EndTime') &&
            data.containsKey('EventTitle') &&
            data.containsKey('EventDescription') &&
            data.containsKey('CampName')) {
          DateTime startTime = DateTime.parse(data['StartTime']);
          if (startTime.isAfter(_startDate.subtract(const Duration(days: 1))) &&
              startTime.isBefore(_endDate.add(const Duration(days: 1)))) {
            events.add(Event(
              doc.id, // Use the document ID as the event ID
              data['StartTime'],
              data['EndTime'],
              data['EventTitle'],
              data['EventDescription'],
              data['CampName'],
            ));
          }
        }
      }
      return events;
    } catch (e) {
      print('Error fetching events: $e');
      throw e; // Re-throw the error after logging it
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents().then((events) {
      setState(() {
        _appointments = events.map((event) {
          return Appointment(
            startTime: DateTime.parse(event.startTime),
            endTime: DateTime.parse(event.endTime),
            subject: event.title,
            notes: event.id, //For Navigation 
            color: const Color.fromRGBO(222, 121, 46, 1),
          );
        }).toList();
      });
    });
  }

  void _onAppointmentTap(CalendarTapDetails details) {
    if (details.appointments == null || details.appointments!.isEmpty) return;

    final Appointment appointment = details.appointments!.first;
    final String id = appointment.notes ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(eventId: id, mode: 'view'),
      ),
    );
  }


/////////// FRONT_END ////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(222, 121, 46, 1),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black, // Background color for the icon
            child: IconButton(
              icon: const Icon(Icons.person),
              color: Colors.white, // Icon color
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0.0, -1.2), // Move the image upwards by 20% of the screen height
            child: Opacity(
              opacity: 0.2, // Adjust the opacity value as needed
              child: Image.asset(
                'assets/Roskilde_logo.png',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 2,
                height: MediaQuery.of(context).size.height * 0.5,
              ),
            ),
          ),
          SfCalendar(
            view: _calendarView,
            firstDayOfWeek: 1,
            dataSource: EventDataSource(_appointments),
            backgroundColor: Colors.white,
            todayHighlightColor: Color.fromRGBO(222, 121, 46, 1),
            showCurrentTimeIndicator: true,
            selectionDecoration: BoxDecoration(
              color: Color.fromRGBO(222, 121, 46, 1),
              border: Border.all(color: Color.fromRGBO(222, 121, 46, 1), width: 10),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            timeSlotViewSettings: TimeSlotViewSettings(
              timeInterval: Duration(minutes: 120), // Set larger time interval
              timeFormat: 'HH:mm',
              startHour: 00, // Start at 07:00
              endHour: 24, // End at 23:00
              timeRulerSize: 50, // Smaller time ruler size
              timeIntervalHeight: 49, // Adjusted time interval height to fit more intervals on screen
              timeTextStyle: TextStyle(color: Colors.black),
            ),
            headerHeight: 0, // Remove the header
            viewHeaderHeight: 50,
            viewHeaderStyle: ViewHeaderStyle(
              dayTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              dateTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            cellBorderColor: Color.fromRGBO(222, 121, 46, 0.9), // Set gridlines to orange
            minDate: _startDate,
            maxDate: _endDate,
            initialDisplayDate: _startDate,
            initialSelectedDate: _startDate,
            allowedViews: [CalendarView.day],
            onTap: _onAppointmentTap,
            monthViewSettings: MonthViewSettings(
              showTrailingAndLeadingDates: false,
              monthCellStyle: MonthCellStyle(
                textStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


