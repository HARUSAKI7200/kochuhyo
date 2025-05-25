import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/utils/print_service.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/models/kouchuhyo_input_model.dart'; // kouchuhyo_app に戻す

class KouchuhyoPreviewPage extends StatelessWidget {
  final KouchuhyoInputModel model; // modelを受け取るように変更

  const KouchuhyoPreviewPage({
    Key? key,
    required this.model, // modelを受け取るように変更
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プレビューページ')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(),
                    const SizedBox(height: 12),
                    _responsiveRow([
                      _buildSizeInfo(),
                      _buildTenjoInfo(),
                    ]),
                    const SizedBox(height: 12),
                    _responsiveRow([
                      _buildKonpouzaiInfo(),
                      _buildBuzaibuInfo(),
                    ]),
                    const SizedBox(height: 12),
                    _responsiveRow([
                      _buildKoshitaInfo(),
                      _buildGawaTsumaInfo(),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // KouchuhyoInputModel を直接渡す
                  await printKouchuhyoA5x2(model);
                },
                child: const Text('印刷 (A4にA5サイズで2面)'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // KouchuhyoInputModel を直接渡す
                  final pdfBytes = await buildKouchuhyoA5x2Pdf(model);

                  // ファイル名に工番と日付をデフォルト値として提案
                  final defaultFileName = '工注票_${model.koban}_${model.hakkoubi.replaceAll('/', '-')}}';

                  final controller = TextEditingController(text: defaultFileName);
                  final fileName = await showDialog<String>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('保存ファイル名を入力'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: '例: 工注票_2025-05-07'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, controller.text.trim()),
                          child: const Text('保存'),
                        ),
                      ],
                    ),
                  );

                  if (fileName != null && fileName.isNotEmpty) {
                    final success = await savePdfWithAndroidPicker(pdfBytes, fileName);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('保存に成功しました')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('保存に失敗しました')),
                      );
                    }
                  }
                },
                child: const Text('PDFを保存（場所と名前を指定）'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _responsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: c,
            )).toList(),
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((c) => Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: c,
            ))).toList(),
          );
        }
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('■ $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }

  Widget _buildRow(String label, String? value) {
    final text = value?.isNotEmpty == true ? value! : '未入力';
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(100),
        1: FixedColumnWidth(20),
        2: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          Text(label, style: const TextStyle(fontSize: 20), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Text(':', style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
          Text(text, style: const TextStyle(fontSize: 20), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ],
    );
  }

  Widget _buildBasicInfo() => _buildSection('基本情報', [
    _responsiveRow([
      _buildRow('出荷日', model.shukkaDate),
      _buildRow('発行日', model.hakkoubi),
      _buildRow('工番', model.koban),
    ]),
    _responsiveRow([
      _buildRow('仕向先', model.shimuke),
      _buildRow('品名', model.hinmei),
      _buildRow('重量(kg)', model.weight),
    ]),
    _responsiveRow([
      _buildRow('整理番号', model.seiriBangou),
      _buildRow('ゲル(kg)', model.gel),
      _buildRow('出荷区分', model.domestic),
    ]),
    _responsiveRow([
      _buildRow('数量(C/S)', model.amount),
      _buildRow('形式', model.keishiki),
      _buildRow('構造', model.structure),
    ]),
  ]);

  Widget _buildSizeInfo() => _buildSection('寸法', [
    _buildRow('内寸', '${model.uchinoriLength}×${model.uchinoriWidth}×${model.uchinoriHeight}'),
    _buildRow('外寸', '${model.sotonoriLength}×${model.sotonoriWidth}×${model.sotonoriHeight}'),
  ]);

  Widget _buildTenjoInfo() => _buildSection('天井', [
    _buildRow('上板', model.tenUeT),
    _buildRow('下板', model.tenShitaT),
  ]);

  Widget _buildKonpouzaiInfo() => _buildSection('梱包材', [
    _buildRow('はり', '${model.konHariW}×${model.konHariT}×${model.konHariN}本'),
    _buildRow('押さえ材', '${model.konOsaeL}×${model.konOsaeW}×${model.konOsaeT}×${model.konOsaeN}本'),
    _buildRow('トップ', '${model.konTopL}×${model.konTopW}×${model.konTopT}×${model.konTopN}本'),
  ]);

  Widget _buildBuzaibuInfo() => _buildSection('追加部材', [
    for (final row in model.tsuikaBuzai)
      if (row.any((e) => e.isNotEmpty))
        _buildRow(row[0], row.sublist(1).where((e) => e.isNotEmpty).join('×'))
  ]);

  Widget _buildKoshitaInfo() {
    final suriType = model.kSuriType;
    final suriLabel = (suriType.trim().isNotEmpty) ? suriType : '（未選択）';

    return _buildSection('腰下', [
      _buildRow('滑材', '${model.kSubeW}×${model.kSubeT}×${model.kSubeN}本'),
      _buildRow(suriLabel, '${model.kSuriW}×${model.kSuriT}×${model.kSuriN}本'),
      _buildRow('ヘッダー', '${model.kHeaderW}×${model.kHeaderT}（${model.kHeaderStop}）'),
      _buildRow('負荷材', '${model.kFukaW}×${model.kFukaT}×${model.kFukaN}本'),
      _buildRow('床板', model.kYukaT),
      _buildRow('根止め材1', '${model.kNedomL[0]}×${model.kNedomW[0]}×${model.kNedomT[0]}×${model.kNedomN[0]}本'),
      _buildRow('根止め材2', '${model.kNedomL[1]}×${model.kNedomW[1]}×${model.kNedomT[1]}×${model.kNedomN[1]}本'),
      _buildRow('根止め材3', '${model.kNedomL[2]}×${model.kNedomW[2]}×${model.kNedomT[2]}×${model.kNedomN[2]}本'),
      _buildRow('根止め材4', '${model.kNedomL[3]}×${model.kNedomW[3]}×${model.kNedomT[3]}×${model.kNedomN[3]}本'),
      if (model.koshitaSketchImageBytes != null) ...[
        const SizedBox(height: 8),
        Image.memory(model.koshitaSketchImageBytes!, height: 150),
      ]
    ]);
  }

  Widget _buildGawaTsumaInfo() => _buildSection('側ツマ', [
    _buildRow('外板', model.gOuterT),
    _buildRow('上かまち', '${model.gUkamW}×${model.gUkamT}'),
    _buildRow('下かまち', '${model.gSujiW}×${model.gSujiT}'),
    _buildRow('支柱', '${model.gShichuW}×${model.gShichuT}'),
    _buildRow('はり受', '${model.gHariukeW}×${model.gHariukeT}（${model.gHariukeEmbed}）'),
    _buildRow('そえ柱', '${model.gSoeW}×${model.gSoeT}'),
    _buildRow('胴さん', '${model.gDoW}×${model.gDoT}×${model.gDoN}本'),
    _buildRow('つまさん', '${model.gTsumaW}×${model.gTsumaT}'),
    if (model.sokotsumaSketchImageBytes != null) ...[
      const SizedBox(height: 8),
      Image.memory(model.sokotsumaSketchImageBytes!, height: 150),
    ]
  ]);
}