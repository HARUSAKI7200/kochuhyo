import 'package:flutter/material.dart';

class TenjoSection extends StatefulWidget {
  final TextEditingController upperBoardController;
  final TextEditingController lowerBoardController;

  const TenjoSection({
    super.key,
    required this.upperBoardController,
    required this.lowerBoardController,
  });

  @override
  State<TenjoSection> createState() => _TenjoSectionState();
}

class _TenjoSectionState extends State<TenjoSection> {
  final _focus1 = FocusNode();
  final _focus2 = FocusNode();

  @override
  void dispose() {
    _focus1.dispose();
    _focus2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('■ 天井', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        const Text('上板', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          keyboardType: TextInputType.number,
          controller: widget.upperBoardController,
          focusNode: _focus1,
          textInputAction: TextInputAction.next,
          onEditingComplete: () => FocusScope.of(context).requestFocus(_focus2),
          decoration: const InputDecoration(labelText: '厚さ'),
        ),

        const SizedBox(height: 12),
        const Text('下板', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          keyboardType: TextInputType.number,
          controller: widget.lowerBoardController,
          focusNode: _focus2,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: '厚さ'),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
