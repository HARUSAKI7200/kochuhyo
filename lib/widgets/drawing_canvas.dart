import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

// 描画モードを定義するEnum
enum DrawingMode { free, line, rectangle, eraser }

// 線の種類と点を保持するクラス
class PathSegment {
  final List<Offset> path;
  final DrawingMode mode;
  final Rect? rect; // 四角形用
  final Color color; // 描画色
  final double strokeWidth; // 線幅

  PathSegment({
    required this.path,
    required this.mode,
    this.rect,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
  });

  PathSegment copyWith({
    List<Offset>? path,
    DrawingMode? mode,
    Rect? rect,
    Color? color,
    double? strokeWidth,
  }) {
    return PathSegment(
      path: path ?? this.path,
      mode: mode ?? this.mode,
      rect: rect ?? this.rect,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

class DrawingCanvas extends StatefulWidget {
  final List<PathSegment> initialPaths;
  final String? backgroundImagePath;
  final DrawingMode currentMode;
  final bool isReadOnly;
  final EdgeInsets contentPadding;

  const DrawingCanvas({
    super.key,
    required this.initialPaths,
    this.backgroundImagePath,
    required this.currentMode,
    this.isReadOnly = false,
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  List<PathSegment> _paths = [];
  PathSegment? _currentPath;
  ui.Image? _backgroundImage;
  Rect? _imageDisplayRect;

  PathSegment? _selectedSegment;
  Offset? _dragStartOffset;
  Rect? _originalRect;

  @override
  void initState() {
    super.initState();
    _paths = List.from(widget.initialPaths);
    _loadImage();
  }

  @override
  void didUpdateWidget(DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.backgroundImagePath != oldWidget.backgroundImagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.backgroundImagePath == null) return;
    final data = await DefaultAssetBundle.of(context).load(widget.backgroundImagePath!);
    final image = await decodeImageFromList(data.buffer.asUint8List());
    if (mounted) {
      setState(() => _backgroundImage = image);
    }
  }

  Rect _calculateImageDisplayRect(Size canvasSize) {
    if (_backgroundImage == null) {
      return widget.contentPadding.deflateRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    }
    final imageSize = Size(_backgroundImage!.width.toDouble(), _backgroundImage!.height.toDouble());
    final availableRect = widget.contentPadding.deflateRect(Offset.zero & canvasSize);
    final fittedSizes = applyBoxFit(BoxFit.contain, imageSize, availableRect.size);
    return Alignment.topCenter.inscribe(fittedSizes.destination, availableRect);
  }
  
  // ★★★ ここからが修正後のPNG生成ロジックです ★★★
  Future<Uint8List> getAsPng() async {
    final canvasSize = context.size;
    if (canvasSize == null || canvasSize.isEmpty) return Uint8List(0);

    // 1. 画面上の背景画像が表示されている領域(cropRect)を計算します。
    //    これには上部の余白(padding)によるオフセットが含まれています。
    final cropRect = _calculateImageDisplayRect(canvasSize);
    if (cropRect.isEmpty) return Uint8List(0);

    // 2. 画像を記録するためのPictureRecorderを用意します。
    final recorder = ui.PictureRecorder();

    // 3. 最終的に出力したいPNG画像のサイズでCanvasを作成します。
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, cropRect.width, cropRect.height));

    // 4. Canvasの座標系を、元の大きな描画領域の座標系に合わせるために移動させます。
    //    これにより、手書きの線などが正しい位置に描画されます。
    canvas.translate(-cropRect.left, -cropRect.top);

    // 5. 画面表示に使っているのと同じ設定（同じ手書き線、同じ背景画像、同じパディング）で
    //    Painter（描画役）を準備します。
    final painter = _DrawingPainter(
      _paths,
      _backgroundImage,
      widget.contentPadding,
    );
    
    // 6. 準備したCanvasに、元のウィジェット全体のサイズを指定して描画を実行させます。
    //    座標が移動されているため、結果的にcropRectの範囲だけが記録されます。
    painter.paint(canvas, canvasSize);

    // 7. 記録を終了し、指定したサイズで画像データに変換します。
    final picture = recorder.endRecording();
    final image = await picture.toImage(cropRect.width.toInt(), cropRect.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List() ?? Uint8List(0);
  }
  // ★★★ ここまでが修正後のPNG生成ロジックです ★★★

  List<PathSegment> get paths => _paths;

  void clear() {
    setState(() {
      _paths.clear();
      _currentPath = null;
    });
  }

  void undo() {
    if (_paths.isNotEmpty) {
      setState(() => _paths.removeLast());
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.isReadOnly) return;
    if (_imageDisplayRect?.contains(details.localPosition) != true) return;

    final point = details.localPosition;
    if (widget.currentMode == DrawingMode.rectangle) {
      final segmentToMove = _findSegmentToMove(point);
      if (segmentToMove != null && segmentToMove.rect != null) {
        setState(() {
          _selectedSegment = segmentToMove;
          _dragStartOffset = point;
          _originalRect = segmentToMove.rect;
        });
      } else {
        const fixedSize = Size(30.0, 30.0);
        final rect = Rect.fromCenter(center: point, width: fixedSize.width, height: fixedSize.height);
        final newSegment = PathSegment(path: [point], mode: DrawingMode.rectangle, rect: rect);
        setState(() {
          _paths.add(newSegment);
          _selectedSegment = newSegment;
          _dragStartOffset = point;
          _originalRect = newSegment.rect;
        });
      }
    } else {
      _currentPath = PathSegment(
        path: [point],
        mode: widget.currentMode,
        color: widget.currentMode == DrawingMode.eraser ? Colors.transparent : Colors.black,
        strokeWidth: widget.currentMode == DrawingMode.eraser ? 20.0 : 2.0,
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isReadOnly) return;
    if (_imageDisplayRect?.contains(details.localPosition) != true) {
      _onPanEnd(DragEndDetails()); 
      return;
    }

    final point = details.localPosition;
    if (widget.currentMode == DrawingMode.rectangle) {
      if (_selectedSegment != null && _dragStartOffset != null && _originalRect != null) {
        final delta = point - _dragStartOffset!;
        setState(() {
          final index = _paths.indexOf(_selectedSegment!);
          if (index != -1) {
            _paths[index] = _selectedSegment!.copyWith(rect: _originalRect!.shift(delta));
            _selectedSegment = _paths[index];
          }
        });
      }
    } else {
       if (_currentPath == null) return;
      setState(() {
        _currentPath = _currentPath?.copyWith(path: List.from(_currentPath!.path)..add(point));
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.isReadOnly) return;
    if (widget.currentMode == DrawingMode.rectangle) {
      setState(() {
        _selectedSegment = null;
        _dragStartOffset = null;
        _originalRect = null;
      });
    } else {
      if (_currentPath != null) {
        setState(() {
          if (widget.currentMode == DrawingMode.line && _currentPath!.path.length > 1) {
            _currentPath = _currentPath?.copyWith(path: [_currentPath!.path.first, _currentPath!.path.last]);
          }
          _paths.add(_currentPath!);
          _currentPath = null;
        });
      }
    }
  }

  PathSegment? _findSegmentToMove(Offset point) {
    for (final segment in _paths.reversed) {
      if (segment.mode == DrawingMode.rectangle && segment.rect != null && segment.rect!.contains(point)) {
        return segment;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _imageDisplayRect = _calculateImageDisplayRect(constraints.biggest);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            painter: _DrawingPainter(
              _currentPath != null ? [..._paths, _currentPath!] : _paths,
              _backgroundImage,
              widget.contentPadding,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<PathSegment> paths;
  final ui.Image? backgroundImage;
  final EdgeInsets contentPadding;

  _DrawingPainter(this.paths, this.backgroundImage, this.contentPadding);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.src);
    if (backgroundImage != null) {
      final imageSize = Size(backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());
      final availableRect = contentPadding.deflateRect(Offset.zero & size);
      final fittedSizes = applyBoxFit(BoxFit.contain, imageSize, availableRect.size);
      final sourceRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);
      final destinationRect = Alignment.topCenter.inscribe(fittedSizes.destination, availableRect);
      canvas.drawImageRect(backgroundImage!, sourceRect, destinationRect, Paint());
    }

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (final segment in paths) {
      final paint = Paint()
        ..strokeWidth = segment.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (segment.mode == DrawingMode.eraser) {
        paint.blendMode = BlendMode.clear;
      } else {
        paint.color = segment.color;
      }
      _drawSegment(canvas, segment, paint);
    }
    canvas.restore();
  }

  void _drawSegment(Canvas canvas, PathSegment segment, Paint paint) {
    if (segment.mode == DrawingMode.free || segment.mode == DrawingMode.eraser) {
      if (segment.path.length < 2) return;
      final path = Path()..moveTo(segment.path.first.dx, segment.path.first.dy);
      for (int i = 1; i < segment.path.length; i++) {
        path.lineTo(segment.path[i].dx, segment.path[i].dy);
      }
      canvas.drawPath(path, paint);
    } else if (segment.mode == DrawingMode.line) {
      if (segment.path.length >= 2) {
        canvas.drawLine(segment.path.first, segment.path.last, paint);
      }
    } else if (segment.mode == DrawingMode.rectangle) {
      if (segment.rect != null) {
        canvas.drawRect(segment.rect!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.paths != paths || 
           oldDelegate.backgroundImage != backgroundImage ||
           oldDelegate.contentPadding != contentPadding;
  }
}