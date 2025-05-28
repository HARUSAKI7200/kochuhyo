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
      body: Column(
        children: [
          // 描画エリア
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DrawingCanvas(
                key: _canvasKey,
                initialPaths: widget.initialPaths,
                backgroundImagePath: widget.backgroundImagePath,
                currentMode: _drawingMode,
              ),
            ),
          ),
          // 操作ボタンのコンテナ
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton(DrawingMode.free, Icons.edit, 'ペン'),
                _buildModeButton(DrawingMode.line, Icons.show_chart, '直線'),
                _buildModeButton(DrawingMode.rectangle, Icons.crop_square, '四角'),
                _buildModeButton(DrawingMode.eraser, Icons.cleaning_services, '消しゴム'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 描画モード切り替えボタン
  Widget _buildModeButton(DrawingMode mode, IconData icon, String label) {
    final bool isSelected = _drawingMode == mode;
    return FilledButton.tonal(
      onPressed: () => setState(() => _drawingMode = mode),
      style: FilledButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
        foregroundColor: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}