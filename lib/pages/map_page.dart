import 'package:flutter/material.dart';

class ZoomableMapPage extends StatefulWidget {
  final bool enableZoom;

  ZoomableMapPage({
    this.enableZoom = true,
  });

  @override
  _ZoomableMapPageState createState() => _ZoomableMapPageState();
}

class _ZoomableMapPageState extends State<ZoomableMapPage> {
  final TransformationController _transformationController =
      TransformationController();
  final String imagePath = 'assets/RF23_Map.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialTransformation();
    });
  }

  void _setInitialTransformation() {
    final Size size = MediaQuery.of(context).size;
    final double initialScale = 3.0; // Start more zoomed in

    // Center the map
    final double translateX = (size.width - size.width * initialScale) / 2;
    final double translateY =
        ((size.height - size.height * initialScale) / 2) + 150;

    _transformationController.value = Matrix4.identity()
      ..translate(translateX, translateY)
      ..scale(initialScale);
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
        title: Text('Roskilde Festival Map'),
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: EdgeInsets.zero,
        minScale: 2.0, // Prevent zooming out beyond initial scale
        maxScale: 13.0, // Allow zooming in
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.5, // Change the aspect ratio to 1.5:1
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
