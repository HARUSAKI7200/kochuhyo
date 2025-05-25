import 'package:flutter/material.dart';

class TsuikabuzaiSection extends StatefulWidget {
  final List<List<TextEditingController>> controllers;

  const TsuikabuzaiSection({
    super.key,
    required this.controllers,
  });

  @override
  State<TsuikabuzaiSection> createState() => _TsuikabuzaiSectionState();
}

class _TsuikabuzaiSectionState extends State<TsuikabuzaiSection> {
  final List<List<FocusNode>> _focusNodes =
      List.generate(5, (_) => List.generate(5, (_) => FocusNode()));

  @override
  void dispose() {
    for (final row in _focusNodes) {
      for (final f in row) {
        f.dispose();
      }
    }
    super.dispose();
  }

  TableRow buildTableHeader() {
    return const TableRow(
      children: [
        TableCell(child: Center(child: Text('部材名'))),
        TableCell(child: Center(child: Text('長さ'))),
        TableCell(child: Center(child: Text('幅'))),
        TableCell(child: Center(child: Text('厚さ'))),
        TableCell(child: Center(child: Text('本数'))),
      ],
    );
  }

  TableRow buildTableRow(int rowIndex) {
    return TableRow(
      children: List.generate(5, (colIndex) {
        final currentFocus = _focusNodes[rowIndex][colIndex];
        final nextFocus = _getNextFocus(rowIndex, colIndex);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: TextField(
            controller: widget.controllers[rowIndex][colIndex],
            keyboardType: colIndex == 0
                ? TextInputType.text
                : const TextInputType.numberWithOptions(decimal: true),
            focusNode: currentFocus,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              } else {
                FocusScope.of(context).unfocus();
              }
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        );
      }),
    );
  }

  FocusNode? _getNextFocus(int row, int col) {
    if (col < 4) {
      return _focusNodes[row][col + 1];
    } else if (row < 4) {
      return _focusNodes[row + 1][0];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('■ 追加部材', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            buildTableHeader(),
            for (int i = 0; i < 5; i++) buildTableRow(i),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
