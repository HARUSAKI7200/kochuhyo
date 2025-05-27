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
  // ★★★★★ 修正点5：形式を単一選択に変更 ★★★★★
  String? _selectedFormType;
  final List<String> _formTypeOptions = const [
    'わく組（合板）', '外さんわく組（合板）', '普通木箱（合板）', '腰下付（合板）', '腰下',
  ];

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

  // ★★★★★ 修正点1：根止めを5行に変更 ★★★★★
  final List<TextEditingController> _rootStopLengthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopWidthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopThicknessControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopQuantityControllers = List.generate(5, (_) => TextEditingController());


  // --- 側ツマセクションのコントローラー ---
  final TextEditingController _sideBoardThicknessController = TextEditingController();
  // ★★★★★ 修正点4：かまち自動入力機能用の状態変数 ★★★★★
  String? _selectedKamachiType;

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
  // ★★★★★ 修正点6：「ハリ」項目用のコントローラーを追加 ★★★★★
  final TextEditingController _hariWidthController = TextEditingController();
  final TextEditingController _hariThicknessController = TextEditingController();
  final TextEditingController _hariQuantityController = TextEditingController();

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
  List<PathSegment> _gawaTsumaPaths = [];
  Uint8List? _koshitaImageBytes;
  Uint8List? _gawaTsumaImageBytes;

  @override
  void initState() {
    super.initState();
    _selectedSuriGetaType = 'すり材'; // 初期選択
    _issueDateController.text = DateFormat('yyyy/MM/dd').format(DateTime.now());

    final listeners = [
      _innerLengthController, _innerWidthController, _innerHeightController,
      _skidThicknessController,
      _suriGetaThicknessController, _getaQuantityController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _floorBoardThicknessController,
      // ★★★★★ 修正点2：外寸計算のトリガーに上かまちの厚さを追加 ★★★★★
      _upperKamachiThicknessController,
    ];
    for (var controller in listeners) {
      controller.addListener(_calculateOuterDimensions);
    }
    _initFocusNodes();
  }

  // ★★★★★ 修正点8：フォーカス制御の対象を全コントローラーに拡大 ★★★★★
  void _initFocusNodes() {
    final allControllers = [
      _shippingDateController, _issueDateController, _serialNumberController, _kobangoController,
      _shihomeisakiController, _hinmeiController, _weightController, _quantityController,
      _innerLengthController, _innerWidthController, _innerHeightController,
      _skidWidthController, _skidThicknessController, _skidQuantityController,
      _hWidthController, _hThicknessController,
      _suriGetaWidthController, _suriGetaThicknessController, _getaQuantityController,
      _floorBoardThicknessController,
      _loadBearingMaterialWidthController, _loadBearingMaterialThicknessController, _loadBearingMaterialQuantityController,
      ..._rootStopLengthControllers, ..._rootStopWidthControllers, ..._rootStopThicknessControllers, ..._rootStopQuantityControllers,
      _sideBoardThicknessController, _upperKamachiWidthController, _upperKamachiThicknessController,
      _lowerKamachiWidthController, _lowerKamachiThicknessController,
      _pillarWidthController, _pillarThicknessController,
      _beamReceiverWidthController, _beamReceiverThicknessController,
      _bracePillarWidthController, _bracePillarThicknessController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _hariWidthController, _hariThicknessController, _hariQuantityController,
      _pressingMaterialLengthController, _pressingMaterialWidthController, _pressingMaterialThicknessController, _pressingMaterialQuantityController,
      _topMaterialLengthController, _topMaterialWidthController, _topMaterialThicknessController, _topMaterialQuantityController,
      ..._additionalPartNameControllers, ..._additionalPartLengthControllers,
      ..._additionalPartWidthControllers, ..._additionalPartThicknessControllers,
      ..._additionalPartQuantityControllers
    ];
    for (int i = 0; i < allControllers.length; i++) {
      // ゲタが選択されていない場合のゲタ本数コントローラーなど、非表示の可能性のあるものは除外
      if (allControllers[i] == _getaQuantityController && _selectedSuriGetaType != 'ゲタ') continue;
      _focusNodes['controller_$i'] = FocusNode();
    }
  }

  void _nextFocus(int currentIndex) {
    // 次のインデックスを探す
    int nextIndex = currentIndex + 1;
    while(_focusNodes.containsKey('controller_$nextIndex')) {
      final node = _focusNodes['controller_$nextIndex'];
      // 次のノードが表示されていてフォーカス可能か確認
      if (node != null && node.context != null) {
         FocusScope.of(context).requestFocus(node);
         return;
      }
      nextIndex++;
    }
    FocusScope.of(context).unfocus();
  }

  Widget _buildFocusableTextField(int index, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      focusNode: _focusNodes['controller_$index'],
      onSubmitted: (_) => _nextFocus(index),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        isDense: true,
      ),
    );
  }

  @override
  void dispose() {
    final listeners = [
      _innerLengthController, _innerWidthController, _innerHeightController,
      _skidThicknessController,
      _suriGetaThicknessController, _getaQuantityController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _floorBoardThicknessController,
      _upperKamachiThicknessController,
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
      ..._rootStopLengthControllers, ..._rootStopWidthControllers, ..._rootStopThicknessControllers, ..._rootStopQuantityControllers,
      _sideBoardThicknessController, _upperKamachiWidthController,
      _upperKamachiThicknessController, _lowerKamachiWidthController, _lowerKamachiThicknessController,
      _pillarWidthController, _pillarThicknessController, _beamReceiverWidthController,
      _beamReceiverThicknessController, _bracePillarWidthController, _bracePillarThicknessController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _hariWidthController, _hariThicknessController, _hariQuantityController,
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

  // ★★★★★ 修正点2：外寸の計算ロジックを変更 ★★★★★
  void _calculateOuterDimensions() {
    final innerLength = double.tryParse(_innerLengthController.text) ?? 0.0;
    final innerWidth = double.tryParse(_innerWidthController.text) ?? 0.0;
    final innerHeight = double.tryParse(_innerHeightController.text) ?? 0.0;
    
    final upperKamachiThickness = double.tryParse(_upperKamachiThicknessController.text) ?? 0.0;
    double horizontalAddition = 0.0;
    if (upperKamachiThickness == 25.0) {
      horizontalAddition = 80.0;
    } else if (upperKamachiThickness == 40.0) {
      horizontalAddition = 110.0;
    }

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

  // ★★★★★ 修正点4：かまち寸法を自動入力するメソッド ★★★★★
  void _updateKamachiDimensions(String? value) {
    setState(() {
      _selectedKamachiType = value;
      String width = '';
      String thickness = '';

      if (value == 'かまち25') {
        width = '85';
        thickness = '25';
      } else if (value == 'かまち40') {
        width = '85';
        thickness = '40';
      }
      
      _upperKamachiWidthController.text = width;
      _upperKamachiThicknessController.text = thickness;
      _lowerKamachiWidthController.text = width;
      _lowerKamachiThicknessController.text = thickness;
      _pillarWidthController.text = width;
      _pillarThicknessController.text = thickness;
    });
  }

  void _navigateToKoshitaDrawingScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrawingScreen(
          initialPaths: _koshitaPaths,
          backgroundImagePath: 'assets/koshita_base.jpg',
          title: '腰下ベース',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _koshitaPaths = result['paths'] as List<PathSegment>? ?? _koshitaPaths;
        _koshitaImageBytes = result['imageBytes'] as Uint8List?;
      });
    }
  }

  void _navigateToGawaTsumaDrawingScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrawingScreen(
          initialPaths: _gawaTsumaPaths,
          backgroundImagePath: 'assets/gawa_tsuma_base.jpg',
          title: '側・妻',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _gawaTsumaPaths = result['paths'] as List<PathSegment>? ?? _gawaTsumaPaths;
        _gawaTsumaImageBytes = result['imageBytes'] as Uint8List?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ★★★★★ 修正点8：フォーカスインデックスを慎重に割り当てる ★★★★★
    int focusIndex = 0;
    int getNextFocusIndex() => focusIndex++;

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
                      child: _buildFocusableTextField(getNextFocusIndex(), controller: _serialNumberController, hintText: 'A-100'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('基本情報セクション'),
            Row(
              children: [
                Expanded(child: _buildLabeledDateInput('出荷日', _shippingDateController, getNextFocusIndex(), _selectDate)),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledDateInput('発行日', _issueDateController, getNextFocusIndex(), _selectDate)),
              ],
            ),
            _buildLabeledTextField('工番', _kobangoController, getNextFocusIndex()),
            _buildLabeledTextField('仕向先', _shihomeisakiController, getNextFocusIndex()),
            _buildLabeledTextField('品名', _hinmeiController, getNextFocusIndex()),
            _buildLabeledTextField('重量 (KG)', _weightController, getNextFocusIndex(), keyboardType: TextInputType.number),
            _buildLabeledTextField('数量 (C/S)', _quantityController, getNextFocusIndex(), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            const Text('出荷形態', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [_buildRadioOption('国内', _selectedShippingType, (value) => setState(() => _selectedShippingType = value)), _buildRadioOption('輸出', _selectedShippingType, (value) => setState(() => _selectedShippingType = value))]),
            const SizedBox(height: 16),
            const Text('形式', style: TextStyle(fontWeight: FontWeight.bold)),
            // ★★★★★ 修正点5：チェックボックスをラジオボタンに変更 ★★★★★
            _buildFormTypeRadioButtons(),
            const SizedBox(height: 16),
            const Text('形状', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [_buildRadioOption('密閉', _selectedPackingForm, (value) => setState(() => _selectedPackingForm = value)), _buildRadioOption('すかし', _selectedPackingForm, (value) => setState(() => _selectedPackingForm = value))]),
            const SizedBox(height: 16),
            // ★★★★★ 修正点7：区切り文字の追加とラベルの修正 ★★★★★
            _buildTripleInputRow('内寸 (mm)',
              _innerLengthController, getNextFocusIndex(), '長',
              _innerWidthController, getNextFocusIndex(), '幅',
              _innerHeightController, getNextFocusIndex(), '高'
            ),
            const SizedBox(height: 16),
            _buildTripleInputRow('外寸 (mm)',
              _outerLengthDisplayController, -1, '長',
              _outerWidthDisplayController, -1, '幅',
              _outerHeightDisplayController, -1, '高',
              isReadOnly: true,
            ),
            const SizedBox(height: 16),
            _buildLabeledTextField('梱包明細: 容積 m3', _packagingVolumeDisplayController, getNextFocusIndex(), readOnly: true),

            _buildSectionTitle('腰下セクション'),
            _buildTripleInputRowWithUnit('滑材',
              _skidWidthController, getNextFocusIndex(), '幅',
              _skidThicknessController, getNextFocusIndex(), '厚',
              _skidQuantityController, getNextFocusIndex(), '本数',
              unit: '(mm)'
            ),
            _buildDimensionWithRadioInput('H (mm)',
              _hWidthController, getNextFocusIndex(), '幅',
              _hThicknessController, getNextFocusIndex(), '厚',
              '止め方', ['釘', 'ボルト'], _hFixingMethod, (value) => setState(() => _hFixingMethod = value)
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('すり材 or ゲタ', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [_buildRadioOption('すり材', _selectedSuriGetaType, (value) => setState(() { _selectedSuriGetaType = value; _calculateOuterDimensions(); })), _buildRadioOption('ゲタ', _selectedSuriGetaType, (value) => setState(() { _selectedSuriGetaType = value; _calculateOuterDimensions(); }))]),
                Row(
                  children: [
                    Expanded(child: _buildFocusableTextField(getNextFocusIndex(), controller: _suriGetaWidthController, keyboardType: TextInputType.number, hintText: '幅')),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
                    Expanded(child: _buildFocusableTextField(getNextFocusIndex(), controller: _suriGetaThicknessController, keyboardType: TextInputType.number, hintText: '厚さ')),
                    if (_selectedSuriGetaType == 'ゲタ') ...[
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
                      Expanded(child: _buildFocusableTextField(getNextFocusIndex(), controller: _getaQuantityController, keyboardType: TextInputType.number, hintText: '本数'))
                    ],
                  ],
                ),
              ],
            ),
            _buildLabeledTextField('床板 (mm)', _floorBoardThicknessController, getNextFocusIndex(), keyboardType: TextInputType.number),
            _buildTripleInputRowWithUnit('負荷床材',
              _loadBearingMaterialWidthController, getNextFocusIndex(), '幅',
              _loadBearingMaterialThicknessController, getNextFocusIndex(), '厚さ',
              _loadBearingMaterialQuantityController, getNextFocusIndex(), '本数'
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('計算方法', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [_buildRadioOption('等分布荷重', _loadCalculationMethod, (value) => setState(() => _loadCalculationMethod = value)), _buildRadioOption('中央集中荷重', _loadCalculationMethod, (value) => setState(() => _loadCalculationMethod = value)), _buildRadioOption('2点集中荷重', _loadCalculationMethod, (value) => setState(() => _loadCalculationMethod = value))]),
              ],
            ),
            // ★★★★★ 修正点1：根止めを5行表示に修正 ★★★★★
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('根止め', style: TextStyle(fontWeight: FontWeight.bold)),
                for (int i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: _buildQuadInputRow(
                      _rootStopLengthControllers[i], getNextFocusIndex(), '長',
                      _rootStopWidthControllers[i], getNextFocusIndex(), '幅',
                      _rootStopThicknessControllers[i], getNextFocusIndex(), '厚',
                      _rootStopQuantityControllers[i], getNextFocusIndex(), '本数'
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildDrawingPreview(
              title: '図面手書き入力 (腰下ベース)',
              onTap: _navigateToKoshitaDrawingScreen,
              imageBytes: _koshitaImageBytes,
              placeholder: 'タップして腰下ベースを描く',
            ),

            _buildSectionTitle('側ツマセクション'),
            _buildLabeledTextField('外板 (mm)', _sideBoardThicknessController, getNextFocusIndex(), keyboardType: TextInputType.number),
            // ★★★★★ 修正点4：かまち選択ラジオボタンを追加 ★★★★★
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('かまち種類', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    _buildRadioOption('かまち25', _selectedKamachiType, _updateKamachiDimensions),
                    _buildRadioOption('かまち40', _selectedKamachiType, _updateKamachiDimensions),
                  ],
                ),
              ],
            ),
            // ★★★★★ 修正点3：ラベルを「幅×厚さ」に変更 ★★★★★
            _buildDoubleInputRow('上かまち',
              _upperKamachiWidthController, getNextFocusIndex(), '幅',
              _upperKamachiThicknessController, getNextFocusIndex(), '厚さ'
            ),
            _buildDoubleInputRow('下かまち',
              _lowerKamachiWidthController, getNextFocusIndex(), '幅',
              _lowerKamachiThicknessController, getNextFocusIndex(), '厚さ'
            ),
            _buildDoubleInputRow('支柱',
              _pillarWidthController, getNextFocusIndex(), '幅',
              _pillarThicknessController, getNextFocusIndex(), '厚さ'
            ),
            _buildDimensionWithCheckbox('はり受',
              _beamReceiverWidthController, getNextFocusIndex(), '幅',
              _beamReceiverThicknessController, getNextFocusIndex(), '厚さ',
              '埋める', _beamReceiverEmbed, (value) => setState(() => _beamReceiverEmbed = value!)
            ),
            _buildDimensionWithCheckbox('そえ柱',
              _bracePillarWidthController, getNextFocusIndex(), '幅',
              _bracePillarThicknessController, getNextFocusIndex(), '厚さ',
              '両端短め', _bracePillarShortEnds, (value) => setState(() => _bracePillarShortEnds = value!)
            ),
            
            const SizedBox(height: 16),
            _buildDrawingPreview(
              title: '図面手書き入力 (側・妻)',
              onTap: _navigateToGawaTsumaDrawingScreen,
              imageBytes: _gawaTsumaImageBytes,
              placeholder: 'タップして側・妻を描く',
            ),

            _buildSectionTitle('天井セクション'),
            Row(
              children: [
                Expanded(child: _buildLabeledTextField('上板 (mm)', _ceilingUpperBoardThicknessController, getNextFocusIndex(), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledTextField('下板 (mm)', _ceilingLowerBoardThicknessController, getNextFocusIndex(), keyboardType: TextInputType.number)),
              ],
            ),

            _buildSectionTitle('梱包材セクション'),
            // ★★★★★ 修正点6：「ハリ」項目を追加 ★★★★★
            _buildTripleInputRowWithUnit('ハリ',
              _hariWidthController, getNextFocusIndex(), '幅',
              _hariThicknessController, getNextFocusIndex(), '厚',
              _hariQuantityController, getNextFocusIndex(), '本数'
            ),
            _buildQuadInputRowWithTitle('押さえ材',
              _pressingMaterialLengthController, getNextFocusIndex(), '長',
              _pressingMaterialWidthController, getNextFocusIndex(), '幅',
              _pressingMaterialThicknessController, getNextFocusIndex(), '厚',
              _pressingMaterialQuantityController, getNextFocusIndex(), '本数'
            ),
            _buildCheckboxOption('盛り材が有', _pressingMaterialHasMolding, (value) => setState(() => _pressingMaterialHasMolding = value!)),
            _buildQuadInputRowWithTitle('トップ材',
              _topMaterialLengthController, getNextFocusIndex(), '長',
              _topMaterialWidthController, getNextFocusIndex(), '幅',
              _topMaterialThicknessController, getNextFocusIndex(), '厚',
              _topMaterialQuantityController, getNextFocusIndex(), '本数'
            ),
            
            _buildSectionTitle('追加部材セクション (5行)'),
            for (int i = 0; i < 5; i++)
              _buildAdditionalPartRow(i,
                _additionalPartNameControllers[i], getNextFocusIndex(),
                _additionalPartLengthControllers[i], getNextFocusIndex(),
                _additionalPartWidthControllers[i], getNextFocusIndex(),
                _additionalPartThicknessControllers[i], getNextFocusIndex(),
                _additionalPartQuantityControllers[i], getNextFocusIndex()
              ),
            
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

  // --- 以下、UI構築用のヘルパーウィジェット群 ---

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
                      fit: BoxFit.contain,
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

  Widget _buildLabeledTextField(String label, TextEditingController controller, int index, {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: _buildFocusableTextField(index, controller: controller, keyboardType: keyboardType, readOnly: readOnly)),
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
            child: AbsorbPointer(child: _buildFocusableTextField(index, controller: controller, hintText: 'yyyy/MM/dd', readOnly: true)),
          )),
        ],
      ),
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

  // ★★★★★ 修正点5：形式選択をラジオボタンで生成するヘルパー ★★★★★
  Widget _buildFormTypeRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _formTypeOptions.map((key) {
        return SizedBox(
          height: 36,
          child: Row(
            children: [
              Radio<String>(
                value: key,
                groupValue: _selectedFormType,
                onChanged: (String? value) => setState(() => _selectedFormType = value),
                visualDensity: VisualDensity.compact,
              ),
              Text(key, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ★★★★★ 修正点7：新しいUIに対応した入力行ウィジェット群 ★★★★★

  Widget _buildDoubleInputRow(String title,
    TextEditingController ctrl1, int idx1, String hint1,
    TextEditingController ctrl2, int idx2, String hint2,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: _buildFocusableTextField(idx1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(idx2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number)),
        ],
      ),
    );
  }
  
  Widget _buildTripleInputRow(String title,
    TextEditingController ctrl1, int idx1, String hint1,
    TextEditingController ctrl2, int idx2, String hint2,
    TextEditingController ctrl3, int idx3, String hint3,
    {bool isReadOnly = false}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(child: _buildFocusableTextField(idx1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number, readOnly: isReadOnly)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
            Expanded(child: _buildFocusableTextField(idx2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number, readOnly: isReadOnly)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
            Expanded(child: _buildFocusableTextField(idx3, controller: ctrl3, hintText: hint3, keyboardType: TextInputType.number, readOnly: isReadOnly)),
          ],
        ),
      ],
    );
  }

  Widget _buildTripleInputRowWithUnit(String title,
    TextEditingController ctrl1, int idx1, String hint1,
    TextEditingController ctrl2, int idx2, String hint2,
    TextEditingController ctrl3, int idx3, String hint3,
    {String? unit}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (unit != null) Text(unit),
          const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField(idx1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(idx2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
          Expanded(child: _buildFocusableTextField(idx3, controller: ctrl3, hintText: hint3, keyboardType: TextInputType.number)),
        ],
      ),
    );
  }

  Widget _buildQuadInputRow(
    TextEditingController ctrl1, int idx1, String hint1,
    TextEditingController ctrl2, int idx2, String hint2,
    TextEditingController ctrl3, int idx3, String hint3,
    TextEditingController ctrl4, int idx4, String hint4,
  ) {
    return Row(
      children: [
        Expanded(child: _buildFocusableTextField(idx1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
        Expanded(child: _buildFocusableTextField(idx2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
        Expanded(child: _buildFocusableTextField(idx3, controller: ctrl3, hintText: hint3, keyboardType: TextInputType.number)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
        Expanded(child: _buildFocusableTextField(idx4, controller: ctrl4, hintText: hint4, keyboardType: TextInputType.number)),
      ],
    );
  }
  
  Widget _buildQuadInputRowWithTitle(String title,
    TextEditingController ctrl1, int idx1, String hint1,
    TextEditingController ctrl2, int idx2, String hint2,
    TextEditingController ctrl3, int idx3, String hint3,
    TextEditingController ctrl4, int idx4, String hint4,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          _buildQuadInputRow(ctrl1, idx1, hint1, ctrl2, idx2, hint2, ctrl3, idx3, hint3, ctrl4, idx4, hint4),
        ],
      ),
    );
  }


  Widget _buildDimensionWithRadioInput(
    String label,
    TextEditingController dim1Ctrl, int dim1Idx, String hint1,
    TextEditingController dim2Ctrl, int dim2Idx, String hint2,
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
              Expanded(child: _buildFocusableTextField(dim1Idx, controller: dim1Ctrl, hintText: hint1, keyboardType: TextInputType.number)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
              Expanded(child: _buildFocusableTextField(dim2Idx, controller: dim2Ctrl, hintText: hint2, keyboardType: TextInputType.number)),
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
    String label,
    TextEditingController dim1Ctrl, int dim1Idx, String hint1,
    TextEditingController dim2Ctrl, int dim2Idx, String hint2,
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
              Expanded(child: _buildFocusableTextField(dim1Idx, controller: dim1Ctrl, hintText: hint1, keyboardType: TextInputType.number)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
              Expanded(child: _buildFocusableTextField(dim2Idx, controller: dim2Ctrl, hintText: hint2, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              _buildCheckboxOption(checkboxLabel, checkboxValue, onChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalPartRow(int rowIndex,
    TextEditingController nameCtrl, int nameIdx,
    TextEditingController lenCtrl, int lenIdx,
    TextEditingController widthCtrl, int widthIdx,
    TextEditingController thicknessCtrl, int thicknessIdx,
    TextEditingController quantityCtrl, int quantityIdx
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: _buildFocusableTextField(nameIdx, controller: nameCtrl, hintText: '部材名')),
          const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField(lenIdx, controller: lenCtrl, hintText: '長', keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(widthIdx, controller: widthCtrl, hintText: '幅', keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(thicknessIdx, controller: thicknessCtrl, hintText: '厚', keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
          Expanded(child: _buildFocusableTextField(quantityIdx, controller: quantityCtrl, hintText: '本数', keyboardType: TextInputType.number)),
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
    print('形式: ${_selectedFormType ?? '未選択'}');
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
    for(int i = 0; i < 5; i++){
      if(_rootStopLengthControllers[i].text.isNotEmpty) {
        print('根止め${i+1}: 長 ${_rootStopLengthControllers[i].text}x幅 ${_rootStopWidthControllers[i].text}x厚 ${_rootStopThicknessControllers[i].text}・本数 ${_rootStopQuantityControllers[i].text}');
      }
    }
    print('腰下図面データ (${_koshitaPaths.length} segments)');

    print('\n--- 側ツマセクション ---');
    print('外板: ${_sideBoardThicknessController.text}mm');
    print('かまち種類: ${_selectedKamachiType ?? '未選択'}');
    print('上かまち: 幅 ${_upperKamachiWidthController.text}x厚さ ${_upperKamachiThicknessController.text}');
    print('下かまち: 幅 ${_lowerKamachiWidthController.text}x厚さ ${_lowerKamachiThicknessController.text}');
    print('支柱: 幅 ${_pillarWidthController.text}x厚さ ${_pillarThicknessController.text}');
    print('はり受: 幅 ${_beamReceiverWidthController.text}x厚さ ${_beamReceiverThicknessController.text}・埋める: ${_beamReceiverEmbed ? '有' : '無'}');
    print('そえ柱: 幅 ${_bracePillarWidthController.text}x厚さ ${_bracePillarThicknessController.text}・両端短め: ${_bracePillarShortEnds ? '有' : '無'}');
    print('側・妻図面データ (${_gawaTsumaPaths.length} segments)');

    print('\n--- 天井セクション ---');
    print('天井上板: ${_ceilingUpperBoardThicknessController.text}mm');
    print('天井下板: ${_ceilingLowerBoardThicknessController.text}mm');

    print('\n--- 梱包材セクション ---');
    print('ハリ: 幅 ${_hariWidthController.text}x厚 ${_hariThicknessController.text}・本数 ${_hariQuantityController.text}');
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