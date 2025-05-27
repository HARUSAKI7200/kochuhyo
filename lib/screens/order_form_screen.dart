import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kouchuhyo_app/widgets/drawing_canvas.dart';
import 'package:kouchuhyo_app/screens/drawing_screen.dart';
import 'dart:math';

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
  
  // ★★★★★ UI分離：State変数の修正と追加 ★★★★★
  String? _loadCalculationMethod;
  double _wUniform = 0.0;
  final TextEditingController _allowableLoadUniformDisplayController = TextEditingController();
  final TextEditingController _l_A_Controller = TextEditingController(); // シナリオA用 l
  final TextEditingController _l0Controller = TextEditingController();
  final TextEditingController _l_B_Controller = TextEditingController(); // シナリオB用 l
  final TextEditingController _l1Controller = TextEditingController();
  final TextEditingController _l2Controller = TextEditingController();
  final TextEditingController _multiplierDisplayController = TextEditingController();
  final TextEditingController _allowableLoadFinalDisplayController = TextEditingController();


  final List<TextEditingController> _rootStopLengthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopWidthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopThicknessControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopQuantityControllers = List.generate(5, (_) => TextEditingController());


  // --- 側ツマセクションのコントローラー ---
  final TextEditingController _sideBoardThicknessController = TextEditingController();
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
    _selectedSuriGetaType = 'すり材';
    _issueDateController.text = DateFormat('yyyy/MM/dd').format(DateTime.now());

    final outerDimListeners = [
      _innerLengthController, _innerWidthController, _innerHeightController,
      _skidThicknessController, _suriGetaThicknessController, _getaQuantityController,
      _ceilingUpperBoardThicknessController, _ceilingLowerBoardThicknessController,
      _floorBoardThicknessController, _upperKamachiThicknessController,
    ];
    for (var controller in outerDimListeners) {
      controller.addListener(_calculateOuterDimensions);
    }

    final loadBearingListeners = [
      _weightController, _innerLengthController, _innerWidthController, _skidWidthController,
      _loadBearingMaterialWidthController, _loadBearingMaterialThicknessController,
    ];
    for (var controller in loadBearingListeners) {
      controller.addListener(_triggerCalculations);
    }

    // ★★★★★ UI分離：リスナーの修正 ★★★★★
    _l_A_Controller.addListener(() {
      if (_l_A_Controller.text.isNotEmpty) _clearTwoPointInputs(scenario: 'B');
      _calculateTwoPointLoad();
    });
    _l0Controller.addListener(() {
      if (_l0Controller.text.isNotEmpty) _clearTwoPointInputs(scenario: 'B');
      _calculateTwoPointLoad();
    });
    _l_B_Controller.addListener(() {
      if (_l_B_Controller.text.isNotEmpty) _clearTwoPointInputs(scenario: 'A');
      _calculateTwoPointLoad();
    });
    _l1Controller.addListener(() {
      if (_l1Controller.text.isNotEmpty) _clearTwoPointInputs(scenario: 'A');
      _calculateTwoPointLoad();
    });
    _l2Controller.addListener(() {
      if (_l2Controller.text.isNotEmpty) _clearTwoPointInputs(scenario: 'A');
      _calculateTwoPointLoad();
    });
    
    _initFocusNodes();
  }

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
      _l_A_Controller, _l0Controller, _l_B_Controller, _l1Controller, _l2Controller,
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
      _focusNodes['controller_$i'] = FocusNode();
    }
  }

  void _nextFocus(int currentIndex) {
    int nextIndex = currentIndex + 1;
    while(_focusNodes.containsKey('controller_$nextIndex')) {
      final node = _focusNodes['controller_$nextIndex'];
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
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enabled: enabled,
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
      _allowableLoadUniformDisplayController, _l_A_Controller, _l0Controller, _l_B_Controller, _l1Controller, _l2Controller,
      _multiplierDisplayController, _allowableLoadFinalDisplayController,
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
    if (_selectedSuriGetaType == 'すり材' || _selectedSuriGetaType == 'ゲタ') {
        suriGetaOrGetaThickness = double.tryParse(_suriGetaThicknessController.text) ?? 0.0;
    }
    final skidThickness = double.tryParse(_skidThicknessController.text) ?? 0.0;
    final ceilingUpperBoardThickness = double.tryParse(_ceilingUpperBoardThicknessController.text) ?? 0.0;
    final ceilingLowerBoardThickness = double.tryParse(_ceilingLowerBoardThicknessController.text) ?? 0.0;
    
    final outerLength = innerLength + horizontalAddition;
    final outerWidth = innerWidth + horizontalAddition;
    final outerHeight = innerHeight + suriGetaOrGetaThickness + skidThickness + ceilingUpperBoardThickness + ceilingLowerBoardThickness + 10.0;

    final roundedOuterHeight = (outerHeight / 10).ceil() * 10.0;
    
    setState(() {
      _outerLengthDisplayController.text = outerLength.toStringAsFixed(0);
      _outerWidthDisplayController.text = outerWidth.toStringAsFixed(0);
      _outerHeightDisplayController.text = roundedOuterHeight.toStringAsFixed(0);
      final volume = (outerLength / 1000.0) * (outerWidth / 1000.0) * (roundedOuterHeight / 1000.0);
      _packagingVolumeDisplayController.text = volume.toStringAsFixed(3);
    });
  }

  void _triggerCalculations() {
    _calculateUniformLoad();
    _calculateTwoPointLoad();
  }

  void _calculateUniformLoad() {
    final innerWidthMm = double.tryParse(_innerWidthController.text) ?? 0.0;
    final skidWidthMm = double.tryParse(_skidWidthController.text) ?? 0.0;
    final bMm = double.tryParse(_loadBearingMaterialWidthController.text) ?? 0.0;
    final hMm = double.tryParse(_loadBearingMaterialThicknessController.text) ?? 0.0;

    double lCm = 0.0;
    if (_selectedFormType == '腰下付（合板）') {
      lCm = (innerWidthMm - (skidWidthMm * 2)) / 10.0;
    } else if (_selectedFormType?.contains('わく組') ?? false) {
      if (_selectedKamachiType == 'かまち25') {
        if (skidWidthMm == 70.0) lCm = (innerWidthMm - 90.0) / 10.0;
        else if (skidWidthMm == 85.0) lCm = (innerWidthMm - 120.0) / 10.0;
      } else if (_selectedKamachiType == 'かまち40') {
        if (skidWidthMm == 85.0) lCm = (innerWidthMm - 90.0) / 10.0;
        else if (skidWidthMm == 100.0) lCm = (innerWidthMm - 120.0) / 10.0;
      }
    }

    if (lCm <= 0 || bMm <= 0 || hMm <= 0) {
      setState(() {
        _wUniform = 0;
        _allowableLoadUniformDisplayController.text = '計算不可';
        if (_loadCalculationMethod == '等分布荷重') {
            _loadBearingMaterialQuantityController.text = '';
        }
      });
      return;
    }

    final bCm = bMm / 10.0;
    final hCm = hMm / 10.0;
    const fb = 107;
    final wKg = (4 * bCm * (hCm * hCm) * fb) / (3 * lCm);

    setState(() {
      _wUniform = wKg;
      _allowableLoadUniformDisplayController.text = _wUniform.toStringAsFixed(1);
      
      if (_loadCalculationMethod == '等分布荷重') {
        final totalWeight = double.tryParse(_weightController.text) ?? 0.0;
        int quantity = 0;
        if (_wUniform > 0 && totalWeight > 0) {
          quantity = (totalWeight / _wUniform).ceil();
        }
        _loadBearingMaterialQuantityController.text = quantity.toString();
      }
    });
  }

  // ★★★★★ UI分離：入力クリア用ヘルパーメソッド ★★★★★
  void _clearTwoPointInputs({required String scenario}) {
    if (scenario == 'A') {
      _l_A_Controller.clear();
      _l0Controller.clear();
    } else if (scenario == 'B') {
      _l_B_Controller.clear();
      _l1Controller.clear();
      _l2Controller.clear();
    }
  }

  // ★★★★★ UI分離：計算ロジックの修正 ★★★★★
  void _calculateTwoPointLoad() {
    if (_loadCalculationMethod != '2点集中荷重') {
      setState(() {
        _multiplierDisplayController.text = '';
        _allowableLoadFinalDisplayController.text = '';
      });
      return;
    }
    
    final l_A = double.tryParse(_l_A_Controller.text) ?? 0.0;
    final l0 = double.tryParse(_l0Controller.text) ?? 0.0;
    final l_B = double.tryParse(_l_B_Controller.text) ?? 0.0;
    double l1 = double.tryParse(_l1Controller.text) ?? 0.0;
    double l2 = double.tryParse(_l2Controller.text) ?? 0.0;

    double multiplier = 0;

    // シナリオA：均等
    if (l_A > 0 && l0 > 0) {
      multiplier = l_A / (4 * l0);
    } 
    // シナリオB：不均等
    else if (l_B > 0 && (l1 > 0 || l2 > 0)) {
        if (l2 > l1) {
            final temp = l1;
            l1 = l2;
            l2 = temp;
        }
        final denominator = 4 * (l_B - l1 + l2) * l1;
        if (denominator > 0) {
            multiplier = (l_B * l_B) / denominator;
        }
    }

    if (multiplier <= 0) {
      setState(() {
        _multiplierDisplayController.text = '計算不可';
        _allowableLoadFinalDisplayController.text = '';
        _loadBearingMaterialQuantityController.text = '';
      });
      return;
    }

    if (multiplier > 2.0) {
      multiplier = 2.0;
    }

    final wFinal = _wUniform * multiplier;
    final totalWeight = double.tryParse(_weightController.text) ?? 0.0;
    int quantity = 0;
    if (wFinal > 0 && totalWeight > 0) {
      quantity = (totalWeight / wFinal).ceil();
    }
    
    setState(() {
      _multiplierDisplayController.text = multiplier.toStringAsFixed(2);
      _allowableLoadFinalDisplayController.text = wFinal.toStringAsFixed(1);
      _loadBearingMaterialQuantityController.text = quantity.toString();
    });
  }


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
    _triggerCalculations();
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
    int focusIndex = 0;
    int getNextFocusIndex() => focusIndex++;
    bool isUniformLoad = _loadCalculationMethod == '等分布荷重';
    bool isTwoPointLoad = _loadCalculationMethod == '2点集中荷重';

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
            _buildFormTypeRadioButtons(),
            const SizedBox(height: 16),
            const Text('形状', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [_buildRadioOption('密閉', _selectedPackingForm, (value) => setState(() => _selectedPackingForm = value)), _buildRadioOption('すかし', _selectedPackingForm, (value) => setState(() => _selectedPackingForm = value))]),
            const SizedBox(height: 16),
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
            
            _buildVerticalInputGroup(
              '滑材 (mm)',
              _buildTripleInputRowWithUnit(
                '',
                _skidWidthController, getNextFocusIndex(), '幅',
                _skidThicknessController, getNextFocusIndex(), '厚',
                _skidQuantityController, getNextFocusIndex(), '本数',
                showTitle: false,
              ),
            ),
            
            _buildDimensionWithRadioInput('H (mm)',
              _hWidthController, getNextFocusIndex(), '幅',
              _hThicknessController, getNextFocusIndex(), '厚',
              '止め方', ['釘', 'ボルト'], _hFixingMethod, (value) => setState(() => _hFixingMethod = value)
            ),
            
            _buildVerticalInputGroup(
              'すり材 or ゲタ',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildRadioOption('すり材', _selectedSuriGetaType, (value) => setState(() { _selectedSuriGetaType = value; _calculateOuterDimensions(); })),
                      _buildRadioOption('ゲタ', _selectedSuriGetaType, (value) => setState(() { _selectedSuriGetaType = value; _calculateOuterDimensions(); }))
                    ]
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildFocusableTextField(getNextFocusIndex(), controller: _suriGetaWidthController, keyboardType: TextInputType.number, hintText: '幅')),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
                      Expanded(child: _buildFocusableTextField(getNextFocusIndex(), controller: _suriGetaThicknessController, keyboardType: TextInputType.number, hintText: '厚さ')),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
                      Expanded(
                        child: _buildFocusableTextField(
                          getNextFocusIndex(),
                          controller: _getaQuantityController,
                          keyboardType: TextInputType.number,
                          hintText: '本数',
                          enabled: _selectedSuriGetaType == 'ゲタ',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            _buildVerticalInputGroup(
              '床板 (mm)',
              _buildFocusableTextField(getNextFocusIndex(), controller: _floorBoardThicknessController, keyboardType: TextInputType.number),
            ),

            _buildVerticalInputGroup(
              '負荷床材',
               _buildTripleInputRowWithUnit('', 
                _loadBearingMaterialWidthController, getNextFocusIndex(), '幅',
                _loadBearingMaterialThicknessController, getNextFocusIndex(), '厚さ',
                _loadBearingMaterialQuantityController, getNextFocusIndex(), '本数',
                showTitle: false,
                isQuantityReadOnly: isUniformLoad || isTwoPointLoad,
              ),
            ),
            _buildVerticalInputGroup(
              '許容荷重W(kg/本)[等分布]',
              TextField(
                controller: _allowableLoadUniformDisplayController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  isDense: true,
                ),
              ),
            ),
              
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('計算方法', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [
                  _buildRadioOption('等分布荷重', _loadCalculationMethod, (value) { setState(() => _loadCalculationMethod = value); _triggerCalculations(); }),
                  _buildRadioOption('中央集中荷重', _loadCalculationMethod, (value) => setState(() => _loadCalculationMethod = value)),
                  _buildRadioOption('2点集中荷重', _loadCalculationMethod, (value) { setState(() => _loadCalculationMethod = value); _triggerCalculations(); })
                ]),
              ],
            ),
            
            // ★★★★★ UI分離：2点集中荷重のUI修正 ★★★★★
            if (isTwoPointLoad)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4.0)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2点集中荷重 詳細入力', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    const SizedBox(height: 12),
                    Text('シナリオA: 均等配置', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(child: _buildVerticalInputGroup("l (cm)", _buildFocusableTextField(getNextFocusIndex(), controller: _l_A_Controller, keyboardType: TextInputType.number))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildVerticalInputGroup("l0 (cm)", _buildFocusableTextField(getNextFocusIndex(), controller: _l0Controller, keyboardType: TextInputType.number))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('シナリオB: 不均等配置', style: TextStyle(fontWeight: FontWeight.bold)),
                     Row(
                      children: [
                        Expanded(child: _buildVerticalInputGroup("l (cm)", _buildFocusableTextField(getNextFocusIndex(), controller: _l_B_Controller, keyboardType: TextInputType.number))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildVerticalInputGroup("l1 (cm)", _buildFocusableTextField(getNextFocusIndex(), controller: _l1Controller, keyboardType: TextInputType.number))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildVerticalInputGroup("l2 (cm)", _buildFocusableTextField(getNextFocusIndex(), controller: _l2Controller, keyboardType: TextInputType.number))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                     _buildVerticalInputGroup(
                      '倍率',
                       TextField(controller: _multiplierDisplayController, readOnly: true, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),)),
                    ),
                    _buildVerticalInputGroup(
                      '最終許容荷重(kg/本)',
                       TextField(controller: _allowableLoadFinalDisplayController, readOnly: true, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),)),
                    ),
                  ],
                ),
              ),

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

            _buildVerticalInputGroup(
              '外板 (mm)',
              _buildFocusableTextField(getNextFocusIndex(), controller: _sideBoardThicknessController, keyboardType: TextInputType.number),
            ),
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
                Expanded(
                  child: _buildVerticalInputGroup(
                    '上板 (mm)',
                    _buildFocusableTextField(getNextFocusIndex(), controller: _ceilingUpperBoardThicknessController, keyboardType: TextInputType.number),
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVerticalInputGroup(
                    '下板 (mm)',
                     _buildFocusableTextField(getNextFocusIndex(), controller: _ceilingLowerBoardThicknessController, keyboardType: TextInputType.number),
                  )
                ),
              ],
            ),

            _buildSectionTitle('梱包材セクション'),
            _buildVerticalInputGroup(
              'ハリ',
              _buildTripleInputRowWithUnit(
                '', 
                _hariWidthController, getNextFocusIndex(), '幅',
                _hariThicknessController, getNextFocusIndex(), '厚',
                _hariQuantityController, getNextFocusIndex(), '本数',
                showTitle: false,
              ),
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
  
  Widget _buildVerticalInputGroup(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          child,
        ],
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
                onChanged: (String? value) {
                  setState(() => _selectedFormType = value);
                  _triggerCalculations();
                },
                visualDensity: VisualDensity.compact,
              ),
              Text(key, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
    );
  }


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
    {String? unit, bool showTitle = true, bool isQuantityReadOnly = false}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (showTitle) SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (unit != null) Text(unit),
          if (showTitle) const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField(idx1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(idx2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
          Expanded(child: _buildFocusableTextField(idx3, controller: ctrl3, hintText: hint3, keyboardType: TextInputType.number, readOnly: isQuantityReadOnly)),
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
    if (_loadCalculationMethod == '等分布荷重' || _loadCalculationMethod == '2点集中荷重') {
      print('許容荷重W (等分布): ${_allowableLoadUniformDisplayController.text} kg/本');
    }
    if (_loadCalculationMethod == '2点集中荷重') {
      print('2点集中荷重 倍率: ${_multiplierDisplayController.text}');
      print('最終許容荷重: ${_allowableLoadFinalDisplayController.text} kg/本');
    }
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