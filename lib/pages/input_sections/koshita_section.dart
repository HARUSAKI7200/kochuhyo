import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'canvas_overlay_page.dart';

class KoshitaSection extends StatefulWidget {
  final TextEditingController subaWController;
  final TextEditingController subaTController;
  final TextEditingController subaNController;
  final TextEditingController headerWController;
  final TextEditingController headerTController;
  final TextEditingController headerStopController;
  final TextEditingController suriTypeController;
  final TextEditingController suriWController;
  final TextEditingController suriTController;
  final TextEditingController suriNController;
  final TextEditingController yukaTController;
  final TextEditingController fukaWController;
  final TextEditingController fukaTController;
  final TextEditingController fukaNController;
  final List<TextEditingController> nedomLControllers;
  final List<TextEditingController> nedomWControllers;
  final List<TextEditingController> nedomTControllers;
  final List<TextEditingController> nedomNControllers;
  final ValueChanged<Uint8List>? onSketch;

  const KoshitaSection({
    super.key,
    required this.subaWController,
    required this.subaTController,
    required this.subaNController,
    required this.headerWController,
    required this.headerTController,
    required this.headerStopController,
    required this.suriTypeController,
    required this.suriWController,
    required this.suriTController,
    required this.suriNController,
    required this.yukaTController,
    required this.fukaWController,
    required this.fukaTController,
    required this.fukaNController,
    required this.nedomLControllers,
    required this.nedomWControllers,
    required this.nedomTControllers,
    required this.nedomNControllers,
    this.onSketch,
  });

  @override
  State<KoshitaSection> createState() => _KoshitaSectionState();
}

class _KoshitaSectionState extends State<KoshitaSection> {
  final List<FocusNode> _focus = List.generate(50, (_) => FocusNode());

  @override
  void dispose() {
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stopItems = ['釘', 'ボルト'];
    final stopValue = stopItems.contains(widget.headerStopController.text)
        ? widget.headerStopController.text
        : null;

    final typeItems = ['ゲタ', 'すり材'];
    final typeValue = typeItems.contains(widget.suriTypeController.text)
        ? widget.suriTypeController.text
        : 'ゲタ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('■ 腰下', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        _buildTripleInput('滑材', '幅', '厚さ', '本数',
          widget.subaWController, widget.subaTController, widget.subaNController,
          _focus[0], _focus[1], _focus[2], _focus[3]),

        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            flex: 2,
            child: _buildDoubleInput('ヘッダー', '幅', '厚さ',
              widget.headerWController, widget.headerTController,
              _focus[3], _focus[4], _focus[5]),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: stopValue,
              decoration: const InputDecoration(labelText: '止め方'),
              items: stopItems.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => widget.headerStopController.text = val!),
            ),
          ),
        ]),

        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: typeValue,
              decoration: const InputDecoration(labelText: '材種'),
              items: typeItems.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => widget.suriTypeController.text = val!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildTripleInput(
              '', '幅', '厚さ', '本数',
               widget.suriWController,
              widget.suriTController,
              widget.suriNController, // ← 新たに controller を追加
              _focus[6], _focus[7], _focus[8], _focus[9],
           ),
          ),
        ]),

        const SizedBox(height: 12),
        const Text('床板', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: widget.yukaTController,
          decoration: const InputDecoration(labelText: '厚さ'),
          keyboardType: TextInputType.number,
          focusNode: _focus[9],
          textInputAction: TextInputAction.next,
          onEditingComplete: () => FocusScope.of(context).requestFocus(_focus[10]),
        ),

        const SizedBox(height: 12),
        _buildTripleInput('負荷床材', '幅', '厚さ', '本数',
          widget.fukaWController, widget.fukaTController, widget.fukaNController,
          _focus[10], _focus[11], _focus[12], _focus[14]),

        const SizedBox(height: 12),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildQuadInput(
              '根止め材${i + 1}', '長さ', '幅', '厚さ', '本数',
              widget.nedomLControllers[i],
              widget.nedomWControllers[i],
              widget.nedomTControllers[i],
              widget.nedomNControllers[i],
              _focus[14 + i * 4],
              _focus[15 + i * 4],
              _focus[16 + i * 4],
              _focus[17 + i * 4],
              i < 3 ? _focus[18 + i * 4] : FocusNode(), // 最後だけ終了
            ),
          ),

        const SizedBox(height: 16),
        const Text('腰下図面（手書き）', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CanvasOverlay(
                imagePath: 'assets/images/koshita_base.jpg',
                onSave: widget.onSketch,
              )),
            ),
            child: const Text('手書き入力を開く'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTripleInput(String label, String l1, String l2, String l3,
      TextEditingController c1, TextEditingController c2, TextEditingController c3,
      FocusNode f1, FocusNode f2, FocusNode f3, FocusNode next) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Expanded(child: TextField(controller: c1, focusNode: f1, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(f2),
            decoration: InputDecoration(labelText: l1), keyboardType: TextInputType.number)),
          const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
          Expanded(child: TextField(controller: c2, focusNode: f2, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(f3),
            decoration: InputDecoration(labelText: l2), keyboardType: TextInputType.number)),
          const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
          Expanded(child: TextField(controller: c3, focusNode: f3, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(next),
            decoration: InputDecoration(labelText: l3), keyboardType: TextInputType.number)),
        ]),
      ],
    );
  }

  Widget _buildDoubleInput(String label, String l1, String l2,
      TextEditingController c1, TextEditingController c2,
      FocusNode f1, FocusNode f2, FocusNode next) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Expanded(child: TextField(controller: c1, focusNode: f1, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(f2),
            decoration: InputDecoration(labelText: l1), keyboardType: TextInputType.number)),
          const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
          Expanded(child: TextField(controller: c2, focusNode: f2, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(next),
            decoration: InputDecoration(labelText: l2), keyboardType: TextInputType.number)),
        ]),
      ],
    );
  }

  Widget _buildQuadInput(String label, String l1, String l2, String l3, String l4,
      TextEditingController c1, TextEditingController c2, TextEditingController c3, TextEditingController c4,
      FocusNode f1, FocusNode f2, FocusNode f3, FocusNode f4, FocusNode next) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Expanded(child: TextField(controller: c1, focusNode: f1, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(f2),
            decoration: InputDecoration(labelText: l1), keyboardType: TextInputType.number)),
          const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
          Expanded(child: TextField(controller: c2, focusNode: f2, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(f3),
            decoration: InputDecoration(labelText: l2), keyboardType: TextInputType.number)),
          const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
          Expanded(child: TextField(controller: c3, focusNode: f3, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(f4),
            decoration: InputDecoration(labelText: l3), keyboardType: TextInputType.number)),
          const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
          Expanded(child: TextField(controller: c4, focusNode: f4, textInputAction: TextInputAction.next,
            onEditingComplete: () => FocusScope.of(context).requestFocus(next),
            decoration: InputDecoration(labelText: l4), keyboardType: TextInputType.number)),
        ]),
      ],
    );
  }
}
