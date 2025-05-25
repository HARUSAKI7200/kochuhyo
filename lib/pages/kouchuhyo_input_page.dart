// lib/pages/kouchuhyo_input_page.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/pages/input_sections/koshita_section.dart';
import 'package:kouchuhyo_app/pages/input_sections/gawa_tsuma_section.dart';
import 'package:kouchuhyo_app/pages/input_sections/konpouzai_section.dart';
import 'package:kouchuhyo_app/pages/input_sections/tenjo_section.dart';
import 'package:kouchuhyo_app/pages/input_sections/tsuikabuzai_section.dart';
import 'package:kouchuhyo_app/pages/input_sections/kouchuhyo_basic_info_section.dart';
import 'package:kouchuhyo_app/pages/kouchuhyo_preview_page.dart';
import '../utils/template_storage.dart';
import '../models/kouchuhyo_input_model.dart';
import '../models/kouchuhyo_template.dart';

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

  final List<List<TextEditingController>> _tsuikaControllers =
      List.generate(5, (_) => List.generate(5, (_) => TextEditingController()));

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
  final _hariukeW = TextEditingController();
  final _hariukeT = TextEditingController();
  final _hariukeEmbed = TextEditingController();
  final _soeW = TextEditingController();
  final _soeT = TextEditingController();
  final _tsumaW = TextEditingController();
  final _tsumaT = TextEditingController();
  final _upperBoard = TextEditingController();
  final _lowerBoard = TextEditingController();
  final _konHariW = TextEditingController();
  final _konHariT = TextEditingController();
  final _konHariN = TextEditingController();
  final _konOsaeL = TextEditingController();
  final _osaeW = TextEditingController();
  final _osaeT = TextEditingController();
  final _konOsaeN = TextEditingController();
  final _konTopL = TextEditingController();
  final _konTopW = TextEditingController();
  final _konTopT = TextEditingController();
  final _konTopN = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = widget.preloadValues != null
        ? KouchuhyoInputModel.fromMap(widget.preloadValues!)
        : KouchuhyoInputModel.empty();
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
              konOsaeWController: _osaeW,
              konOsaeTController: _osaeT,
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
                    final values = <String, String>{
                      'shukkaDate': _shukkaDate.text,
                      'seiri': _seiri.text,
                      'date': _date.text,
                      'koban': _koban.text,
                      'shimuke': _shimuke.text,
                      'hinmei': _hinmei.text,
                      'weight': _weight.text,
                      'amount': _amount.text,
                      'gel': _gel.text,
                      'keishiki': _keishiki.text,
                      'structure': _structure.text,
                      'domestic': _domestic.text,
                      'uchiL': _uchiL.text,
                      'uchiW': _uchiW.text,
                      'uchiH': _uchiH.text,
                      'sotoL': _sotoL.text,
                      'sotoW': _sotoW.text,
                      'sotoH': _sotoH.text,
                      // 他のキーも同様に追加
                    };
                    final buzaibuList = List.generate(
                      5,
                      (i) => List.generate(
                        5,
                        (j) => _tsuikaControllers[i][j].text,
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KouchuhyoPreviewPage(
                          values: values,
                          buzaibuList: buzaibuList,
                          koshitaImage: _koshitaSketchImage,
                          sokotsumaImage: _sokotsumaSketchImage,
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
                            onPressed: () => Navigator.pop(context, controller.text),
                            child: const Text('保存'),
                          ),
                        ],
                      ),
                    );
                    if (name != null && name.isNotEmpty) {
                      final template = KouchuhyoTemplate(
                        name: name,
                        values: _model.toMap(),
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
