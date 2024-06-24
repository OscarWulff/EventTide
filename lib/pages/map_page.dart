import 'package:flutter/material.dart';

class ZoomableMapPage extends StatefulWidget {
  final Function(Offset) onLocationSelected;
  final Offset? initialLocation; // Made initialLocation nullable
  final bool enableZoom;
  final bool editable;

  ZoomableMapPage({
    required this.onLocationSelected,
    this.initialLocation,
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
  final double _viewScale = 4.0; // Define a different scale for view mode
  final String imagePath = 'assets/RF23_Map.png';

  @override
  void initState() {
    super.initState();
    _tapPosition = widget.initialLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialPosition();
    });
  }

  void _setInitialPosition() {
    final double scale = widget.editable ? _fixedScale : _viewScale;
    final Size screenSize = MediaQuery.of(context).size;
    final double screenCenterX = screenSize.width / 2;
    final double screenCenterY = screenSize.height / 2;

    double initialTranslateX;
    double initialTranslateY;

    if (_tapPosition == Offset(0.0, 0.0)) {
      // Default translation values
      initialTranslateX = widget.editable
          ? -1100
          : -1100 / 2; // Adjust translation based on the scale
      initialTranslateY = widget.editable
          ? -750
          : -750 / 2; // Adjust translation based on the scale
    } else {
      // Centering around the pin
      initialTranslateX = screenCenterX - (_tapPosition!.dx * scale);
      initialTranslateY = screenCenterY - (_tapPosition!.dy * scale);
    }

    setState(() {
      _transformationController.value = Matrix4.identity()
        ..translate(initialTranslateX, initialTranslateY)
        ..scale(scale);
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
        title: Text(widget.editable ? 'Select Location' : 'Event Location'),
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
                        left: _tapPosition!.dx -
                            (widget.editable
                                ? 6
                                : 11), // Adjusted to center the icon based on editable
                        top: _tapPosition!.dy -
                            (widget.editable
                                ? 23
                                : 31), // Adjusted to center the icon based on editable
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: widget.editable
                              ? 10
                              : 20, // Larger icon when not editable
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
