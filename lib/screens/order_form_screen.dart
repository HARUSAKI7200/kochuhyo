import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kouchuhyo_app/widgets/drawing_canvas.dart';
import 'package:kouchuhyo_app/screens/drawing_screen.dart';
import 'dart:math';
import 'package:kouchuhyo_app/screens/print_preview_screen.dart';

// ★★★ 乾燥剤関連の項目を追加 ★★★
class KochuhyoData {
  // 基本情報
  final String shippingDate, issueDate, serialNumber, kobango, shihomeisaki, hinmei, weight, quantity;
  final String shippingType, packingForm, formType;
  final String desiccantPeriod, desiccantCoefficientValue, desiccantAmount; // 乾燥剤の期間、選択された係数の値、計算結果
  // 寸法
  final String innerLength, innerWidth, innerHeight;
  final String outerLength, outerWidth, outerHeight, packagingVolume;
  // 腰下
  final String skid, h, hFixingMethod, suriGetaType, suriGeta, getaQuantity, floorBoard;
  // 荷重計算
  final String loadBearingMaterial, allowableLoadUniform, loadCalculationMethod, twoPointLoadDetails, finalAllowableLoad;
  // 根止め (5行分)
  final List<String> rootStops;
  // 側・妻
  final String sideBoard, kamachiType, upperKamachi, lowerKamachi, pillar;
  final String beamReceiver, bracePillar;
  final bool beamReceiverEmbed, bracePillarShortEnds;
  // 天井
  final String ceilingUpperBoard, ceilingLowerBoard;
  // 梱包材
  final String hari, pressingMaterial, topMaterial;
  final bool pressingMaterialHasMolding;
  // 追加部材 (5行分)
  final List<Map<String, String>> additionalParts;
  // 図面
  final Uint8List? koshitaImageBytes;
  final Uint8List? gawaTsumaImageBytes;

