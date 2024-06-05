import 'package:flutter/material.dart';

class Event {
  final String day;
  final String time;
  final String description;

  Event(this.day, this.time, this.description);
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String? selectedDay;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> days = [
      {'date': '29', 'day': 'Lø'},
      {'date': '30', 'day': 'Sø'},
      {'date': '1', 'day': 'Ma'},
      {'date': '2', 'day': 'Ti'},
      {'date': '3', 'day': 'On'},
      {'date': '4', 'day': 'To'},
      {'date': '5', 'day': 'Fr'},
    ];

    final List<String> times = [
      '08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00', '22:00', '24:00'
    ];

    final List<Event> events = [
      Event('29', '10:00', 'Event 1 on 29 Lø'),
      Event('29', '14:00', 'Event 2 on 29 Lø'),
      Event('29', '16:00', 'Event 3 on 29 Lø'),
      Event('30', '10:00', 'Event 1 on 30 Sø'),
      Event('30', '14:00', 'Event 2 on 30 Sø'),
      Event('1', '10:00', 'Event 1 on 1 Ma'),
      Event('1', '14:00', 'Event 2 on 1 Ma'),
      Event('2', '10:00', 'Event 1 on 2 Ti'),
      Event('2', '14:00', 'Event 2 on 2 Ti'),
    ];

    List<Event> getEventsForSelectedDay(String? day) {
      return events.where((event) => event.day == day).toList();
    }

    return Scaffold(
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
          Column(
            children: [
              const SizedBox(height: 200), // Adjust the height to position the calendar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: days.map((day) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedDay = day['date'];
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedDay == day['date'] ? Colors.orange.withOpacity(0.3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            day['date']!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: selectedDay == day['date'] ? Colors.orange : Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          day['day']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 137, 135, 135),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30), // Add some space between the calendar and the text
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  'Events i dag',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold, // Make the text bold
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add some space between "Events i dag" and the times
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(38, 0, 16.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: times.map((time) {
                    final eventsForSelectedDay = getEventsForSelectedDay(selectedDay);
                    final eventAtTime = eventsForSelectedDay.firstWhere((event) => event.time == time, orElse: () => Event('', '', ''));

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 137, 135, 135),
                            ),
                          ),
                          const SizedBox(width: 10), // Adjust the spacing between the time and event box
                          Container(
                            width: 80,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: eventAtTime.description.isNotEmpty ? Colors.orange.withOpacity(0.3) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              eventAtTime.description,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CalendarPage(),
  ));
}
