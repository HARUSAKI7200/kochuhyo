// lib/pages/kouchuhyo_input_page.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/pages/input_sections/koshita_section.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/pages/input_sections/gawa_tsuma_section.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/pages/input_sections/konpouzai_section.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/pages/input_sections/tenjo_section.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/pages/input_sections/tsuikabuzai_section.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/pages/input_sections/kouchuhyo_basic_info_section.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/pages/kouchuhyo_preview_page.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/utils/template_storage.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/models/kouchuhyo_input_model.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/models/kouchuhyo_template.dart'; // kouchuhyo_app に戻す


class KouchuhyoInputPage extends StatefulWidget {
  final Map<String, dynamic>? preloadValues;
  const KouchuhyoInputPage({Key? key, this.preloadValues}) : super(key: key);

  @override
  State<KouchuhyoInputPage> createState() => _KouchuhyoInputPageState();
}

class _KouchuhyoInputPageState extends State<KouchuhyoInputPage> {
  late KouchuhyoInputModel _model;
  Uint8List? _koshitaSketchImage;
  Uint8List? _sokotsumaSketchImage;

  // TextEditingControllerの定義
  // 基本情報
  final _seiri = TextEditingController();
  final _shukkaDate = TextEditingController();
  final _date = TextEditingController();
  final _koban = TextEditingController();
  final _shimuke = TextEditingController();
  final _hinmei = TextEditingController();
  final _weight = TextEditingController();
  final _amount = TextEditingController();
  final _gel = TextEditingController();
  final _keishiki = TextEditingController();
  final _structure = TextEditingController();
  final _domestic = TextEditingController();
  final _uchiL = TextEditingController();
  final _uchiW = TextEditingController();
  final _uchiH = TextEditingController();
  final _sotoL = TextEditingController();
  final _sotoW = TextEditingController();
  final _sotoH = TextEditingController();

  // 腰下
  final _subeW = TextEditingController();
  final _subeT = TextEditingController();
  final _subeN = TextEditingController();
  final _headerW = TextEditingController();
  final _headerT = TextEditingController();
  final _headerStopCtr = TextEditingController();
  final _suriTypeCtr = TextEditingController();
  final _suriW = TextEditingController();
  final _suriT = TextEditingController();
  final _suriN = TextEditingController();
  final _yukaT = TextEditingController();
  final _fukaW = TextEditingController();
  final _fukaT = TextEditingController();
  final _fukaN = TextEditingController();
  final _nedomL = List<TextEditingController>.generate(4, (_) => TextEditingController());
  final _nedomW = List<TextEditingController>.generate(4, (_) => TextEditingController());
  final _nedomT = List<TextEditingController>.generate(4, (_) => TextEditingController());
  final _nedomN = List<TextEditingController>.generate(4, (_) => TextEditingController());

  // 天井
  final _upperBoard = TextEditingController();
  final _lowerBoard = TextEditingController();

  // 側ツマ
  final _gOuterT = TextEditingController();
  final _ukamW = TextEditingController();
  final _ukamT = TextEditingController();
  final _sujiW = TextEditingController();
  final _sujiT = TextEditingController();
  final _shichuW = TextEditingController();
  final _shichuT = TextEditingController();
  final _dosanW = TextEditingController();
  final _dosanT = TextEditingController();
  final _dosanN = TextEditingController();
  final _tsumaW = TextEditingController();
  final _tsumaT = TextEditingController();
  final _hariukeW = TextEditingController();
  final _hariukeT = TextEditingController();
  final _hariukeEmbed = TextEditingController();
  final _soeW = TextEditingController();
  final _soeT = TextEditingController();

  // 梱包材
  final _konHariW = TextEditingController();
  final _konHariT = TextEditingController();
  final _konHariN = TextEditingController();
  final _konOsaeL = TextEditingController();
  final _konOsaeW = TextEditingController();
  final _konOsaeT = TextEditingController();
  final _konOsaeN = TextEditingController();
  final _konTopL = TextEditingController();
  final _konTopW = TextEditingController();
  final _konTopT = TextEditingController();
  final _konTopN = TextEditingController();

  // 追加部材
  final List<List<TextEditingController>> _tsuikaControllers =
      List.generate(5, (_) => List.generate(5, (_) => TextEditingController()));

