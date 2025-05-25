import 'package:flutter/material.dart';

class KouchuhyoBasicInfoSection extends StatefulWidget {
  final TextEditingController seiriController;
  final TextEditingController shukkaDateController; // 出荷日
  final TextEditingController dateController; // 発行日
  final TextEditingController kobanController;
  final TextEditingController shimukeController;
  final TextEditingController hinmeiController;
  final TextEditingController weightController;
  final TextEditingController amountController;
  final TextEditingController keishikiController;
  final TextEditingController domesticController;
  final TextEditingController uchinoriLengthController;
  final TextEditingController uchinoriWidthController;
  final TextEditingController uchinoriHeightController;
  final TextEditingController sotonoriLengthController;
  final TextEditingController sotonoriWidthController;
  final TextEditingController sotonoriHeightController;
  final TextEditingController gelController; 
  final TextEditingController structureController;

  const KouchuhyoBasicInfoSection({
    super.key,
    required this.seiriController,
    required this.shukkaDateController,
    required this.dateController,
    required this.kobanController,
    required this.shimukeController,
    required this.hinmeiController,
    required this.weightController,
    required this.amountController,
    required this.keishikiController,
    required this.domesticController,
    required this.uchinoriLengthController,
    required this.uchinoriWidthController,
    required this.uchinoriHeightController,
    required this.sotonoriLengthController,
    required this.sotonoriWidthController,
    required this.sotonoriHeightController,
    required this.gelController,
    required this.structureController,
  });

  @override
  State<KouchuhyoBasicInfoSection> createState() => _KouchuhyoBasicInfoSectionState();
}

class _KouchuhyoBasicInfoSectionState extends State<KouchuhyoBasicInfoSection> {
  final List<FocusNode> _f = List.generate(12, (_) => FocusNode());
  final List<FocusNode> _dimFocus = List.generate(6, (_) => FocusNode());

  final List<String> _keishikiOptions = ['枠組み(合板)', '普通木箱(合板)', '腰下付(合板)'];
  final List<String> _domesticOptions = ['輸出', '国内'];
  final List<String> _structureOptions = ['密閉', 'すかし'];
   @override
  void initState() {
    super.initState();
    if (widget.keishikiController.text.isEmpty) {
      widget.keishikiController.text = '腰下付(合板)';
    }
    if (widget.domesticController.text.isEmpty) {
      widget.domesticController.text = '輸出';
    }
    if (widget.structureController.text.isEmpty) {
      widget.structureController.text = '密閉';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateRowField(), // 出荷日・発行日 横並び
        _buildTextField('整理番号', widget.seiriController, _f[2], _f[3]),
        _buildTextField('工番', widget.kobanController, _f[3], _f[4]),
        _buildTextField('仕向先', widget.shimukeController, _f[4], _f[5]),
        _buildTextField('品名', widget.hinmeiController, _f[5], _f[6]),
        _buildTextField('重量（Kg）', widget.weightController, _f[6], _f[7]),
        _buildTextField('数量(C/S)', widget.amountController, _f[7], _f[8]),
        _buildTextField('ゲル（Kg）', widget.gelController, _f[8], _f[9]),
        _buildDropdownField('形式', widget.keishikiController, _keishikiOptions, _f[9], _f[10]),
        _buildDropdownField('構造', widget.structureController, _structureOptions, _f[10], _f[11]),
        _buildDropdownField('出荷区分', widget.domesticController, _domesticOptions, _f[11], FocusNode()),
        const SizedBox(height: 16),
        const Text('寸法（mm）', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildDimensionFields(
          '内のり寸法',
          widget.uchinoriLengthController,
          widget.uchinoriWidthController,
          widget.uchinoriHeightController,
          _dimFocus[0], _dimFocus[1], _dimFocus[2],
          next: _dimFocus[3],
        ),
        const SizedBox(height: 8),
        _buildDimensionFields(
          '外のり寸法',
          widget.sotonoriLengthController,
          widget.sotonoriWidthController,
          widget.sotonoriHeightController,
          _dimFocus[3], _dimFocus[4], _dimFocus[5],
        ),
      ],
    );
  }

  Widget _buildDateRowField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildDatePickerField('出荷日', widget.shukkaDateController, _f[0], _f[1]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDatePickerField('発行日', widget.dateController, _f[1], _f[2]),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, FocusNode current, FocusNode next) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        focusNode: current,
        textInputAction: TextInputAction.next,
        onEditingComplete: () => FocusScope.of(context).requestFocus(next),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, FocusNode current, FocusNode next) {
    return TextField(
      controller: controller,
      focusNode: current,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.text = '${picked.year}/${picked.month}/${picked.day}';
          FocusScope.of(context).requestFocus(next);
        }
      },
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items, FocusNode current, FocusNode next) {
  final currentValue = items.contains(controller.text) ? controller.text : null;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(labelText: label),
      focusNode: current,
      onChanged: (value) {
        setState(() => controller.text = value ?? '');
        FocusScope.of(context).requestFocus(next);
      },
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    ),
  );
}


  Widget _buildDimensionFields(
    String label,
    TextEditingController len,
    TextEditingController w,
    TextEditingController h,
    FocusNode fLen,
    FocusNode fW,
    FocusNode fH, {
    FocusNode? next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: len,
                focusNode: fLen,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(fW),
                decoration: const InputDecoration(labelText: '長さ'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: w,
                focusNode: fW,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).requestFocus(fH),
                decoration: const InputDecoration(labelText: '幅'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: h,
                focusNode: fH,
                textInputAction: next != null ? TextInputAction.next : TextInputAction.done,
                onEditingComplete: () {
                  if (next != null) {
                    FocusScope.of(context).requestFocus(next);
                  } else {
                    FocusScope.of(context).unfocus();
                  }
                },
                decoration: const InputDecoration(labelText: '高さ'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
