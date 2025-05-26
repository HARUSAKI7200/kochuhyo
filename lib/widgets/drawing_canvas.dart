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

  const DrawingCanvas({
    super.key,
    required this.initialPaths,
    this.backgroundImagePath,
    required this.currentMode,
    this.isReadOnly = false,
  });

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  List<PathSegment> _paths = [];
  PathSegment? _currentPath;
  ui.Image? _backgroundImage;
  Rect? _imageDisplayRect; // 背景画像の表示領域を保持

  // --- 四角形移動用の変数 ---
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

  // 背景画像の表示領域を計算するヘルパーメソッド
  Rect _calculateImageDisplayRect(Size canvasSize) {
    if (_backgroundImage == null) {
      return Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);
    }
    final imageSize = Size(_backgroundImage!.width.toDouble(), _backgroundImage!.height.toDouble());
    final fittedSizes = applyBoxFit(BoxFit.contain, imageSize, canvasSize);
    return Alignment.center.inscribe(fittedSizes.destination, Offset.zero & canvasSize);
  }
  
  // ★★★★★ 修正点：画像をトリミングして保存する ★★★★★
  Future<Uint8List> getAsPng() async {
    final canvasSize = context.size!;
    if (canvasSize.isEmpty) return Uint8List(0);
    
    // 1. まずキャンバス全体を画像にレンダリング
    final fullRecorder = ui.PictureRecorder();
    final fullCanvas = Canvas(fullRecorder);
    final painter = _DrawingPainter(_paths, _backgroundImage);
    painter.paint(fullCanvas, canvasSize);
    final fullPicture = fullRecorder.endRecording();
    final fullImage = await fullPicture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());

    // 2. 背景画像の表示領域のみを切り出す
    final cropRect = _calculateImageDisplayRect(canvasSize);
    
    final cropRecorder = ui.PictureRecorder();
    // 切り出すサイズでCanvasを作成
    final cropCanvas = Canvas(cropRecorder, cropRect);

    // fullImageからcropRectの範囲を新しいCanvasに描画
    cropCanvas.drawImageRect(
      fullImage,
      cropRect,
      Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
      Paint(),
    );

    // 3. 切り出した画像をPNGとしてエンコード
    final croppedPicture = cropRecorder.endRecording();
    final croppedImage = await croppedPicture.toImage(cropRect.width.toInt(), cropRect.height.toInt());
    final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

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

  // ★★★★★ 修正点：描画範囲を画像領域に制限 ★★★★★
  void _onPanStart(DragStartDetails details) {
    if (widget.isReadOnly) return;
    // 背景画像の範囲外なら処理を中断
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
        strokeWidth: widget.currentMode == DrawingMode.eraser ? 20.0 : 2.0,
      );
    }
  }

  // ★★★★★ 修正点：描画範囲を画像領域に制限 ★★★★★
  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isReadOnly) return;
    // 背景画像の範囲外なら処理を中断（線を引いている途中で外に出た場合など）
    if (_imageDisplayRect?.contains(details.localPosition) != true) {
      // 外に出たら一旦ペンを離したことにする
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
        // LayoutBuilderでサイズが確定した後に描画範囲を計算
        _imageDisplayRect = _calculateImageDisplayRect(constraints.biggest);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            painter: _DrawingPainter(
              _currentPath != null ? [..._paths, _currentPath!] : _paths,
              _backgroundImage,
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

  _DrawingPainter(this.paths, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    // まず背景を描画
    canvas.drawColor(Colors.white, BlendMode.src);
    if (backgroundImage != null) {
      final imageSize = Size(backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());
      final canvasRect = Offset.zero & size;
      final fittedSizes = applyBoxFit(BoxFit.contain, imageSize, canvasRect.size);
      final sourceRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);
      final destinationRect = Alignment.center.inscribe(fittedSizes.destination, canvasRect);
      canvas.drawImageRect(backgroundImage!, sourceRect, destinationRect, Paint());
    }

    // 次に描画用の新しいレイヤーを作成
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 線と四角形を描画
    for (final segment in paths) {
      if (segment.mode == DrawingMode.eraser) continue;
      final paint = Paint()
        ..color = segment.color
        ..strokeWidth = segment.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      _drawSegment(canvas, segment, paint);
    }

    // 消しゴムを描画（このレイヤーのみクリアする）
    final eraserPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.clear;
    for (final segment in paths) {
      if (segment.mode != DrawingMode.eraser) continue;
      eraserPaint.strokeWidth = segment.strokeWidth;
      _drawSegment(canvas, segment, eraserPaint);
    }

    // レイヤーをキャンバスに結合
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
    return oldDelegate.paths != paths || oldDelegate.backgroundImage != backgroundImage;
  }
}