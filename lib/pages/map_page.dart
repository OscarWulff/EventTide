import 'package:flutter/material.dart';

class ZoomableMapPage extends StatefulWidget {
  final Function(Offset) onLocationSelected;
  final Offset initialLocation;
  final bool enableZoom;
  final bool editable;

  ZoomableMapPage({
    required this.onLocationSelected,
    required this.initialLocation,
    this.enableZoom = false,
    this.editable = false,
  });

  @override
  _ZoomableMapPageState createState() => _ZoomableMapPageState();
}

class _ZoomableMapPageState extends State<ZoomableMapPage> {
  final TransformationController _transformationController =
      TransformationController();
  Offset? _tapPosition;
  final double _fixedScale = 8.0;
  final String imagePath = 'assets/RF23_Map.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _setInitialPosition();
    });

    // Set the initial position based on passed location
    _tapPosition = widget.initialLocation;
  }

  void _setInitialPosition() {
    // Manually set the initial translation values (in pixels)
    final double initialTranslateX =
        -1100; // Change this value to set initial X position
    final double initialTranslateY =
        -750; // Change this value to set initial Y position

    setState(() {
      _transformationController.value = Matrix4.identity()
        ..translate(initialTranslateX, initialTranslateY)
        ..scale(widget.enableZoom ? 10.0 : _fixedScale);
    });
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.editable) return;

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
    if (_tapPosition != null && widget.editable) {
      widget.onLocationSelected(_tapPosition!);
    }
    Navigator.pop(context);
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
          if (widget.editable)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _confirmLocation,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTapDown: _onTapDown,
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: EdgeInsets.all(20.0),
                minScale: widget.enableZoom ? 1.0 : _fixedScale,
                maxScale: widget.enableZoom ? 10.0 : _fixedScale,
                child: Stack(
                  children: [
                    Image.asset(imagePath),
                    if (_tapPosition != null)
                      Positioned(
                        left:
                            _tapPosition!.dx - 6, // Adjusted to center the icon
                        top: _tapPosition!.dy -
                            23, // Adjusted to center the icon
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 10, // Icon size 10 as requested
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