  KochuhyoData({
    required this.shippingDate, required this.issueDate, required this.serialNumber, required this.kobango,
    required this.shihomeisaki, required this.hinmei, required this.weight, required this.quantity,
    required this.shippingType, required this.packingForm, required this.formType,
    required this.desiccantPeriod, required this.desiccantCoefficientValue, required this.desiccantAmount, // ★乾燥剤
    required this.innerLength, required this.innerWidth, required this.innerHeight,
    required this.outerLength, required this.outerWidth, required this.outerHeight, required this.packagingVolume,
    required this.skid, required this.h, required this.hFixingMethod, required this.suriGetaType,
    required this.suriGeta, required this.getaQuantity, required this.floorBoard,
    required this.loadBearingMaterial, required this.allowableLoadUniform, required this.loadCalculationMethod,
    required this.twoPointLoadDetails, required this.finalAllowableLoad, required this.rootStops,
    required this.sideBoard, required this.kamachiType, required this.upperKamachi, required this.lowerKamachi,
    required this.pillar, required this.beamReceiver, required this.bracePillar,
    required this.beamReceiverEmbed, required this.bracePillarShortEnds,
    required this.ceilingUpperBoard, required this.ceilingLowerBoard,
    required this.hari, required this.pressingMaterial, required this.topMaterial,
    required this.pressingMaterialHasMolding, required this.additionalParts,
    this.koshitaImageBytes, this.gawaTsumaImageBytes,
  });
}


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

  // ★★★ 乾燥剤関連のコントローラーと変数を追加 ★★★
  final TextEditingController _desiccantPeriodController = TextEditingController();
  final TextEditingController _desiccantResultDisplayController = TextEditingController();
  double? _selectedDesiccantCoefficient; // 係数の選択値を保持
  final Map<String, double> _desiccantCoefficients = { // 係数の選択肢
    '0.12 (地域Aなど)': 0.12,
    '0.048 (地域Bなど)': 0.048,
    '0.026 (地域Cなど)': 0.026,
    '0.013 (地域Dなど)': 0.013,
  };
  // ドロップダウン用のFocusNode
  final FocusNode _desiccantCoefficientFocusNode = FocusNode();


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

  // (他のコントローラーは変更なし)
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
  double _wUniform = 0.0;
  final TextEditingController _allowableLoadUniformDisplayController = TextEditingController();
  final TextEditingController _l_A_Controller = TextEditingController();
  final TextEditingController _l0Controller = TextEditingController();
  final TextEditingController _l_B_Controller = TextEditingController();
  final TextEditingController _l1Controller = TextEditingController();
  final TextEditingController _l2Controller = TextEditingController();
  final TextEditingController _multiplierDisplayController = TextEditingController();
  final TextEditingController _allowableLoadFinalDisplayController = TextEditingController();
  final List<TextEditingController> _rootStopLengthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopWidthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopThicknessControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _rootStopQuantityControllers = List.generate(5, (_) => TextEditingController());
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
  final TextEditingController _ceilingUpperBoardThicknessController = TextEditingController();
  final TextEditingController _ceilingLowerBoardThicknessController = TextEditingController();
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
  final List<TextEditingController> _additionalPartNameControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _additionalPartLengthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _additionalPartWidthControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _additionalPartThicknessControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _additionalPartQuantityControllers = List.generate(5, (_) => TextEditingController());

  List<PathSegment> _koshitaPaths = [];
  List<PathSegment> _gawaTsumaPaths = [];
  Uint8List? _koshitaImageBytes;
  Uint8List? _gawaTsumaImageBytes;

  @override
  void initState() {
    super.initState();
    _selectedSuriGetaType = 'すり材';
    _issueDateController.text = DateFormat('yyyy/MM/dd').format(DateTime.now());

    final desiccantListeners = [
      _innerLengthController, _innerWidthController, _innerHeightController,
      _desiccantPeriodController,
    ];
    for (var controller in desiccantListeners) {
      controller.addListener(_calculateDesiccant);
    }

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
    final allControllersWithKeys = {
      'shippingDate': _shippingDateController, 'issueDate': _issueDateController, 'serialNumber': _serialNumberController,
      'kobango': _kobangoController, 'shihomeisaki': _shihomeisakiController, 'hinmei': _hinmeiController,
      'weight': _weightController, 'quantity': _quantityController,
      // ★★★ 乾燥剤の期間コントローラーをFocusNode管理に追加 ★★★
      'desiccantPeriod': _desiccantPeriodController,
      // ドロップダウンは直接TextFieldではないため、FocusNodeでの制御は少し異なります。
      // ドロップダウンの後ろのフィールドに遷移するようにします。
      'innerLength': _innerLengthController, 'innerWidth': _innerWidthController, 'innerHeight': _innerHeightController,
      'skidWidth': _skidWidthController, 'skidThickness': _skidThicknessController, 'skidQuantity': _skidQuantityController,
      'hWidth': _hWidthController, 'hThickness': _hThicknessController,
      'suriGetaWidth': _suriGetaWidthController, 'suriGetaThickness': _suriGetaThicknessController, 'getaQuantity': _getaQuantityController,
      'floorBoardThickness': _floorBoardThicknessController,
      'loadBearingMaterialWidth': _loadBearingMaterialWidthController, 'loadBearingMaterialThickness': _loadBearingMaterialThicknessController,
      'loadBearingMaterialQuantity': _loadBearingMaterialQuantityController,
      'l_A': _l_A_Controller, 'l0': _l0Controller, 'l_B': _l_B_Controller, 'l1': _l1Controller, 'l2': _l2Controller,
      'sideBoardThickness': _sideBoardThicknessController,
      'upperKamachiWidth': _upperKamachiWidthController, 'upperKamachiThickness': _upperKamachiThicknessController,
      'lowerKamachiWidth': _lowerKamachiWidthController, 'lowerKamachiThickness': _lowerKamachiThicknessController,
      'pillarWidth': _pillarWidthController, 'pillarThickness': _pillarThicknessController,
      'beamReceiverWidth': _beamReceiverWidthController, 'beamReceiverThickness': _beamReceiverThicknessController,
      'bracePillarWidth': _bracePillarWidthController, 'bracePillarThickness': _bracePillarThicknessController,
      'ceilingUpperBoardThickness': _ceilingUpperBoardThicknessController, 'ceilingLowerBoardThickness': _ceilingLowerBoardThicknessController,
      'hariWidth': _hariWidthController, 'hariThickness': _hariThicknessController, 'hariQuantity': _hariQuantityController,
      'pressingMaterialLength': _pressingMaterialLengthController, 'pressingMaterialWidth': _pressingMaterialWidthController,
      'pressingMaterialThickness': _pressingMaterialThicknessController, 'pressingMaterialQuantity': _pressingMaterialQuantityController,
      'topMaterialLength': _topMaterialLengthController, 'topMaterialWidth': _topMaterialWidthController,
      'topMaterialThickness': _topMaterialThicknessController, 'topMaterialQuantity': _topMaterialQuantityController,
    };

    allControllersWithKeys.forEach((key, controller) {
      _focusNodes[key] = FocusNode();
    });

    // 根止めと追加部材のFocusNodeも初期化
    for (int i = 0; i < 5; i++) {
      _focusNodes['rootStopLength_$i'] = FocusNode();
      _focusNodes['rootStopWidth_$i'] = FocusNode();
      _focusNodes['rootStopThickness_$i'] = FocusNode();
      _focusNodes['rootStopQuantity_$i'] = FocusNode();
      _focusNodes['additionalPartName_$i'] = FocusNode();
      _focusNodes['additionalPartLength_$i'] = FocusNode();
      _focusNodes['additionalPartWidth_$i'] = FocusNode();
      _focusNodes['additionalPartThickness_$i'] = FocusNode();
      _focusNodes['additionalPartQuantity_$i'] = FocusNode();
    }
    // 乾燥剤係数ドロップダウン用のFocusNode
    _focusNodes['desiccantCoefficient'] = _desiccantCoefficientFocusNode;
  }

  void _nextFocus(String currentKey) {
    // マッピングされたキーのリストを定義順に取得
    final orderedKeys = [
      'shippingDate', 'issueDate', 'serialNumber', 'kobango', 'shihomeisaki', 'hinmei', 'weight', 'quantity',
      'desiccantPeriod', 'desiccantCoefficient', // 乾燥剤の期間の次に係数ドロップダウン
      'innerLength', 'innerWidth', 'innerHeight', // ドロップダウンの次は内寸L
      'skidWidth', 'skidThickness', 'skidQuantity', 'hWidth', 'hThickness',
      'suriGetaWidth', 'suriGetaThickness', 'getaQuantity', 'floorBoardThickness',
      'loadBearingMaterialWidth', 'loadBearingMaterialThickness', 'loadBearingMaterialQuantity',
      'l_A', 'l0', 'l_B', 'l1', 'l2',
      // 根止め (動的に生成する)
      ...List.generate(5, (i) => ['rootStopLength_$i', 'rootStopWidth_$i', 'rootStopThickness_$i', 'rootStopQuantity_$i']).expand((x) => x),
      'sideBoardThickness', 'upperKamachiWidth', 'upperKamachiThickness', 'lowerKamachiWidth', 'lowerKamachiThickness',
      'pillarWidth', 'pillarThickness', 'beamReceiverWidth', 'beamReceiverThickness',
      'bracePillarWidth', 'bracePillarThickness', 'ceilingUpperBoardThickness', 'ceilingLowerBoardThickness',
      'hariWidth', 'hariThickness', 'hariQuantity',
      'pressingMaterialLength', 'pressingMaterialWidth', 'pressingMaterialThickness', 'pressingMaterialQuantity',
      'topMaterialLength', 'topMaterialWidth', 'topMaterialThickness', 'topMaterialQuantity',
      // 追加部材 (動的に生成する)
      ...List.generate(5, (i) => ['additionalPartName_$i', 'additionalPartLength_$i', 'additionalPartWidth_$i', 'additionalPartThickness_$i', 'additionalPartQuantity_$i']).expand((x) => x),
    ];

    final currentIndex = orderedKeys.indexOf(currentKey);
    if (currentIndex != -1 && currentIndex < orderedKeys.length - 1) {
      final nextKey = orderedKeys[currentIndex + 1];
      final nextNode = _focusNodes[nextKey];
      if (nextNode != null) {
        // ドロップダウンの場合、直接フォーカスはできないので、次のTextFieldにフォーカスを移すことを試みる
        if (nextKey == 'desiccantCoefficient') {
          FocusScope.of(context).requestFocus(_focusNodes['innerLength']); // 係数の次は内寸Lへ
        } else {
          FocusScope.of(context).requestFocus(nextNode);
        }
      }
    } else {
      FocusScope.of(context).unfocus(); // 最後のフィールドならフォーカスを外す
    }
  }

  // TextField用
  Widget _buildFocusableTextField(String key, {
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
      focusNode: _focusNodes[key],
      onSubmitted: (_) => _nextFocus(key),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        isDense: true,
      ),
    );
  }
  // 日付入力用
  Widget _buildFocusableDateTextField(String key, TextEditingController controller, Function(TextEditingController, String) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(controller, key), // タップ時に日付選択
      child: AbsorbPointer( // TextField自体はタップ不可にする
        child: TextField(
          controller: controller,
          readOnly: true,
          focusNode: _focusNodes[key],
          // onSubmittedは不要、タップで日付選択し、選択後にフォーカス移動
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'yyyy/MM/dd',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            isDense: true,
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _focusNodes.forEach((_, node) => node.dispose());
    _desiccantCoefficientFocusNode.dispose(); // ドロップダウン用も
    // (他のコントローラーのdispose処理は変更なし)
    final allControllers = [
      _shippingDateController, _issueDateController, _serialNumberController, _kobangoController,
      _shihomeisakiController, _hinmeiController, _weightController, _quantityController,
      _desiccantPeriodController, _desiccantResultDisplayController, // ★乾燥剤コントローラー
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
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller, String currentKey) async {
    DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => controller.text = DateFormat('yyyy/MM/dd').format(picked));
      _nextFocus(currentKey); // 日付選択後、次のフィールドへフォーカスを移す
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
    _calculateDesiccant(); // ★乾燥剤計算もトリガー
  }

  // ★★★ 乾燥剤の計算ロジックを追加 ★★★
  void _calculateDesiccant() {
    final length = double.tryParse(_innerLengthController.text) ?? 0.0;
    final width = double.tryParse(_innerWidthController.text) ?? 0.0;
    final height = double.tryParse(_innerHeightController.text) ?? 0.0;
    final period = double.tryParse(_desiccantPeriodController.text) ?? 0.0;
    final coefficient = _selectedDesiccantCoefficient ?? 0.0;

    if (length <= 0 || width <= 0 || height <= 0 || period <= 0 || coefficient <= 0) {
      _desiccantResultDisplayController.text = '';
      return;
    }

    // 表面積を計算 (mm^2からm^2に変換)
    final surfaceAreaMm2 = (2 * (length * width + length * height + width * height));
    final surfaceAreaM2 = surfaceAreaMm2 / (1000 * 1000);

    // 乾燥剤の量を計算
    final amount = surfaceAreaM2 * 0.15 * period * coefficient * 1.1;

    setState(() {
      _desiccantResultDisplayController.text = amount.toStringAsFixed(2);
    });
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

    if (l_A > 0 && l0 > 0) {
      multiplier = l_A / (4 * l0);
    } 
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

  void _navigateToPreviewScreen() {
    String twoPointLoadDetails = '';
    if (_loadCalculationMethod == '2点集中荷重') {
      if (_l_A_Controller.text.isNotEmpty) {
        twoPointLoadDetails = '均等(l=${_l_A_Controller.text}, l0=${_l0Controller.text})';
      } else if (_l_B_Controller.text.isNotEmpty) {
        twoPointLoadDetails = '不均等(l=${_l_B_Controller.text}, l1=${_l1Controller.text}, l2=${_l2Controller.text})';
      }
      twoPointLoadDetails += ' 倍率:${_multiplierDisplayController.text}';
    }

    final data = KochuhyoData(
      shippingDate: _shippingDateController.text,
      issueDate: _issueDateController.text,
      serialNumber: _serialNumberController.text,
      kobango: _kobangoController.text,
      shihomeisaki: _shihomeisakiController.text,
      hinmei: _hinmeiController.text,
      weight: _weightController.text,
      quantity: _quantityController.text,
      shippingType: _selectedShippingType ?? '未選択',
      packingForm: _selectedPackingForm ?? '未選択',
      formType: _selectedFormType ?? '未選択',
      // ★★★ 乾燥剤データを追加 ★★★
      desiccantPeriod: _desiccantPeriodController.text,
      desiccantCoefficientValue: _selectedDesiccantCoefficient?.toString() ?? '未選択',
      desiccantAmount: '${_desiccantResultDisplayController.text} kg',
      innerLength: _innerLengthController.text,
      innerWidth: _innerWidthController.text,
      innerHeight: _innerHeightController.text,
      outerLength: _outerLengthDisplayController.text,
      outerWidth: _outerWidthDisplayController.text,
      outerHeight: _outerHeightDisplayController.text,
      packagingVolume: _packagingVolumeDisplayController.text,
      skid: '${_skidWidthController.text}w x ${_skidThicknessController.text}t x ${_skidQuantityController.text}本',
      h: '${_hWidthController.text}w x ${_hThicknessController.text}t',
      hFixingMethod: _hFixingMethod ?? '未選択',
      suriGetaType: _selectedSuriGetaType ?? '未選択',
      suriGeta: '${_suriGetaWidthController.text}w x ${_suriGetaThicknessController.text}t',
      getaQuantity: _getaQuantityController.text,
      floorBoard: '${_floorBoardThicknessController.text}t',
      loadBearingMaterial: '${_loadBearingMaterialWidthController.text}w x ${_loadBearingMaterialThicknessController.text}t x ${_loadBearingMaterialQuantityController.text}本',
      allowableLoadUniform: _allowableLoadUniformDisplayController.text,
      loadCalculationMethod: _loadCalculationMethod ?? '未選択',
      twoPointLoadDetails: twoPointLoadDetails,
      finalAllowableLoad: _allowableLoadFinalDisplayController.text,
      rootStops: List.generate(5, (i) => 'L${_rootStopLengthControllers[i].text} x W${_rootStopWidthControllers[i].text} x T${_rootStopThicknessControllers[i].text}・${_rootStopQuantityControllers[i].text}本'),
      sideBoard: '${_sideBoardThicknessController.text}t',
      kamachiType: _selectedKamachiType ?? '未選択',
      upperKamachi: '${_upperKamachiWidthController.text}w x ${_upperKamachiThicknessController.text}t',
      lowerKamachi: '${_lowerKamachiWidthController.text}w x ${_lowerKamachiThicknessController.text}t',
      pillar: '${_pillarWidthController.text}w x ${_pillarThicknessController.text}t',
      beamReceiver: '${_beamReceiverWidthController.text}w x ${_beamReceiverThicknessController.text}t',
      beamReceiverEmbed: _beamReceiverEmbed,
      bracePillar: '${_bracePillarWidthController.text}w x ${_bracePillarThicknessController.text}t',
      bracePillarShortEnds: _bracePillarShortEnds,
      ceilingUpperBoard: '${_ceilingUpperBoardThicknessController.text}t',
      ceilingLowerBoard: '${_ceilingLowerBoardThicknessController.text}t',
      hari: '${_hariWidthController.text}w x ${_hariThicknessController.text}t x ${_hariQuantityController.text}本',
      pressingMaterial: 'L${_pressingMaterialLengthController.text} x W${_pressingMaterialWidthController.text} x T${_pressingMaterialThicknessController.text}・${_pressingMaterialQuantityController.text}本',
      pressingMaterialHasMolding: _pressingMaterialHasMolding,
      topMaterial: 'L${_topMaterialLengthController.text} x W${_topMaterialWidthController.text} x T${_topMaterialThicknessController.text}・${_topMaterialQuantityController.text}本',
      additionalParts: List.generate(5, (i) => {
        'name': _additionalPartNameControllers[i].text,
        'dims': 'L${_additionalPartLengthControllers[i].text} x W${_additionalPartWidthControllers[i].text} x T${_additionalPartThicknessControllers[i].text}・${_additionalPartQuantityControllers[i].text}本',
      }),
      koshitaImageBytes: _koshitaImageBytes,
      gawaTsumaImageBytes: _gawaTsumaImageBytes,
    );

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PrintPreviewScreen(data: data),
    ));
  }


  @override
  Widget build(BuildContext context) {
    // int focusIndex = 0; を削除 (未使用のため)
    // int getNextFocusIndex() => focusIndex++; を削除 (未使用のため)
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
                      child: _buildFocusableTextField('serialNumber', controller: _serialNumberController, hintText: 'A-100'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('基本情報セクション'),
            Row(
              children: [
                Expanded(child: _buildLabeledDateInput('出荷日', 'shippingDate', _shippingDateController, _selectDate)),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledDateInput('発行日', 'issueDate', _issueDateController, _selectDate)),
              ],
            ),
            _buildLabeledTextField('工番', 'kobango', _kobangoController),
            _buildLabeledTextField('仕向先', 'shihomeisaki', _shihomeisakiController),
            _buildLabeledTextField('品名', 'hinmei', _hinmeiController),
            _buildLabeledTextField('重量 (KG)', 'weight', _weightController, keyboardType: TextInputType.number),
            _buildLabeledTextField('数量 (C/S)', 'quantity', _quantityController, keyboardType: TextInputType.number),
            
            // ★★★ 乾燥剤UIを追加 ★★★
            _buildVerticalInputGroup(
              "乾燥剤 (kg)",
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildFocusableTextField(
                      'desiccantPeriod',
                      controller: _desiccantPeriodController,
                      hintText: '期間(ヶ月)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<double>(
                      value: _selectedDesiccantCoefficient,
                      isDense: true,
                      focusNode: _focusNodes['desiccantCoefficient'],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), //isDenseと合わせる
                        isDense: true,
                      ),
                      hint: const Text('係数'),
                      items: _desiccantCoefficients.entries.map((entry) {
                        return DropdownMenuItem<double>(
                          value: entry.value,
                          child: Text(entry.key, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDesiccantCoefficient = value;
                        });
                        _calculateDesiccant();
                        _nextFocus('desiccantCoefficient'); // ドロップダウン選択後にフォーカスを移す
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('=', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField( // 結果表示用なのでFocusableTextFieldは不要
                      controller: _desiccantResultDisplayController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: '計算結果',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              )
            ),

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
              'innerLength', _innerLengthController, '長',
              'innerWidth', _innerWidthController, '幅',
              'innerHeight', _innerHeightController, '高'
            ),
            const SizedBox(height: 16),
            _buildTripleInputRow('外寸 (mm)', // 外寸は読み取り専用なのでキー指定不要
              '', _outerLengthDisplayController, '長',
              '', _outerWidthDisplayController, '幅',
              '', _outerHeightDisplayController, '高',
              isReadOnly: true,
            ),
            const SizedBox(height: 16),
            _buildLabeledTextField('梱包明細: 容積 m3', 'packagingVolume',_packagingVolumeDisplayController, readOnly: true), // 読み取り専用

            _buildSectionTitle('腰下セクション'),
            
            _buildVerticalInputGroup(
              '滑材 (mm)',
              _buildTripleInputRowWithUnit(
                '',
                'skidWidth', _skidWidthController, '幅',
                'skidThickness', _skidThicknessController, '厚',
                'skidQuantity', _skidQuantityController, '本数',
                showTitle: false,
              ),
            ),
            
            _buildDimensionWithRadioInput('H (mm)',
              'hWidth', _hWidthController, '幅',
              'hThickness', _hThicknessController, '厚',
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
                      Expanded(child: _buildFocusableTextField('suriGetaWidth', controller: _suriGetaWidthController, keyboardType: TextInputType.number, hintText: '幅')),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
                      Expanded(child: _buildFocusableTextField('suriGetaThickness', controller: _suriGetaThicknessController, keyboardType: TextInputType.number, hintText: '厚さ')),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
                      Expanded(
                        child: _buildFocusableTextField(
                          'getaQuantity',
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
              _buildFocusableTextField('floorBoardThickness', controller: _floorBoardThicknessController, keyboardType: TextInputType.number),
            ),

            _buildVerticalInputGroup(
              '負荷床材',
               _buildTripleInputRowWithUnit('', 
                'loadBearingMaterialWidth', _loadBearingMaterialWidthController, '幅',
                'loadBearingMaterialThickness', _loadBearingMaterialThicknessController, '厚さ',
                'loadBearingMaterialQuantity', _loadBearingMaterialQuantityController, '本数',
                showTitle: false,
                isQuantityReadOnly: isUniformLoad || isTwoPointLoad,
              ),
            ),
            _buildVerticalInputGroup(
              '許容荷重W(kg/本)[等分布]',
              TextField( // 読み取り専用
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
                        Expanded(child: _buildVerticalInputGroup("l (cm)", _buildFocusableTextField('l_A', controller: _l_A_Controller, keyboardType: TextInputType.number))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildVerticalInputGroup("l0 (cm)", _buildFocusableTextField('l0', controller: _l0Controller, keyboardType: TextInputType.number))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('シナリオB: 不均等配置', style: TextStyle(fontWeight: FontWeight.bold)),
                     Row(
                      children: [
                        Expanded(child: _buildVerticalInputGroup("l (cm)", _buildFocusableTextField('l_B', controller: _l_B_Controller, keyboardType: TextInputType.number))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildVerticalInputGroup("l1 (cm)", _buildFocusableTextField('l1', controller: _l1Controller, keyboardType: TextInputType.number))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildVerticalInputGroup("l2 (cm)", _buildFocusableTextField('l2', controller: _l2Controller, keyboardType: TextInputType.number))),
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
                      'rootStopLength_$i', _rootStopLengthControllers[i], '長',
                      'rootStopWidth_$i', _rootStopWidthControllers[i], '幅',
                      'rootStopThickness_$i', _rootStopThicknessControllers[i], '厚',
                      'rootStopQuantity_$i', _rootStopQuantityControllers[i], '本数'
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
              _buildFocusableTextField('sideBoardThickness', controller: _sideBoardThicknessController, keyboardType: TextInputType.number),
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
              'upperKamachiWidth', _upperKamachiWidthController, '幅',
              'upperKamachiThickness', _upperKamachiThicknessController, '厚さ'
            ),
            _buildDoubleInputRow('下かまち',
              'lowerKamachiWidth', _lowerKamachiWidthController, '幅',
              'lowerKamachiThickness', _lowerKamachiThicknessController, '厚さ'
            ),
            _buildDoubleInputRow('支柱',
              'pillarWidth', _pillarWidthController, '幅',
              'pillarThickness', _pillarThicknessController, '厚さ'
            ),
            _buildDimensionWithCheckbox('はり受',
              'beamReceiverWidth', _beamReceiverWidthController, '幅',
              'beamReceiverThickness', _beamReceiverThicknessController, '厚さ',
              '埋める', _beamReceiverEmbed, (value) => setState(() => _beamReceiverEmbed = value!)
            ),
            _buildDimensionWithCheckbox('そえ柱',
              'bracePillarWidth', _bracePillarWidthController, '幅',
              'bracePillarThickness', _bracePillarThicknessController, '厚さ',
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
                    _buildFocusableTextField('ceilingUpperBoardThickness', controller: _ceilingUpperBoardThicknessController, keyboardType: TextInputType.number),
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVerticalInputGroup(
                    '下板 (mm)',
                     _buildFocusableTextField('ceilingLowerBoardThickness', controller: _ceilingLowerBoardThicknessController, keyboardType: TextInputType.number),
                  )
                ),
              ],
            ),

            _buildSectionTitle('梱包材セクション'),
            _buildVerticalInputGroup(
              'ハリ',
              _buildTripleInputRowWithUnit(
                '', 
                'hariWidth', _hariWidthController, '幅',
                'hariThickness', _hariThicknessController, '厚',
                'hariQuantity', _hariQuantityController, '本数',
                showTitle: false,
              ),
            ),
            _buildQuadInputRowWithTitle('押さえ材',
              'pressingMaterialLength', _pressingMaterialLengthController, '長',
              'pressingMaterialWidth', _pressingMaterialWidthController, '幅',
              'pressingMaterialThickness', _pressingMaterialThicknessController, '厚',
              'pressingMaterialQuantity', _pressingMaterialQuantityController, '本数'
            ),
            _buildCheckboxOption('盛り材が有', _pressingMaterialHasMolding, (value) => setState(() => _pressingMaterialHasMolding = value!)),
            _buildQuadInputRowWithTitle('トップ材',
              'topMaterialLength', _topMaterialLengthController, '長',
              'topMaterialWidth', _topMaterialWidthController, '幅',
              'topMaterialThickness', _topMaterialThicknessController, '厚',
              'topMaterialQuantity', _topMaterialQuantityController, '本数'
            ),
            
            _buildSectionTitle('追加部材セクション (5行)'),
            for (int i = 0; i < 5; i++)
              _buildAdditionalPartRow(i,
                'additionalPartName_$i', _additionalPartNameControllers[i],
                'additionalPartLength_$i', _additionalPartLengthControllers[i],
                'additionalPartWidth_$i', _additionalPartWidthControllers[i],
                'additionalPartThickness_$i', _additionalPartThicknessControllers[i],
                'additionalPartQuantity_$i', _additionalPartQuantityControllers[i]
              ),
            
            const SizedBox(height: 32),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveFormData,
                    child: const Text('入力内容を保存 (開発中)'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _navigateToPreviewScreen,
                    icon: const Icon(Icons.print),
                    label: const Text('印刷プレビュー'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 以下、UI構築用のヘルパーウィジェット群 (FocusNodeキー引数を追加) ---
  
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

  Widget _buildLabeledTextField(String label, String key, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: _buildFocusableTextField(key, controller: controller, keyboardType: keyboardType, readOnly: readOnly)),
        ],
      ),
    );
  }

  Widget _buildLabeledDateInput(String label, String key, TextEditingController controller, Function(TextEditingController, String) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(child: _buildFocusableDateTextField(key, controller, onSelect)),
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
    String key1, TextEditingController ctrl1, String hint1,
    String key2, TextEditingController ctrl2, String hint2,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: _buildFocusableTextField(key1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(key2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number)),
        ],
      ),
    );
  }
  
  Widget _buildTripleInputRow(String title,
    String key1, TextEditingController ctrl1, String hint1,
    String key2, TextEditingController ctrl2, String hint2,
    String key3, TextEditingController ctrl3, String hint3,
    {bool isReadOnly = false}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(child: _buildFocusableTextField(key1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number, readOnly: isReadOnly)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
            Expanded(child: _buildFocusableTextField(key2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number, readOnly: isReadOnly)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
            Expanded(child: _buildFocusableTextField(key3, controller: ctrl3, hintText: hint3, keyboardType: TextInputType.number, readOnly: isReadOnly)),
          ],
        ),
      ],
    );
  }

  Widget _buildTripleInputRowWithUnit(String title,
    String key1, TextEditingController ctrl1, String hint1,
    String key2, TextEditingController ctrl2, String hint2,
    String key3, TextEditingController ctrl3, String hint3,
    {String? unit, bool showTitle = true, bool isQuantityReadOnly = false}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (showTitle) SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (unit != null) Text(unit),
          if (showTitle) const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField(key1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(key2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
          Expanded(child: _buildFocusableTextField(key3, controller: ctrl3, hintText: hint3, keyboardType: TextInputType.number, readOnly: isQuantityReadOnly)),
        ],
      ),
    );
  }

  Widget _buildQuadInputRow(
    String key1, TextEditingController ctrl1, String hint1,
    String key2, TextEditingController ctrl2, String hint2,
    String key3, TextEditingController ctrl3, String hint3,
    String key4, TextEditingController ctrl4, String hint4,
  ) {
    return Row(
      children: [
        Expanded(child: _buildFocusableTextField(key1, controller: ctrl1, hintText: hint1, keyboardType: TextInputType.number)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
        Expanded(child: _buildFocusableTextField(key2, controller: ctrl2, hintText: hint2, keyboardType: TextInputType.number)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
        Expanded(child: _buildFocusableTextField(key3, controller: ctrl3, hintText: hint3, keyboardType: TextInputType.number)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
        Expanded(child: _buildFocusableTextField(key4, controller: ctrl4, hintText: hint4, keyboardType: TextInputType.number)),
      ],
    );
  }
  
  Widget _buildQuadInputRowWithTitle(String title,
    String key1, TextEditingController ctrl1, String hint1,
    String key2, TextEditingController ctrl2, String hint2,
    String key3, TextEditingController ctrl3, String hint3,
    String key4, TextEditingController ctrl4, String hint4,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          _buildQuadInputRow(key1, ctrl1, hint1, key2, ctrl2, hint2, key3, ctrl3, hint3, key4, ctrl4, hint4),
        ],
      ),
    );
  }


  Widget _buildDimensionWithRadioInput(
    String label,
    String key1, TextEditingController dim1Ctrl, String hint1,
    String key2, TextEditingController dim2Ctrl, String hint2,
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
              Expanded(child: _buildFocusableTextField(key1, controller: dim1Ctrl, hintText: hint1, keyboardType: TextInputType.number)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
              Expanded(child: _buildFocusableTextField(key2, controller: dim2Ctrl, hintText: hint2, keyboardType: TextInputType.number)),
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
    String key1, TextEditingController dim1Ctrl, String hint1,
    String key2, TextEditingController dim2Ctrl, String hint2,
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
              Expanded(child: _buildFocusableTextField(key1, controller: dim1Ctrl, hintText: hint1, keyboardType: TextInputType.number)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
              Expanded(child: _buildFocusableTextField(key2, controller: dim2Ctrl, hintText: hint2, keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              _buildCheckboxOption(checkboxLabel, checkboxValue, onChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalPartRow(int rowIndex,
    String nameKey, TextEditingController nameCtrl,
    String lenKey, TextEditingController lenCtrl,
    String widthKey, TextEditingController widthCtrl,
    String thicknessKey, TextEditingController thicknessCtrl,
    String quantityKey, TextEditingController quantityCtrl
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: _buildFocusableTextField(nameKey, controller: nameCtrl, hintText: '部材名')),
          const SizedBox(width: 8),
          Expanded(child: _buildFocusableTextField(lenKey, controller: lenCtrl, hintText: '長', keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(widthKey, controller: widthCtrl, hintText: '幅', keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('×')),
          Expanded(child: _buildFocusableTextField(thicknessKey, controller: thicknessCtrl, hintText: '厚', keyboardType: TextInputType.number)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Text('・')),
          Expanded(child: _buildFocusableTextField(quantityKey, controller: quantityCtrl, hintText: '本数', keyboardType: TextInputType.number)),
        ],
      ),
    );
  }

  void _saveFormData() {
    // This is a helper for debugging, no changes needed here.
    print('--- 工注票データ ---');
    // ここにすべてのコントローラーの値を集めて表示するロジックを追加できます
  }
}