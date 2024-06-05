import 'package:flutter/material.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2, // Adjust the opacity value as needed
            child: Image.asset(
              'assets/Roskilde_logo.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 2,
              height: MediaQuery.of(context).size.height * 0.5,
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
                          style: TextStyle(
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 137, 135, 135),
                        ),
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
