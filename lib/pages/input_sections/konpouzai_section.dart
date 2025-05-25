import 'package:flutter/material.dart';

class KonpouzaiSection extends StatefulWidget {
  final TextEditingController konHariWController;
  final TextEditingController konHariTController;
  final TextEditingController konHariNController;

  final TextEditingController konOsaeLController;
  final TextEditingController konOsaeWController;
  final TextEditingController konOsaeTController;
  final TextEditingController konOsaeNController;

  final TextEditingController konTopLController;
  final TextEditingController konTopWController;
  final TextEditingController konTopTController;
  final TextEditingController konTopNController;

  const KonpouzaiSection({
    super.key,
    required this.konHariWController,
    required this.konHariTController,
    required this.konHariNController,
    required this.konOsaeLController,
    required this.konOsaeWController,
    required this.konOsaeTController,
    required this.konOsaeNController,
    required this.konTopLController,
    required this.konTopWController,
    required this.konTopTController,
    required this.konTopNController,
  });

  @override
  State<KonpouzaiSection> createState() => _KonpouzaiSectionState();
}

class _KonpouzaiSectionState extends State<KonpouzaiSection> {
  final List<FocusNode> _focus = List.generate(15, (_) => FocusNode());

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
        const Text('■ 梱包材', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        _buildTripleInput(
          'はり', '幅', '厚さ', '本数',
          widget.konHariWController,
          widget.konHariTController,
          widget.konHariNController,
          _focus[0], _focus[1], _focus[2], _focus[3],
        ),

        const SizedBox(height: 12),
        _buildQuadInput(
          '押さえ材', '長さ', '幅', '厚さ', '本数',
          widget.konOsaeLController,
          widget.konOsaeWController,
          widget.konOsaeTController,
          widget.konOsaeNController,
          _focus[3], _focus[4], _focus[5], _focus[6], _focus[7],
        ),

        const SizedBox(height: 12),
        const Text('トップ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.konTopLController,
                focusNode: _focus[7],
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(_focus[8]),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '長さ'),
              ),
            ),
            const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: widget.konTopWController,
                focusNode: _focus[8],
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(_focus[9]),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '幅'),
              ),
            ),
            const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: widget.konTopTController,
                focusNode: _focus[9],
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(_focus[10]),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '厚さ'),
              ),
            ),
            const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: widget.konTopNController,
                focusNode: _focus[10],
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '本数'),
              ),
            ),
          ],
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

  Widget _buildQuadInput(String label, String l1, String l2, String l3, String l4,
      TextEditingController c1, TextEditingController c2, TextEditingController c3, TextEditingController c4,
      FocusNode f1, FocusNode f2, FocusNode f3, FocusNode f4, FocusNode next) {
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
                onEditingComplete: () => FocusScope.of(context).requestFocus(f4),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l3),
              ),
            ),
            const SizedBox(width: 4), const Text('×'), const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: c4,
                focusNode: f4,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(next),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
