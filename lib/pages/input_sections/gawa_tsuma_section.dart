import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'canvas_overlay_page.dart';

class GawaTsumaSection extends StatefulWidget {
  final TextEditingController outerBoardTController;
  final TextEditingController ukamWController;
  final TextEditingController ukamTController;
  final TextEditingController sujiWController;
  final TextEditingController sujiTController;
  final TextEditingController shichuWController;
  final TextEditingController shichuTController;
  final TextEditingController dosanWController;
  final TextEditingController dosanTController;
  final TextEditingController dosanNController;
  final TextEditingController tsumaWController;
  final TextEditingController tsumaTController;
  final TextEditingController hariukeWController;
  final TextEditingController hariukeTController;
  final TextEditingController hariukeEmbedController;
  final TextEditingController soeWController;
  final TextEditingController soeTController;
  final ValueChanged<Uint8List>? onSketch;
  final ValueChanged<String>? onHariukeSelect; // ← 追加

  const GawaTsumaSection({
    super.key,
    required this.outerBoardTController,
    required this.ukamWController,
    required this.ukamTController,
    required this.sujiWController,
    required this.sujiTController,
    required this.shichuWController,
    required this.shichuTController,
    required this.dosanWController,
    required this.dosanTController,
    required this.dosanNController,
    required this.tsumaWController,
    required this.tsumaTController,
    required this.hariukeWController,
    required this.hariukeTController,
    required this.hariukeEmbedController,
    required this.soeWController,
    required this.soeTController,
    this.onSketch,
    this.onHariukeSelect, // ← 追加
  });

  @override
  State<GawaTsumaSection> createState() => _GawaTsumaSectionState();
}

class _GawaTsumaSectionState extends State<GawaTsumaSection> {
  final List<FocusNode> _focus = List.generate(20, (_) => FocusNode());
  String _hariukeOption = '埋めない';

  @override
  void dispose() {
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('■ 側ツマ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        const Text('外板', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          keyboardType: TextInputType.number,
          controller: widget.outerBoardTController,
          focusNode: _focus[0],
          textInputAction: TextInputAction.next,
          onEditingComplete: () => FocusScope.of(context).requestFocus(_focus[1]),
          decoration: const InputDecoration(labelText: '厚さ'),
        ),

        const SizedBox(height: 12),
        _buildDoubleInput('上かまち', '幅', '厚さ', widget.ukamWController, widget.ukamTController, _focus[1], _focus[2], _focus[3]),
        const SizedBox(height: 12),
        _buildDoubleInput('下かまち', '幅', '厚さ', widget.sujiWController, widget.sujiTController, _focus[3], _focus[4], _focus[5]),
        const SizedBox(height: 12),
        _buildDoubleInput('支柱', '幅', '厚さ', widget.shichuWController, widget.shichuTController, _focus[5], _focus[6], _focus[7]),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('はり受', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.hariukeWController,
                    focusNode: _focus[7],
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_focus[8]),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '幅'),
                  ),
                ),
                const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: widget.hariukeTController,
                    focusNode: _focus[8],
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_focus[9]),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '厚さ'),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _hariukeOption,
                  items: ['埋めない', '埋める']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _hariukeOption = val);
                      widget.hariukeEmbedController.text = _hariukeOption;
                      widget.onHariukeSelect?.call(val);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDoubleInput('そえ柱', '幅', '厚さ', widget.soeWController, widget.soeTController, _focus[9], _focus[10], _focus[11]),
        const SizedBox(height: 12),
        _buildTripleInput('胴さん', '幅', '厚さ', '本数', widget.dosanWController, widget.dosanTController, widget.dosanNController,  _focus[11], _focus[12], _focus[13], _focus[14]),
        const SizedBox(height: 12),
        _buildDoubleInput('つまさん', '幅', '厚さ', widget.tsumaWController, widget.tsumaTController, _focus[14], _focus[15], FocusNode(),),

        const SizedBox(height: 16),
        const Text('側ツマ図面（手書き）', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CanvasOverlay(
                    imagePath: 'assets/images/gawa_tsuma_base.jpg',
                    onSave: widget.onSketch,
                  ),
                ),
              );
            },
            child: const Text('手書き入力を開く'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDoubleInput(String label, String label1, String label2,
      TextEditingController c1, TextEditingController c2,
      FocusNode f1, FocusNode f2, FocusNode next) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: c1,
                focusNode: f1,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(f2),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: label1),
              ),
            ),
            const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: c2,
                focusNode: f2,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(next),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: label2),
              ),
            ),
          ],
        ),
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
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: c1,
                focusNode: f1,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(f2),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l1),
              ),
            ),
            const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: c2,
                focusNode: f2,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(f3),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l2),
              ),
            ),
            const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: c3,
                focusNode: f3,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(next),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