  @override
  void initState() {
    super.initState();
    _model = widget.preloadValues != null
        ? KouchuhyoInputModel.fromMap(widget.preloadValues!)
        : KouchuhyoInputModel.empty();

    // コントローラに初期値を設定
    _seiri.text = _model.seiriBangou;
    _shukkaDate.text = _model.shukkaDate;
    _date.text = _model.hakkoubi;
    _koban.text = _model.koban;
    _shimuke.text = _model.shimuke;
    _hinmei.text = _model.hinmei;
    _weight.text = _model.weight;
    _amount.text = _model.amount;
    _gel.text = _model.gel;
    _keishiki.text = _model.keishiki;
    _structure.text = _model.structure;
    _domestic.text = _model.domestic;
    _uchiL.text = _model.uchinoriLength;
    _uchiW.text = _model.uchinoriWidth;
    _uchiH.text = _model.uchinoriHeight;
    _sotoL.text = _model.sotonoriLength;
    _sotoW.text = _model.sotonoriWidth;
    _sotoH.text = _model.sotonoriHeight;

    _subeW.text = _model.kSubeW;
    _subeT.text = _model.kSubeT;
    _subeN.text = _model.kSubeN;
    _headerW.text = _model.kHeaderW;
    _headerT.text = _model.kHeaderT;
    _headerStopCtr.text = _model.kHeaderStop;
    _suriTypeCtr.text = _model.kSuriType;
    _suriW.text = _model.kSuriW;
    _suriT.text = _model.kSuriT;
    _suriN.text = _model.kSuriN;
    _yukaT.text = _model.kYukaT;
    _fukaW.text = _model.kFukaW;
    _fukaT.text = _model.kFukaT;
    _fukaN.text = _model.kFukaN;
    for (int i = 0; i < 4; i++) {
      _nedomL[i].text = _model.kNedomL[i];
      _nedomW[i].text = _model.kNedomW[i];
      _nedomT[i].text = _model.kNedomT[i];
      _nedomN[i].text = _model.kNedomN[i];
    }
    _koshitaSketchImage = _model.koshitaSketchImageBytes;

    _upperBoard.text = _model.tenUeT;
    _lowerBoard.text = _model.tenShitaT;

    _gOuterT.text = _model.gOuterT;
    _ukamW.text = _model.gUkamW;
    _ukamT.text = _model.gUkamT;
    _sujiW.text = _model.gSujiW;
    _sujiT.text = _model.gSujiT;
    _shichuW.text = _model.gShichuW;
    _shichuT.text = _model.gShichuT;
    _dosanW.text = _model.gDoW;
    _dosanT.text = _model.gDoT;
    _dosanN.text = _model.gDoN;
    _tsumaW.text = _model.gTsumaW;
    _tsumaT.text = _model.gTsumaT;
    _hariukeW.text = _model.gHariukeW;
    _hariukeT.text = _model.gHariukeT;
    _hariukeEmbed.text = _model.gHariukeEmbed;
    _soeW.text = _model.gSoeW;
    _soeT.text = _model.gSoeT;
    _sokotsumaSketchImage = _model.sokotsumaSketchImageBytes;

    _konHariW.text = _model.konHariW;
    _konHariT.text = _model.konHariT;
    _konHariN.text = _model.konHariN;
    _konOsaeL.text = _model.konOsaeL;
    _konOsaeW.text = _model.konOsaeW;
    _konOsaeT.text = _model.konOsaeT;
    _konOsaeN.text = _model.konOsaeN;
    _konTopL.text = _model.konTopL;
    _konTopW.text = _model.konTopW;
    _konTopT.text = _model.konTopT;
    _konTopN.text = _model.konTopN;

    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        _tsuikaControllers[i][j].text = _model.tsuikaBuzai[i][j];
      }
    }
  }

  // 現在の入力値からKouchuhyoInputModelを構築するメソッド
  KouchuhyoInputModel _buildCurrentKouchuhyoModel() {
    return KouchuhyoInputModel(
      seiriBangou: _seiri.text,
      shukkaDate: _shukkaDate.text,
      hakkoubi: _date.text,
      koban: _koban.text,
      shimuke: _shimuke.text,
      hinmei: _hinmei.text,
      weight: _weight.text,
      amount: _amount.text,
      gel: _gel.text,
      keishiki: _keishiki.text,
      structure: _structure.text,
      domestic: _domestic.text,
      uchinoriLength: _uchiL.text,
      uchinoriWidth: _uchiW.text,
      uchinoriHeight: _uchiH.text,
      sotonoriLength: _sotoL.text,
      sotonoriWidth: _sotoW.text,
      sotonoriHeight: _sotoH.text,
      gOuterT: _gOuterT.text,
      gUkamW: _ukamW.text,
      gUkamT: _ukamT.text,
      gSujiW: _sujiW.text,
      gSujiT: _sujiT.text,
      // gShitaW: '', // モデルにはあるがコントローラがない項目は空文字
      // gShitaT: '', // モデルにはあるがコントローラがない項目は空文字
      gShichuW: _shichuW.text,
      gShichuT: _shichuT.text,
      gDoW: _dosanW.text,
      gDoT: _dosanT.text,
      gDoN: _dosanN.text,
      gTsumaW: _tsumaW.text,
      gTsumaT: _tsumaT.text,
      gHariukeW: _hariukeW.text,
      gHariukeT: _hariukeT.text,
      gHariukeEmbed: _hariukeEmbed.text,
      gSoeW: _soeW.text,
      gSoeT: _soeT.text,
      kSubeW: _subeW.text,
      kSubeT: _subeT.text,
      kSubeN: _subeN.text,
      kHeaderW: _headerW.text,
      kHeaderT: _headerT.text,
      kHeaderStop: _headerStopCtr.text,
      kSuriType: _suriTypeCtr.text,
      kSuriW: _suriW.text,
      kSuriT: _suriT.text,
      kSuriN: _suriN.text,
      kYukaT: _yukaT.text,
      kFukaW: _fukaW.text,
      kFukaT: _fukaT.text,
      kFukaN: _fukaN.text,
      kNedomL: _nedomL.map((c) => c.text).toList(),
      kNedomW: _nedomW.map((c) => c.text).toList(),
      kNedomT: _nedomT.map((c) => c.text).toList(),
      kNedomN: _nedomN.map((c) => c.text).toList(),
      konHariW: _konHariW.text,
      konHariT: _konHariT.text,
      konHariN: _konHariN.text,
      konOsaeL: _konOsaeL.text,
      konOsaeW: _konOsaeW.text,
      konOsaeT: _konOsaeT.text,
      konOsaeN: _konOsaeN.text,
      konTopL: _konTopL.text,
      konTopW: _konTopW.text,
      konTopT: _konTopT.text,
      konTopN: _konTopN.text,
      tenUeT: _upperBoard.text,
      tenShitaT: _lowerBoard.text,
      tsuikaBuzai: List.generate(
        5,
        (i) => List.generate(
          5,
          (j) => _tsuikaControllers[i][j].text,
        ),
      ),
      koshitaSketchImageBytes: _koshitaSketchImage,
      sokotsumaSketchImageBytes: _sokotsumaSketchImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('工注票入力')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KouchuhyoBasicInfoSection(
              seiriController: _seiri,
              shukkaDateController: _shukkaDate,
              dateController: _date,
              kobanController: _koban,
              shimukeController: _shimuke,
              hinmeiController: _hinmei,
              weightController: _weight,
              amountController: _amount,
              gelController: _gel,
              keishikiController: _keishiki,
              structureController: _structure,
              domesticController: _domestic,
              uchinoriLengthController: _uchiL,
              uchinoriWidthController: _uchiW,
              uchinoriHeightController: _uchiH,
              sotonoriLengthController: _sotoL,
              sotonoriWidthController: _sotoW,
              sotonoriHeightController: _sotoH,
            ),
            KoshitaSection(
              subaWController: _subeW,
              subaTController: _subeT,
              subaNController: _subeN,
              headerWController: _headerW,
              headerTController: _headerT,
              headerStopController: _headerStopCtr,
              suriTypeController: _suriTypeCtr,
              suriWController: _suriW,
              suriTController: _suriT,
              suriNController: _suriN,
              yukaTController: _yukaT,
              fukaWController: _fukaW,
              fukaTController: _fukaT,
              fukaNController: _fukaN,
              nedomLControllers: _nedomL,
              nedomWControllers: _nedomW,
              nedomTControllers: _nedomT,
              nedomNControllers: _nedomN,
              onSketch: (bytes) => setState(() => _koshitaSketchImage = bytes),
            ),
            TenjoSection(
              upperBoardController: _upperBoard,
              lowerBoardController: _lowerBoard,
            ),
            GawaTsumaSection(
              outerBoardTController: _gOuterT,
              ukamWController: _ukamW,
              ukamTController: _ukamT,
              sujiWController: _sujiW,
              sujiTController: _sujiT,
              shichuWController: _shichuW,
              shichuTController: _shichuT,
              hariukeWController: _hariukeW,
              hariukeTController: _hariukeT,
              hariukeEmbedController: _hariukeEmbed,
              soeWController: _soeW,
              soeTController: _soeT,
              dosanWController: _dosanW,
              dosanTController: _dosanT,
              dosanNController: _dosanN,
              tsumaWController: _tsumaW,
              tsumaTController: _tsumaT,
              onSketch: (bytes) => setState(() => _sokotsumaSketchImage = bytes),
            ),
            KonpouzaiSection(
              konHariWController: _konHariW,
              konHariTController: _konHariT,
              konHariNController: _konHariN,
              konOsaeLController: _konOsaeL,
              konOsaeWController: _konOsaeW,
              konOsaeTController: _konOsaeT,
              konOsaeNController: _konOsaeN,
              konTopLController: _konTopL,
              konTopWController: _konTopW,
              konTopTController: _konTopT,
              konTopNController: _konTopN,
            ),
            TsuikabuzaiSection(controllers: _tsuikaControllers),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('プレビュー表示'),
                  onPressed: () {
                    // 現在の入力値からKouchuhyoInputModelを構築
                    final currentModel = _buildCurrentKouchuhyoModel();

                    // プレビューページにモデルを渡す
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KouchuhyoPreviewPage(
                          model: currentModel, // modelを直接渡す
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('テンプレートとして保存'),
                  onPressed: () async {
                    final controller = TextEditingController();
                    final name = await showDialog<String>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('テンプレート名を入力'),
                        content: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: const InputDecoration(hintText: '例: A社輸出'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, controller.text.trim()),
                            child: const Text('保存'),
                          ),
                        ],
                      ),
                    );
                    if (name != null && name.isNotEmpty) {
                      // 現在の入力値からKouchuhyoInputModelを構築
                      final currentModel = _buildCurrentKouchuhyoModel();
                      final template = KouchuhyoTemplate(
                        name: name,
                        values: currentModel.toMap(),
                      );
                      await TemplateStorage.saveTemplate(template);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('テンプレートを保存しました')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}