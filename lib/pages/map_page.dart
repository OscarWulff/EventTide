import 'package:flutter/material.dart';

class ZoomableMapPage extends StatefulWidget {
  final Function(Offset) onLocationSelected;

  ZoomableMapPage({required this.onLocationSelected});

  @override
  _ZoomableMapPageState createState() => _ZoomableMapPageState();
}

class _ZoomableMapPageState extends State<ZoomableMapPage> {
  final TransformationController _transformationController =
      TransformationController();
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set the initial zoom level to fit the entire image within the viewport
      _transformationController.value = Matrix4.identity()..scale(5.0);
    });
  }

  void _onTapDown(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition =
        renderBox.globalToLocal(details.globalPosition);
    final Matrix4 matrix = _transformationController.value.clone()..invert();
    final Offset transformedPosition =
        MatrixUtils.transformPoint(matrix, localPosition);

    setState(() {
      _tapPosition = transformedPosition;
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
          minScale: 5.0,
          maxScale: 5.0,
          child: Stack(
            children: [
              Image.asset('assets/RF23_Map.png'),
              if (_tapPosition != null)
                Positioned(
                  left: _tapPosition!.dx - 17,
                  top: _tapPosition!.dy - 53,
                  child: Icon(Icons.location_pin, color: Colors.red, size: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
