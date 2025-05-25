import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CanvasOverlay extends StatefulWidget {
  final String imagePath;
  final void Function(Uint8List)? onSave;

  const CanvasOverlay({super.key, required this.imagePath, this.onSave});

  @override
  State<CanvasOverlay> createState() => _CanvasOverlayState();
}

enum DrawMode { free, straight, rectangle }

enum ToolMode { draw, erase }

class _CanvasOverlayState extends State<CanvasOverlay> {
  final List<_Stroke> _strokes = [];
  final List<Rect> _rectangles = [];
  ToolMode _toolMode = ToolMode.draw;
  DrawMode _drawMode = DrawMode.free;

  Offset? _startPoint;
  Offset? _previewEndPoint;
  Rect? _previewRect;

  GlobalKey repaintKey = GlobalKey();
  ui.Image? _backgroundImage;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadImage(widget.imagePath).then((image) {
      setState(() {
        _backgroundImage = image;
        _scale = _calculateScale(image);
      });
    });
  }

  double _calculateScale(ui.Image image) {
    final mq = MediaQuery.of(context);
    final maxWidth = mq.size.width - 32;
    final maxHeight = mq.size.height - 180;
    final scaleW = maxWidth / image.width;
    final scaleH = maxHeight / image.height;
    return scaleW < scaleH ? scaleW : scaleH;
  }

  bool get _isEraser => _toolMode == ToolMode.erase;

  @override
  Widget build(BuildContext context) {
    if (_backgroundImage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final imgSize = Size(
      _backgroundImage!.width.toDouble(),
      _backgroundImage!.height.toDouble(),
    );
    final displaySize = imgSize * _scale;

    return Scaffold(
      appBar: AppBar(title: const Text('手書き入力')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<ToolMode>(
                  value: _toolMode,
                  onChanged: (ToolMode? newMode) {
                    if (newMode != null) {
                      setState(() => _toolMode = newMode);
                    }
                  },
                  items: ToolMode.values.map((ToolMode mode) {
                    return DropdownMenuItem<ToolMode>(
                      value: mode,
                      child: Text(mode == ToolMode.draw ? '描画モード' : '消しゴム'),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 16),
                DropdownButton<DrawMode>(
                  value: _drawMode,
                  onChanged: (DrawMode? newMode) {
                    if (newMode != null) {
                      setState(() => _drawMode = newMode);
                    }
                  },
                  items: DrawMode.values.map((DrawMode mode) {
                    return DropdownMenuItem<DrawMode>(
                      value: mode,
                      child: Text({
                        DrawMode.free: '自由手書き',
                        DrawMode.straight: '直線モード',
                        DrawMode.rectangle: '矩形モード'
                      }[mode]!),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: repaintKey,
                child: SizedBox(
                  width: displaySize.width,
                  height: displaySize.height,
                  child: GestureDetector(
                    onPanStart: (details) {
                      final local = details.localPosition / _scale;
                      _startPoint = local;
                      if (_isEraser) {
                        setState(() => _strokes.add(_Stroke(offset: local, isErase: true)));
                      } else if (_drawMode == DrawMode.free) {
                        setState(() => _strokes.add(_Stroke(offset: local, isErase: false)));
                      } else if (_drawMode == DrawMode.rectangle) {
                        const fixedSize = Size(170, 170);
                        setState(() => _previewRect = Rect.fromLTWH(local.dx, local.dy, fixedSize.width, fixedSize.height));
                      }
                    },
                    onPanUpdate: (details) {
                      final local = details.localPosition / _scale;
                      if (_isEraser) {
                        setState(() {
                          _strokes.add(_Stroke(offset: local, isErase: true));
                          _rectangles.removeWhere((rect) => rect.contains(local));
                        });
                      } else if (_drawMode == DrawMode.free) {
                        setState(() => _strokes.add(_Stroke(offset: local, isErase: false)));
                      } else if (_drawMode == DrawMode.rectangle) {
                        const fixedSize = Size(170, 170);
                        setState(() => _previewRect = Rect.fromLTWH(local.dx, local.dy, fixedSize.width, fixedSize.height));
                      } else {
                        setState(() => _previewEndPoint = local);
                      }
                    },
                    onPanEnd: (_) {
                      if (_isEraser) {
                        _strokes.add(_Stroke(offset: null, isErase: true));
                      } else if (_drawMode == DrawMode.straight && _startPoint != null && _previewEndPoint != null) {
                        _strokes.addAll([
                          _Stroke(offset: _startPoint!, isErase: false),
                          _Stroke(offset: _previewEndPoint!, isErase: false),
                          _Stroke(offset: null),
                        ]);
                      } else if (_drawMode == DrawMode.rectangle && !_isEraser && _previewRect != null) {
                        _rectangles.add(_previewRect!);
                      } else if (_drawMode == DrawMode.free) {
                        _strokes.add(_Stroke(offset: null));
                      }  
                      _startPoint = null;
                      _previewEndPoint = null;
                      _previewRect = null;
                    },
                    child: CustomPaint(
                      painter: _UnifiedPainter(
                        image: _backgroundImage!,
                        strokes: _strokes,
                        scale: _scale,
                        rectangles: _rectangles,
                        previewLine: !_isEraser && _drawMode == DrawMode.straight && _startPoint != null && _previewEndPoint != null
                            ? [_startPoint!, _previewEndPoint!]
                            : null,
                        previewRect: !_isEraser && _drawMode == DrawMode.rectangle ? _previewRect : null,
                        previewErase: _isEraser,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => setState(() {
              _strokes.clear();
              _rectangles.clear();
            }),
            child: const Text('クリア'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _saveAndClose,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndClose() async {
    if (_backgroundImage == null) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(
      _backgroundImage!.width.toDouble(),
      _backgroundImage!.height.toDouble(),
    );

    _UnifiedPainter(
      image: _backgroundImage!,
      strokes: _strokes,
      rectangles: _rectangles,
      scale: 1.0,
    ).paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null && widget.onSave != null) {
      widget.onSave!(byteData.buffer.asUint8List());
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await DefaultAssetBundle.of(context).load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class _Stroke {
  final Offset? offset;
  final bool isErase;

  _Stroke({required this.offset, this.isErase = false});
}

class _UnifiedPainter extends CustomPainter {
  final ui.Image image;
  final List<_Stroke> strokes;
  final List<Rect> rectangles;
  final double scale;
  final List<Offset>? previewLine;
  final Rect? previewRect;
  final bool previewErase;

  _UnifiedPainter({
    required this.image,
    required this.strokes,
    required this.rectangles,
    required this.scale,
    this.previewLine,
    this.previewRect,
    this.previewErase = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);

    canvas.drawImage(image, Offset.zero, Paint());
    canvas.saveLayer(Offset.zero & (size / scale), Paint());

    final paintDraw = Paint()
      ..color = Colors.black
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.srcOver;

    final paintErase = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < strokes.length - 1; i++) {
      final p1 = strokes[i];
      final p2 = strokes[i + 1];
      if (p1.offset == null || p2.offset == null || p1.isErase != p2.isErase) {
        continue;
      }
      canvas.drawLine(
        p1.offset!,
        p2.offset!,
        p1.isErase ? paintErase : paintDraw,
      );
    }

    for (final rect in rectangles) {
      canvas.drawRect(rect, paintDraw);
    }

    if (previewLine != null && previewLine!.length == 2) {
      canvas.drawLine(
        previewLine![0],
        previewLine![1],
        previewErase ? paintErase : paintDraw,
      );
    }

    if (previewRect != null && !previewErase) {
      canvas.drawRect(previewRect!, paintDraw);
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
