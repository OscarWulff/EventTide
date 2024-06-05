import 'package:flutter/material.dart';

class DayInWeek {
  final String name;
  bool isSelected;

  DayInWeek(this.name, {this.isSelected = false});
}

class SelectWeekDays extends StatefulWidget {
  final List<DayInWeek> days;
  final double fontSize;
  final FontWeight fontWeight;
  final bool border;
  final BoxDecoration boxDecoration;
  final ValueChanged<List<DayInWeek>>? onSelect;

  const SelectWeekDays({
    Key? key,
    required this.days,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.border = true,
    required this.boxDecoration,
    this.onSelect,
  }) : super(key: key);

  @override
  _SelectWeekDaysState createState() => _SelectWeekDaysState();
}

class _SelectWeekDaysState extends State<SelectWeekDays> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: widget.days.map((day) {
        return InkWell(
          onTap: () {
            setState(() {
              for (var d in widget.days) {
                d.isSelected = false;
              }
              day.isSelected = true;
            });
            if (widget.onSelect != null) widget.onSelect!(widget.days);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(10),
            decoration: widget.boxDecoration.copyWith(
              color: day.isSelected ? Color.fromRGBO(222, 121, 46, 0.5) : Colors.transparent,
              borderRadius: day.isSelected ? BorderRadius.circular(30.0) : BorderRadius.circular(0),
            ),
            child: Text(
              day.name,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                color: day.isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
