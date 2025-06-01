import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/widgets/drawing_canvas.dart';
import 'dart:typed_data';

class DrawingScreen extends StatefulWidget {
  final List<PathSegment> initialPaths;
  final String backgroundImagePath;
  final String title;

  const DrawingScreen({
    super.key,
    required this.initialPaths,
    required this.backgroundImagePath,
    required this.title,
  });

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  DrawingMode _drawingMode = DrawingMode.free;
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey<DrawingCanvasState>();
  
  // ★★★ 追加点: ツールバーの高さ分のオフセットを定義 ★★★
  static const double _toolbarOffsetY = 80.0;


  // 保存して前の画面に戻る処理
  void _saveAndExit() async {
    if (!mounted) return;

    final paths = _canvasKey.currentState?.paths ?? [];
    final Uint8List? imageBytes = await _canvasKey.currentState?.getAsPng();
    
    if (mounted) {
      Navigator.of(context).pop({
        'paths': paths,
        'imageBytes': imageBytes,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              _canvasKey.currentState?.undo();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              _canvasKey.currentState?.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndExit,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. 背景の描画エリア
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DrawingCanvas(
              key: _canvasKey,
              initialPaths: widget.initialPaths,
              backgroundImagePath: widget.backgroundImagePath,
              currentMode: _drawingMode,
              // ★★★ 変更点: 背景画像の上部に余白を設定 ★★★
              contentPadding: const EdgeInsets.only(top: _toolbarOffsetY),
            ),
          ),
          // 2. 前面の操作ボタン
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 16.0),
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeButton(DrawingMode.free, Icons.edit, 'ペン'),
                  _buildModeButton(DrawingMode.line, Icons.show_chart, '直線'),
                  _buildModeButton(DrawingMode.rectangle, Icons.crop_square, '四角'),
                  _buildModeButton(DrawingMode.eraser, Icons.cleaning_services, '消しゴム'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 描画モード切り替えボタン
  Widget _buildModeButton(DrawingMode mode, IconData icon, String label) {
    final bool isSelected = _drawingMode == mode;
    return IconButton(
      onPressed: () => setState(() => _drawingMode = mode),
      icon: Icon(icon),
      tooltip: label,
      color: isSelected 
          ? Theme.of(context).colorScheme.primary 
          : Theme.of(context).colorScheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        backgroundColor: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
            : null
      ),
    );
  }
}