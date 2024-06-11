import 'package:flutter/material.dart';

class ZoomableMapPage extends StatefulWidget {
  final Function(Offset) onLocationSelected;

  ZoomableMapPage({required this.onLocationSelected});

  @override
  _ZoomableMapPageState createState() => _ZoomableMapPageState();
}

class _ZoomableMapPageState extends State<ZoomableMapPage> {
  TransformationController _transformationController =
      TransformationController();
  Offset? _tapPosition;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
  }

  void _confirmLocation() {
    if (_tapPosition != null) {
      widget.onLocationSelected(_tapPosition!);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: _onTapDown,
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: EdgeInsets.all(20.0),
          minScale: 0.1,
          maxScale: 4.0,
          child: Stack(
            children: [
              Image.asset('assets/RF23_Map.png'),
              if (_tapPosition != null)
                Positioned(
                  left: _tapPosition!.dx - 15,
                  top: _tapPosition!.dy - 30,
                  child: Icon(Icons.location_pin, color: Colors.red, size: 30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
