import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/widgets/drawing_canvas.dart'; // PathSegmentとDrawingModeを参照するため
import 'dart:typed_data'; // Uint8List を参照するため (実際にはこのファイルでは直接使わないが、DrawingScreenの引数型として残す)

class DrawingScreen extends StatefulWidget {
  final List<PathSegment> initialPaths;
  final String backgroundImagePath;
  final String title;
  final bool isGawaTsuma;
  final List<PathSegment> initialGawaPaths;
  final List<PathSegment> initialTsumaPaths;

  const DrawingScreen({
    super.key,
    required this.initialPaths,
    required this.backgroundImagePath,
    required this.title,
  }) : isGawaTsuma = false, initialGawaPaths = const [], initialTsumaPaths = const [];

  const DrawingScreen.gawatsuma({
    super.key,
    required this.initialGawaPaths,
    required this.initialTsumaPaths,
    required this.backgroundImagePath,
    required this.title,
  }) : isGawaTsuma = true, initialPaths = const [];

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  DrawingMode _drawingMode = DrawingMode.free;

  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey<DrawingCanvasState>();
  final GlobalKey<DrawingCanvasState> _gawaCanvasKey = GlobalKey<DrawingCanvasState>();
  final GlobalKey<DrawingCanvasState> _tsumaCanvasKey = GlobalKey<DrawingCanvasState>();

  void _saveAndExit() async {
    if (!mounted) return;

    if (widget.isGawaTsuma) {
      final gawaPaths = _gawaCanvasKey.currentState?.paths ?? [];
      final tsumaPaths = _tsumaCanvasKey.currentState?.paths ?? [];
      final Uint8List? imageBytes = await _gawaCanvasKey.currentState?.getAsPng();

      if (mounted) {
        Navigator.of(context).pop({
          'gawaPaths': gawaPaths,
          'tsumaPaths': tsumaPaths,
          'imageBytes': imageBytes,
        });
      }
    } else {
      final paths = _canvasKey.currentState?.paths ?? [];
      final Uint8List? imageBytes = await _canvasKey.currentState?.getAsPng();
      if (mounted) {
        Navigator.of(context).pop({
          'paths': paths,
          'imageBytes': imageBytes,
        });
      }
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
              if (widget.isGawaTsuma) {
                _gawaCanvasKey.currentState?.undo();
                _tsumaCanvasKey.currentState?.undo(); // 妻側もundoできるようにする
              } else {
                _canvasKey.currentState?.undo();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
               if (widget.isGawaTsuma) {
                _gawaCanvasKey.currentState?.clear();
                _tsumaCanvasKey.currentState?.clear(); // 妻側もクリアできるようにする
              } else {
                _canvasKey.currentState?.clear();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndExit,
          ),
        ],
      ),
      body: Column( // メインのColumn
        children: [
          Expanded( // ★このExpandedが描画エリア全体を占める
            child: widget.isGawaTsuma
                ? Row( // isGawaTsuma == true の場合
                    children: [
                      Expanded(child: _buildDrawingArea( // ★Rowの子としてExpanded
                        key: _gawaCanvasKey,
                        label: '側',
                        paths: widget.initialGawaPaths,
                      )),
                      Expanded(child: _buildDrawingArea( // ★Rowの子としてExpanded
                        key: _tsumaCanvasKey,
                        label: '妻',
                        paths: widget.initialTsumaPaths,
                      )),
                    ],
                  )
                : Expanded(child: _buildDrawingArea( // isGawaTsuma == false の場合、Columnの子としてExpanded
                    key: _canvasKey,
                    label: '',
                    paths: widget.initialPaths,
                  )),
          ),
          Container( // 操作ボタンのコンテナ
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

  // ★★★★★ _buildDrawingAreaの修正 ★★★★★
  // このウィジェットのルートはExpandedではなく、Columnにする。
  // Expandedにするかどうかは呼び出し側で制御する。
  Widget _buildDrawingArea({
    required GlobalKey<DrawingCanvasState> key,
    required String label,
    required List<PathSegment> paths,
  }) {
    return Column( // ★ルートをColumnに変更
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        Expanded( // ★このColumnの中で残りのスペースを占めるためにExpandedを使用
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DrawingCanvas( // DrawingCanvas自体はサイズ制約に従う
              key: key,
              initialPaths: paths,
              backgroundImagePath: widget.backgroundImagePath,
              currentMode: _drawingMode,
            ),
          ),
        ),
      ],
    );
  }
}