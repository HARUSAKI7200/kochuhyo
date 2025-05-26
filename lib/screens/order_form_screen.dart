import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kouchuhyo_app/widgets/drawing_canvas.dart';
import 'package:kouchuhyo_app/screens/drawing_screen.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  // --- フォーカスノード ---
  final Map<String, FocusNode> _focusNodes = {};

  // --- 基本情報セクションのコントローラー ---
  final TextEditingController _shippingDateController = TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController(text: 'A-');
  final TextEditingController _kobangoController = TextEditingController();
  final TextEditingController _shihomeisakiController = TextEditingController();
  final TextEditingController _hinmeiController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // --- 寸法関連のコントローラーと値 ---
  final TextEditingController _innerLengthController = TextEditingController();
  final TextEditingController _innerWidthController = TextEditingController();
  final TextEditingController _innerHeightController = TextEditingController();

  final TextEditingController _outerLengthDisplayController = TextEditingController();
  final TextEditingController _outerWidthDisplayController = TextEditingController();
  final TextEditingController _outerHeightDisplayController = TextEditingController();
  final TextEditingController _packagingVolumeDisplayController = TextEditingController();

  // --- 選択肢の状態 ---
  String? _selectedShippingType;
  String? _selectedPackingForm;

  final Map<String, bool> _formTypes = {
    'わく組（合板）': false,
    '外さんわく組（合板）': false,
    '普通木箱（合板）': false,
    '腰下付（合板）': false,
    '腰下': false,
  };

  // --- 腰下セクションのコントローラー ---
  final TextEditingController _skidWidthController = TextEditingController();
  final TextEditingController _skidThicknessController = TextEditingController();
  final TextEditingController _skidQuantityController = TextEditingController();

  final TextEditingController _hWidthController = TextEditingController();
  final TextEditingController _hThicknessController = TextEditingController();
  String? _hFixingMethod;

  String? _selectedSuriGetaType;
  final TextEditingController _suriGetaWidthController = TextEditingController();
  final TextEditingController _suriGetaThicknessController = TextEditingController();
  final TextEditingController _getaQuantityController = TextEditingController();

  final TextEditingController _floorBoardThicknessController = TextEditingController();

  final TextEditingController _loadBearingMaterialWidthController = TextEditingController();
  final TextEditingController _loadBearingMaterialThicknessController = TextEditingController();
  final TextEditingController _loadBearingMaterialQuantityController = TextEditingController();
  String? _loadCalculationMethod;

  final TextEditingController _rootStopLengthController = TextEditingController();
  final TextEditingController _rootStopWidthController = TextEditingController();
  final TextEditingController _rootStopThicknessController = TextEditingController();
  final TextEditingController _rootStopQuantityController = TextEditingController();

  // --- 側ツマセクションのコントローラー ---
  final TextEditingController _sideBoardThicknessController = TextEditingController();
  final TextEditingController _upperKamachiWidthController = TextEditingController();
  final TextEditingController _upperKamachiThicknessController = TextEditingController();
  final TextEditingController _lowerKamachiWidthController = TextEditingController();
  final TextEditingController _lowerKamachiThicknessController = TextEditingController();
  final TextEditingController _pillarWidthController = TextEditingController();
  final TextEditingController _pillarThicknessController = TextEditingController();

  final TextEditingController _beamReceiverWidthController = TextEditingController();
  final TextEditingController _beamReceiverThicknessController = TextEditingController();
  bool _beamReceiverEmbed = false;

  final TextEditingController _bracePillarWidthController = TextEditingController();
  final TextEditingController _bracePillarThicknessController = TextEditingController();
  bool _bracePillarShortEnds = false;

  // --- 天井セクションのコントローラー ---
  final TextEditingController _ceilingUpperBoardThicknessController = TextEditingController();
  final TextEditingController _ceilingLowerBoardThicknessController = TextEditingController();

  // --- 梱包材セクションのコントローラー ---
  final TextEditingController _pressingMaterialLengthController = TextEditingController();
  final TextEditingController _pressingMaterialWidthController = TextEditingController();
  final TextEditingController _pressingMaterialThicknessController = TextEditingController();
  final TextEditingController _pressingMaterialQuantityController = TextEditingController();
  bool _pressingMaterialHasMolding = false;

  final TextEditingController _topMaterialLengthController = TextEditingController();
  final TextEditingController _topMaterialWidthController = TextEditingController();
  final TextEditingController _topMaterialThicknessController = TextEditingController();
  final TextEditingController _topMaterialQuantityController = TextEditingController();

  // --- 追加部材セクションのコントローラー ---
  final List<TextEditingController> _additionalPartNameControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _additionalPartLengthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _additionalPartWidthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _additionalPartThicknessControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _additionalPartQuantityControllers = List.generate(5, (_) => TextEditingController());

  // --- 手書きデータ & プレビュー画像 ---
  List<PathSegment> _koshitaPaths = [];
  List<PathSegment> _gawaPaths = [];
  List<PathSegment> _tsumaPaths = [];
  Uint8List? _koshitaImageBytes; // ★腰下プレビュー画像用
  Uint8List? _gawaTsumaImageBytes; // ★側妻プレビュー画像用

  @override
  void initState() {
    super.initState();
    _selectedSuriGetaType = 'すり材'; // 初期選択
    _issueDateController.text = DateFormat('yyyy/MM/dd').format(DateTime.now());

    final listeners = [
      _innerLengthController, _innerWidthController, _innerHeightController,
      _upperKamachiWidthController, _skidThicknessController,
      _suriGetaThicknessController, _getaQuantityController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _floorBoardThicknessController
    ];
    for (var controller in listeners) {
      controller.addListener(_calculateOuterDimensions);
    }
    _initFocusNodes();
  }

  void _initFocusNodes() {
    final allControllers = [
      _shippingDateController, _issueDateController, _serialNumberController, _kobangoController,
      _shihomeisakiController, _hinmeiController, _weightController, _quantityController,
      _innerLengthController, _innerWidthController, _innerHeightController,
      _skidWidthController, _skidThicknessController, _skidQuantityController,
      _hWidthController, _hThicknessController, _suriGetaWidthController,
      _suriGetaThicknessController, _getaQuantityController, _floorBoardThicknessController,
      _loadBearingMaterialWidthController, _loadBearingMaterialThicknessController,
      _loadBearingMaterialQuantityController, _rootStopLengthController,
      _rootStopWidthController, _rootStopThicknessController, _rootStopQuantityController,
      _sideBoardThicknessController, _upperKamachiWidthController, _upperKamachiThicknessController,
      _lowerKamachiWidthController, _lowerKamachiThicknessController, _pillarWidthController,
      _pillarThicknessController, _beamReceiverWidthController, _beamReceiverThicknessController,
      _bracePillarWidthController, _bracePillarThicknessController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _pressingMaterialLengthController, _pressingMaterialWidthController,
      _pressingMaterialThicknessController, _pressingMaterialQuantityController,
      _topMaterialLengthController, _topMaterialWidthController, _topMaterialThicknessController,
      _topMaterialQuantityController,
      ..._additionalPartNameControllers, ..._additionalPartLengthControllers,
      ..._additionalPartWidthControllers, ..._additionalPartThicknessControllers,
      ..._additionalPartQuantityControllers
    ];
    for (int i = 0; i < allControllers.length; i++) {
      _focusNodes['controller_$i'] = FocusNode();
    }
  }

  void _nextFocus(int currentIndex) {
    if (_focusNodes.containsKey('controller_${currentIndex + 1}')) {
      FocusScope.of(context).requestFocus(_focusNodes['controller_${currentIndex + 1}']);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Widget _buildFocusableTextField(String? labelText, TextEditingController controller, int index, {TextInputType keyboardType = TextInputType.text, String? hintText, bool readOnly = false}) {
    return TextField(
      controller: controller, keyboardType: keyboardType, readOnly: readOnly,
      focusNode: _focusNodes['controller_$index'], onSubmitted: (_) => _nextFocus(index),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: labelText, hintText: hintText, border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), isDense: true,
      ),
    );
  }

  @override
  void dispose() {
    final listeners = [
      _innerLengthController, _innerWidthController, _innerHeightController,
      _upperKamachiWidthController, _skidThicknessController,
      _suriGetaThicknessController, _getaQuantityController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _floorBoardThicknessController
    ];
    for (var controller in listeners) {
      controller.removeListener(_calculateOuterDimensions);
    }
    
    final allControllers = [
      _shippingDateController, _issueDateController, _serialNumberController, _kobangoController,
      _shihomeisakiController, _hinmeiController, _weightController, _quantityController,
      _innerLengthController, _innerWidthController, _innerHeightController,
      _outerLengthDisplayController, _outerWidthDisplayController, _outerHeightDisplayController,
      _packagingVolumeDisplayController, _skidWidthController, _skidThicknessController,
      _skidQuantityController, _hWidthController, _hThicknessController,
      _suriGetaWidthController, _suriGetaThicknessController, _getaQuantityController,
      _floorBoardThicknessController, _loadBearingMaterialWidthController,
      _loadBearingMaterialThicknessController, _loadBearingMaterialQuantityController,
      _rootStopLengthController, _rootStopWidthController, _rootStopThicknessController,
      _rootStopQuantityController, _sideBoardThicknessController, _upperKamachiWidthController,
      _upperKamachiThicknessController, _lowerKamachiWidthController, _lowerKamachiThicknessController,
      _pillarWidthController, _pillarThicknessController, _beamReceiverWidthController,
      _beamReceiverThicknessController, _bracePillarWidthController, _bracePillarThicknessController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _pressingMaterialLengthController, _pressingMaterialWidthController,
      _pressingMaterialThicknessController, _pressingMaterialQuantityController,
      _topMaterialLengthController, _topMaterialWidthController, _topMaterialThicknessController,
      _topMaterialQuantityController,
      ..._additionalPartNameControllers, ..._additionalPartLengthControllers,
      ..._additionalPartWidthControllers, ..._additionalPartThicknessControllers,
      ..._additionalPartQuantityControllers
    ];
    for (var controller in allControllers) {
      controller.dispose();
    }
    
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller, int index) async {
    DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => controller.text = DateFormat('yyyy/MM/dd').format(picked));
      _nextFocus(index);
    }
  }

  void _calculateOuterDimensions() {
    final innerLength = double.tryParse(_innerLengthController.text) ?? 0.0;
    final innerWidth = double.tryParse(_innerWidthController.text) ?? 0.0;
    final innerHeight = double.tryParse(_innerHeightController.text) ?? 0.0;
    final upperKamachiWidthValue = double.tryParse(_upperKamachiWidthController.text) ?? 0.0;
    final horizontalAddition = upperKamachiWidthValue > 0 ? 80.0 : 0.0;
    double suriGetaOrGetaThickness = 0.0;
    if (_selectedSuriGetaType == 'すり材') {
      suriGetaOrGetaThickness = double.tryParse(_suriGetaThicknessController.text) ?? 0.0;
    } else if (_selectedSuriGetaType == 'ゲタ') {
      suriGetaOrGetaThickness = double.tryParse(_suriGetaThicknessController.text) ?? 0.0;
    }
    final skidThickness = double.tryParse(_skidThicknessController.text) ?? 0.0;
    final ceilingUpperBoardThickness = double.tryParse(_ceilingUpperBoardThicknessController.text) ?? 0.0;
    final ceilingLowerBoardThickness = double.tryParse(_ceilingLowerBoardThicknessController.text) ?? 0.0;
    final outerLength = innerLength + horizontalAddition;
    final outerWidth = innerWidth + horizontalAddition;
    final outerHeight = innerHeight + suriGetaOrGetaThickness + skidThickness + ceilingUpperBoardThickness + ceilingLowerBoardThickness + 10.0;
    
    setState(() {
      _outerLengthDisplayController.text = outerLength.toStringAsFixed(0);
      _outerWidthDisplayController.text = outerWidth.toStringAsFixed(0);
      _outerHeightDisplayController.text = outerHeight.toStringAsFixed(0);
      final volume = (outerLength / 1000.0) * (outerWidth / 1000.0) * (outerHeight / 1000.0);
      _packagingVolumeDisplayController.text = volume.toStringAsFixed(3);
    });
  }

  void _navigateToKoshitaDrawingScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrawingScreen(
          initialPaths: _koshitaPaths, // ★現在のパスデータを渡す
          backgroundImagePath: 'assets/koshita_base.jpg',
          title: '腰下ベース',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // ★描画画面から返されたパスデータと画像データで更新
        _koshitaPaths = result['paths'] as List<PathSegment>? ?? _koshitaPaths;
        _koshitaImageBytes = result['imageBytes'] as Uint8List?;
      });
    }
  }

  void _navigateToGawaTsumaDrawingScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrawingScreen.gawatsuma(
          initialGawaPaths: _gawaPaths, // ★現在のパスデータを渡す
          initialTsumaPaths: _tsumaPaths, // ★現在のパスデータを渡す
          backgroundImagePath: 'assets/gawa_tsuma_base.jpg',
          title: '側・妻',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // ★描画画面から返されたパスデータと画像データで更新
        _gawaPaths = result['gawaPaths'] as List<PathSegment>? ?? _gawaPaths;
        _tsumaPaths = result['tsumaPaths'] as List<PathSegment>? ?? _tsumaPaths;
        _gawaTsumaImageBytes = result['imageBytes'] as Uint8List?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int focusIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('工注票', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 80),
                const Text('工 注 票', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('整理番号', style: TextStyle(fontSize: 12)),
                    SizedBox(
                      width: 100,
                      child: _buildFocusableTextField(null, _serialNumberController, focusIndex++, hintText: 'A-100'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('基本情報セクション'),
            Row(
              children: [
                Expanded(child: _buildLabeledDateInput('出荷日', _shippingDateController, focusIndex++, _selectDate)),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledDateInput('発行日', _issueDateController, focusIndex++, _selectDate)),
              ],
            ),
            _buildLabeledTextField('工番', _kobangoController, focusIndex++),
            _buildLabeledTextField('仕向先', _shihomeisakiController, focusIndex++),
            _buildLabeledTextField('品名', _hinmeiController, focusIndex++),
            _buildLabeledTextField('重量 (KG)', _weightController, focusIndex++, keyboardType: TextInputType.number),
            _buildLabeledTextField('数量 (C/S)', _quantityController, focusIndex++, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            const Text('出荷形態', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [_buildRadioOption('国内', _selectedShippingType, (value) => setState(() => _selectedShippingType = value)), _buildRadioOption('輸出', _selectedShippingType, (value) => setState(() => _selectedShippingType = value))]),
            const SizedBox(height: 16),
            const Text('形式', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildFormTypeCheckboxes(),
            const SizedBox(height: 16),
            const Text('形状', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [_buildRadioOption('密閉', _selectedPackingForm, (value) => setState(() => _selectedPackingForm = value)), _buildRadioOption('すかし', _selectedPackingForm, (value) => setState(() => _selectedPackingForm = value))]),
            const SizedBox(height: 16),
            _buildDimensionInputRow('内寸 (mm)', _innerLengthController, focusIndex++, _innerWidthController, focusIndex++, _innerHeightController, focusIndex++),
            const SizedBox(height: 16),
            _buildDimensionDisplayRow('外寸 (mm)', _outerLengthDisplayController, _outerWidthDisplayController, _outerHeightDisplayController),
            const SizedBox(height: 16),
            _buildLabeledTextField('梱包明細: 容積 m3', _packagingVolumeDisplayController, focusIndex++, readOnly: true),

            _buildSectionTitle('腰下セクション'),
            _buildDimensionWithQuantityInput('滑材 (mm)', '幅', _skidWidthController, focusIndex++, '厚', _skidThicknessController, focusIndex++, '本数', _skidQuantityController, focusIndex++),
            _buildDimensionWithRadioInput('H (mm)', '幅', _hWidthController, focusIndex++, '厚', _hThicknessController, focusIndex++, '止め方', ['釘', 'ボルト'], _hFixingMethod, (value) => setState(() => _hFixingMethod = value)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('すり材 or ゲタ', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [_buildRadioOption('すり材', _selectedSuriGetaType, (value) => setState(() { _selectedSuriGetaType = value; _calculateOuterDimensions(); })), _buildRadioOption('ゲタ', _selectedSuriGetaType, (value) => setState(() { _selectedSuriGetaType = value; _calculateOuterDimensions(); }))]),
                Row(
                  children: [
                    Expanded(child: _buildFocusableTextField('幅', _suriGetaWidthController, focusIndex++, keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFocusableTextField('厚さ', _suriGetaThicknessController, focusIndex++, keyboardType: TextInputType.number)),
                    if (_selectedSuriGetaType == 'ゲタ') ...[const SizedBox(width: 8), Expanded(child: _buildFocusableTextField('本数', _getaQuantityController, focusIndex++, keyboardType: TextInputType.number))],
                  ],
                ),
              ],
            ),
            _buildLabeledTextField('床板 (mm)', _floorBoardThicknessController, focusIndex++, keyboardType: TextInputType.number),
            _buildDimensionWithQuantityInput('負荷床材', '幅', _loadBearingMaterialWidthController, focusIndex++, '厚さ', _loadBearingMaterialThicknessController, focusIndex++, '本数', _loadBearingMaterialQuantityController, focusIndex++),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('計算方法', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [_buildRadioOption('等分布荷重', _loadCalculationMethod, (value) => setState(() => _loadCalculationMethod = value)), _buildRadioOption('中央集中荷重', _loadCalculationMethod, (value) => setState(() => _loadCalculationMethod = value)), _buildRadioOption('2点集中荷重', _loadCalculationMethod, (value) => setState(() => _loadCalculationMethod = value))]),
              ],
            ),
            _buildDimensionWithQuantityInput('根止め', '長', _rootStopLengthController, focusIndex++, '幅', _rootStopWidthController, focusIndex++, '本数', _rootStopQuantityController, focusIndex++, dim3Label: '厚', dim3Ctrl: _rootStopThicknessController, dim3Idx: focusIndex++),
            
            const SizedBox(height: 16),
            _buildDrawingPreview(
              title: '図面手書き入力 (腰下ベース)',
              onTap: _navigateToKoshitaDrawingScreen,
              imageBytes: _koshitaImageBytes, // ★プレビュー画像を表示
              placeholder: 'タップして腰下ベースを描く',
            ),

            _buildSectionTitle('側ツマセクション'),
            _buildLabeledTextField('外板 (mm)', _sideBoardThicknessController, focusIndex++, keyboardType: TextInputType.number),
            _buildDimensionInputRow('上かまち', _upperKamachiWidthController, focusIndex++, _upperKamachiThicknessController, focusIndex++, null, focusIndex),
            _buildDimensionInputRow('下かまち', _lowerKamachiWidthController, focusIndex++, _lowerKamachiThicknessController, focusIndex++, null, focusIndex),
            _buildDimensionInputRow('支柱', _pillarWidthController, focusIndex++, _pillarThicknessController, focusIndex++, null, focusIndex),
            _buildDimensionWithCheckbox('はり受', '幅', _beamReceiverWidthController, focusIndex++, '厚さ', _beamReceiverThicknessController, focusIndex++, '埋める', _beamReceiverEmbed, (value) => setState(() => _beamReceiverEmbed = value!)),
            _buildDimensionWithCheckbox('そえ柱', '幅', _bracePillarWidthController, focusIndex++, '厚さ', _bracePillarThicknessController, focusIndex++, '両端短め', _bracePillarShortEnds, (value) => setState(() => _bracePillarShortEnds = value!)),
            
            const SizedBox(height: 16),
            _buildDrawingPreview(
              title: '図面手書き入力 (側・妻)',
              onTap: _navigateToGawaTsumaDrawingScreen,
              imageBytes: _gawaTsumaImageBytes, // ★プレビュー画像を表示
              placeholder: 'タップして側・妻を描く',
            ),

            _buildSectionTitle('天井セクション'),
            Row(
              children: [
                Expanded(child: _buildLabeledTextField('上板 (mm)', _ceilingUpperBoardThicknessController, focusIndex++, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledTextField('下板 (mm)', _ceilingLowerBoardThicknessController, focusIndex++, keyboardType: TextInputType.number)),
              ],
            ),

            _buildSectionTitle('梱包材セクション'),
            _buildMaterialInputRow('押さえ材', '長', _pressingMaterialLengthController, focusIndex++, '幅', _pressingMaterialWidthController, focusIndex++, '厚', _pressingMaterialThicknessController, focusIndex++, '本数', _pressingMaterialQuantityController, focusIndex++),
            _buildCheckboxOption('盛り材が有', _pressingMaterialHasMolding, (value) => setState(() => _pressingMaterialHasMolding = value!)),
            _buildMaterialInputRow('トップ材', '長', _topMaterialLengthController, focusIndex++, '幅', _topMaterialWidthController, focusIndex++, '厚', _topMaterialThicknessController, focusIndex++, '本数', _topMaterialQuantityController, focusIndex++),
            
            _buildSectionTitle('追加部材セクション (5行)'),
            for (int i = 0; i < 5; i++)
              _buildAdditionalPartRow(_additionalPartNameControllers[i], focusIndex++, _additionalPartLengthControllers[i], focusIndex++, _additionalPartWidthControllers[i], focusIndex++, _additionalPartThicknessControllers[i], focusIndex++, _additionalPartQuantityControllers[i], focusIndex++),
            
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _saveFormData,
                child: const Text('入力内容を保存 (開発中)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingPreview({
    required String title,
    required VoidCallback onTap,
    required Uint8List? imageBytes,
    required String placeholder,
  }) {
    const double previewHeight = 250.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: previewHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey.shade100,
            ),
            child: imageBytes == null
                ? Center(child: Text(placeholder, style: TextStyle(color: Colors.grey.shade700)))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain, // ★枠内に収まるように表示
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('画像表示エラー')),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text('--- $title ---', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
    );
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller, int index, {double width = 200, TextInputType keyboardType = TextInputType.text, String? hintText, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: _buildFocusableTextField(null, controller, index, keyboardType: keyboardType, hintText: hintText, readOnly: readOnly)),
        ],
      ),
    );
  }

  Widget _buildLabeledDateInput(String label, TextEditingController controller, int index, Function(TextEditingController, int) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(child: GestureDetector(
            onTap: () => onSelect(controller, index),
            child: AbsorbPointer(child: _buildFocusableTextField(null, controller, index, hintText: 'yyyy/MM/dd', readOnly: true)),
          )),
        ],
      ),
    );
  }

  Widget _buildDimensionInputRow(String title, TextEditingController lenCtrl, int lenIdx, TextEditingController widthCtrl, int widthIdx, TextEditingController? heightCtrl, int heightIdx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildFocusableTextField('長', lenCtrl, lenIdx, keyboardType: TextInputType.number))),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildFocusableTextField('幅', widthCtrl, widthIdx, keyboardType: TextInputType.number))),
            if (heightCtrl != null) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildFocusableTextField('高', heightCtrl, heightIdx, keyboardType: TextInputType.number))),
          ],
        ),
      ],
    );
  }

  Widget _buildDimensionDisplayRow(String title, TextEditingController lenCtrl, TextEditingController widthCtrl, TextEditingController heightCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildFocusableTextField('長', lenCtrl, -1, readOnly: true))),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildFocusableTextField('幅', widthCtrl, -1, readOnly: true))),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildFocusableTextField('高', heightCtrl, -1, readOnly: true))),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value, String? groupValue, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Row(
        children: [
          Radio<String>(value: value, groupValue: groupValue, onChanged: onChanged, visualDensity: VisualDensity.compact),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, visualDensity: VisualDensity.compact),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildFormTypeCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _formTypes.keys.map((String key) {
        return Row(
          children: [
            Checkbox(
              value: _formTypes[key]!,
              onChanged: (bool? value) => setState(() => _formTypes[key] = value!),
              visualDensity: VisualDensity.compact,
            ),
            Text(key, style: const TextStyle(fontSize: 14)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDimensionWithQuantityInput(
    String label, String dim1Label, TextEditingController dim1Ctrl, int dim1Idx,
    String dim2Label, TextEditingController dim2Ctrl, int dim2Idx,
    String quantityLabel, TextEditingController quantityCtrl, int quantityIdx,
    {TextEditingController? dim3Ctrl, String? dim3Label, int? dim3Idx}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(child: _buildFocusableTextField(dim1Label, dim1Ctrl, dim1Idx, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildFocusableTextField(dim2Label, dim2Ctrl, dim2Idx, keyboardType: TextInputType.number)),
              if (dim3Ctrl != null && dim3Label != null && dim3Idx != null) ...[
                const SizedBox(width: 8),
                Expanded(child: _buildFocusableTextField(dim3Label, dim3Ctrl, dim3Idx, keyboardType: TextInputType.number)),
              ],
              const SizedBox(width: 8),
              Expanded(child: _buildFocusableTextField(quantityLabel, quantityCtrl, quantityIdx, keyboardType: TextInputType.number)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialInputRow(
    String label, String dim1Label, TextEditingController dim1Ctrl, int dim1Idx,
    String dim2Label, TextEditingController dim2Ctrl, int dim2Idx,
    String dim3Label, TextEditingController dim3Ctrl, int dim3Idx,
    String quantityLabel, TextEditingController quantityCtrl, int quantityIdx,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(child: _buildFocusableTextField(dim1Label, dim1Ctrl, dim1Idx, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildFocusableTextField(dim2Label, dim2Ctrl, dim2Idx, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildFocusableTextField(dim3Label, dim3Ctrl, dim3Idx, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildFocusableTextField(quantityLabel, quantityCtrl, quantityIdx, keyboardType: TextInputType.number)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionWithRadioInput(
    String label, String dim1Label, TextEditingController dim1Ctrl, int dim1Idx,
    String dim2Label, TextEditingController dim2Ctrl, int dim2Idx,
    String radioLabel, List<String> radioOptions, String? groupValue, ValueChanged<String?> onChanged
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(child: _buildFocusableTextField(dim1Label, dim1Ctrl, dim1Idx, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildFocusableTextField(dim2Label, dim2Ctrl, dim2Idx, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(radioLabel),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: radioOptions.map((option) => Expanded(child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(value: option, groupValue: groupValue, onChanged: onChanged, visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          Text(option, style: const TextStyle(fontSize: 12)),
                        ],
                      ))).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionWithCheckbox(
    String label, String dim1Label, TextEditingController dim1Ctrl, int dim1Idx,
    String dim2Label, TextEditingController dim2Ctrl, int dim2Idx,
    String checkboxLabel, bool checkboxValue, ValueChanged<bool?> onChanged
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(child: _buildFocusableTextField(dim1Label, dim1Ctrl, dim1Idx, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildFocusableTextField(dim2Label, dim2Ctrl, dim2Idx, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              _buildCheckboxOption(checkboxLabel, checkboxValue, onChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalPartRow(
    TextEditingController nameCtrl, int nameIdx, TextEditingController lenCtrl, int lenIdx,
    TextEditingController widthCtrl, int widthIdx, TextEditingController thicknessCtrl, int thicknessIdx,
    TextEditingController quantityCtrl, int quantityIdx
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: _buildFocusableTextField('部材名', nameCtrl, nameIdx)),
          const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField('長', lenCtrl, lenIdx, keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField('幅', widthCtrl, widthIdx, keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField('厚', thicknessCtrl, thicknessIdx, keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField('本数', quantityCtrl, quantityIdx, keyboardType: TextInputType.number)),
        ],
      ),
    );
  }

  void _saveFormData() {
    print('--- 工注票データ ---');
    print('出荷日: ${_shippingDateController.text}');
    print('発行日: ${_issueDateController.text}');
    print('整理番号: ${_serialNumberController.text}');
    print('工番: ${_kobangoController.text}');
    print('仕向先: ${_shihomeisakiController.text}');
    print('品名: ${_hinmeiController.text}');
    print('重量: ${_weightController.text} KG');
    print('出荷形態: ${_selectedShippingType ?? '未選択'}');
    print('数量: ${_quantityController.text} C/S');
    print('形式: ${_formTypes.entries.where((e) => e.value).map((e) => e.key).join(', ')}');
    print('形状: ${_selectedPackingForm ?? '未選択'}');
    print('内寸: 長 ${_innerLengthController.text}mm, 幅 ${_innerWidthController.text}mm, 高 ${_innerHeightController.text}mm');
    print('外寸: 長 ${_outerLengthDisplayController.text}mm, 幅 ${_outerWidthDisplayController.text}mm, 高 ${_outerHeightDisplayController.text}mm');
    print('梱包明細: 容積 ${_packagingVolumeDisplayController.text} m3');

    print('\n--- 腰下セクション ---');
    print('滑材: 幅 ${_skidWidthController.text}x厚 ${_skidThicknessController.text}・本数 ${_skidQuantityController.text}');
    print('H: 幅 ${_hWidthController.text}x厚 ${_hThicknessController.text}・止め方 ${_hFixingMethod ?? '未選択'}');
    print('すり材/ゲタ: ${_selectedSuriGetaType ?? '未選択'} - 幅 ${_suriGetaWidthController.text}x厚さ ${_suriGetaThicknessController.text}${_selectedSuriGetaType == 'ゲタ' ? 'x本数 ${_getaQuantityController.text}' : ''}');
    print('床板: ${_floorBoardThicknessController.text}mm');
    print('負荷床材: 幅 ${_loadBearingMaterialWidthController.text}x厚さ ${_loadBearingMaterialThicknessController.text}・本数 ${_loadBearingMaterialQuantityController.text}');
    print('計算方法: ${_loadCalculationMethod ?? '未選択'}');
    print('根止め: 長 ${_rootStopLengthController.text}x幅 ${_rootStopWidthController.text}x厚 ${_rootStopThicknessController.text}・本数 ${_rootStopQuantityController.text}');
    print('腰下図面データ (${_koshitaPaths.length} segments)'); // ★パスの変数名に合わせて修正


    print('\n--- 側ツマセクション ---');
    print('外板: ${_sideBoardThicknessController.text}mm');
    print('上かまち: 幅 ${_upperKamachiWidthController.text}x厚さ ${_upperKamachiThicknessController.text}');
    print('下かまち: 幅 ${_lowerKamachiWidthController.text}x厚さ ${_lowerKamachiThicknessController.text}');
    print('支柱: 幅 ${_pillarWidthController.text}x厚さ ${_pillarThicknessController.text}');
    print('はり受: 幅 ${_beamReceiverWidthController.text}x厚さ ${_beamReceiverThicknessController.text}・埋める: ${_beamReceiverEmbed ? '有' : '無'}');
    print('そえ柱: 幅 ${_bracePillarWidthController.text}x厚さ ${_bracePillarThicknessController.text}・両端短め: ${_bracePillarShortEnds ? '有' : '無'}');
    print('側図面データ (${_gawaPaths.length} segments)'); // ★パスの変数名に合わせて修正
    print('妻図面データ (${_tsumaPaths.length} segments)'); // ★パスの変数名に合わせて修正

    print('\n--- 天井セクション ---');
    print('天井上板: ${_ceilingUpperBoardThicknessController.text}mm');
    print('天井下板: ${_ceilingLowerBoardThicknessController.text}mm');

    print('\n--- 梱包材セクション ---');
    print('押さえ材: 長 ${_pressingMaterialLengthController.text}x幅 ${_pressingMaterialWidthController.text}x厚 ${_pressingMaterialThicknessController.text}・本数 ${_pressingMaterialQuantityController.text}・盛り材: ${_pressingMaterialHasMolding ? '有' : '無'}');
    print('トップ材: 長 ${_topMaterialLengthController.text}x幅 ${_topMaterialWidthController.text}x厚 ${_topMaterialThicknessController.text}・本数 ${_topMaterialQuantityController.text}');

    print('\n--- 追加部材セクション ---');
    for (int i = 0; i < 5; i++) {
      if (_additionalPartNameControllers[i].text.isNotEmpty) {
        print('部材${i + 1}: ${_additionalPartNameControllers[i].text} - 長 ${_additionalPartLengthControllers[i].text}x幅 ${_additionalPartWidthControllers[i].text}x厚 ${_additionalPartThicknessControllers[i].text}・本数 ${_additionalPartQuantityControllers[i].text}');
      }
    }
  }
}