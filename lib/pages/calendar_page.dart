import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:eventtide/pages/event_detail_page.dart';

class Event {
  final String id; // Add this field
  final String startTime;
  final String endTime;
  final String title;
  final String description;
  final String campName;
  final int maxPeople;
  final String imageUrl;

  Event(this.id, this.startTime, this.endTime, this.title, this.description,
      this.campName, this.maxPeople, this.imageUrl);
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Appointment> _appointments = [];
  DateTime _startDate = DateTime(2024, 6, 30);
  DateTime _endDate = DateTime(2024, 7, 6);
  CalendarView _calendarView = CalendarView.week;

  Future<List<Event>> fetchEvents() async {
    try {
      List<Event> events = [];
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Events').get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('StartTime') &&
            data.containsKey('EndTime') &&
            data.containsKey('EventTitle') &&
            data.containsKey('EventDescription') &&
            data.containsKey('CampName') &&
            data.containsKey('MaxPeople') &&
            data.containsKey('imageUrl')) {
          DateTime startTime = DateTime.parse(data['StartTime']);
          if (startTime.isAfter(_startDate.subtract(Duration(days: 1))) &&
              startTime.isBefore(_endDate.add(Duration(days: 1)))) {
            events.add(Event(
              doc.id, // Use the document ID as the event ID
              data['StartTime'],
              data['EndTime'],
              data['EventTitle'],
              data['EventDescription'],
              data['CampName'],
              data['MaxPeople'],
              data['imageUrl'],
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
            notes:
                '${event.description}|${event.campName}|${event.maxPeople}|${event.startTime}|${event.endTime}|${event.imageUrl}|${event.id}',
            color: Colors.orange.withOpacity(0.7),
          );
        }).toList();
      });
    });
  }

  void _onAppointmentTap(CalendarTapDetails details) {
    if (details.appointments == null) return;

    final Appointment appointment = details.appointments!.first;
    final List<String> notes =
        appointment.notes?.split('|') ?? ['', '', '', '', '', '', ''];
    final String description = notes[0];
    final String campName = notes[1];
    final int maxPeople = int.tryParse(notes[2]) ?? 1;
    final String startTime = notes[3];
    final String endTime = notes[4];
    final String imageUrl = notes[5];
    final String id = notes[6];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(eventId: id, mode: 'view'),
      ),
    );
  }

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
          'Roskilde Festival',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      backgroundColor: Colors.black,
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
            dataSource: EventDataSource(_appointments),
            backgroundColor: Colors.black,
            todayHighlightColor: Colors.orange,
            showCurrentTimeIndicator: true,
            selectionDecoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.3),
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            timeSlotViewSettings: TimeSlotViewSettings(
              timeInterval: Duration(minutes: 60), // Set larger time interval
              timeFormat: 'HH:mm',
              startHour: 7, // Start at 07:00
              endHour: 24, // End at 23:00
              timeRulerSize: 40, // Smaller time ruler size
              timeIntervalHeight: 28, // Adjusted time interval height to fit more intervals on screen
              timeTextStyle: TextStyle(color: Colors.white),
            ),
            headerHeight: 0, // Remove the header
            viewHeaderHeight: 50,
            viewHeaderStyle: ViewHeaderStyle(
              dayTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              dateTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            cellBorderColor: Color.fromRGBO(222, 121, 46, 0.9), // Set gridlines to white
            minDate: _startDate,
            maxDate: _endDate,
            initialDisplayDate: _startDate,
            initialSelectedDate: _startDate,
            allowedViews: [CalendarView.day, CalendarView.week],
            onTap: _onAppointmentTap,
            monthViewSettings: MonthViewSettings(
              showTrailingAndLeadingDates: false,
              monthCellStyle: MonthCellStyle(
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
