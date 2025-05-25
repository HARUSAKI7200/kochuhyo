import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/print_service.dart';

class KouchuhyoPreviewPage extends StatelessWidget {
  final Map<String, String?> values;
  final List<List<String>> buzaibuList;
  final Uint8List? koshitaImage;
  final Uint8List? sokotsumaImage;

  const KouchuhyoPreviewPage({
    Key? key,
    required this.values,
    required this.buzaibuList,
    this.koshitaImage,
    this.sokotsumaImage,
  }) : super(key: key);

  static final GlobalKey previewKey = GlobalKey();

  Future<Uint8List> _capturePreviewImage() async {
    final boundary = previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final image = await boundary!.toImage(pixelRatio: 4.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プレビューページ')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: previewKey,
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
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final imageBytes = await _capturePreviewImage();
                  await printKouchuhyoA5x2(imageBytes);
                },
                child: const Text('印刷 (A4にA5サイズで2面)'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final imageBytes = await _capturePreviewImage();
                  final pdfBytes = await buildKouchuhyoA5x2Pdf(imageBytes);

                  final success = await savePdfWithAndroidPicker(pdfBytes, '工注票_2025-05-07');
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存に成功しました')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存に失敗しました')),
                    );
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

  Future<void> _onSavePdfWithName(BuildContext context) async {
    final imageBytes = await _capturePreviewImage();

    final controller = TextEditingController();
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
      final pdfBytes = await buildKouchuhyoA5x2Pdf(imageBytes);
      final savedPath = await savePdfWithName(pdfBytes, fileName);
      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存しました: $savedPath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存に失敗しました')),
        );
      }
    }
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
      _buildRow('出荷日', values['shukkaDate']),
      _buildRow('発行日', values['date']),
      _buildRow('工番', values['koban']),
    ]),
    _responsiveRow([
      _buildRow('仕向先', values['shimuke']),
      _buildRow('品名', values['hinmei']),
      _buildRow('重量(kg)', values['weight']),
    ]),
    _responsiveRow([
      _buildRow('整理番号', values['seiri']),
      _buildRow('ゲル(kg)', values['gel']),
      _buildRow('出荷区分', values['domestic']),
    ]),
    _responsiveRow([
      _buildRow('数量(C/S)', values['amount']),
      _buildRow('形式', values['keishiki']),
      _buildRow('構造', values['structure']),
    ]),
  ]);

  Widget _buildSizeInfo() => _buildSection('寸法', [
    _buildRow('内寸', '${values['uchiL']}×${values['uchiW']}×${values['uchiH']}'),
    _buildRow('外寸', '${values['sotoL']}×${values['sotoW']}×${values['sotoH']}'),
  ]);

  Widget _buildTenjoInfo() => _buildSection('天井', [
    _buildRow('上板', values['upperBoard']),
    _buildRow('下板', values['lowerBoard']),
  ]);

  Widget _buildKonpouzaiInfo() => _buildSection('梱包材', [
    _buildRow('はり', '${values['konHariW']}×${values['konHariT']}×${values['konHariN']}本'),
    _buildRow('押さえ材', '${values['konOsaeL']}×${values['konOsaeW']}×${values['konOsaeT']}×${values['konOsaeN']}本'),
    _buildRow('トップ', '${values['konTopL']}×${values['konTopW']}×${values['konTopT']}×${values['konTopN']}本'),
  ]);

  Widget _buildBuzaibuInfo() => _buildSection('追加部材', [
    for (final row in buzaibuList)
      if (row.any((e) => e.isNotEmpty))
        _buildRow(row[0], row.sublist(1).where((e) => e.isNotEmpty).join('×'))
  ]);

  Widget _buildKoshitaInfo() {
    final suriType = values['suriType'];
    final suriLabel = (suriType != null && suriType.trim().isNotEmpty) ? suriType : '（未選択）';

    return _buildSection('腰下', [
      _buildRow('滑材', '${values['subeW']}×${values['subeT']}×${values['subeN']}本'),
      _buildRow(suriLabel, '${values['suriW']}×${values['suriT']}×${values['suriN']}本'),
      _buildRow('ヘッダー', '${values['headerW']}×${values['headerT']}（${values['headerStop'] ?? '未選択'}）'),
      _buildRow('負荷材', '${values['fukaW']}×${values['fukaT']}×${values['fukaN']}本'),
      _buildRow('床板', values['yuka']),
      _buildRow('根止め材1', '${values['nedomL1']}×${values['nedomW1']}×${values['nedomT1']}×${values['nedomN1']}本'),
      _buildRow('根止め材2', '${values['nedomL2']}×${values['nedomW2']}×${values['nedomT2']}×${values['nedomN2']}本'),
      _buildRow('根止め材3', '${values['nedomL3']}×${values['nedomW3']}×${values['nedomT3']}×${values['nedomN3']}本'),
      _buildRow('根止め材4', '${values['nedomL4']}×${values['nedomW4']}×${values['nedomT4']}×${values['nedomN4']}本'),
      if (koshitaImage != null) ...[
        const SizedBox(height: 8),
        Image.memory(koshitaImage!, height: 150),
      ]
    ]);
  }

  Widget _buildGawaTsumaInfo() => _buildSection('側ツマ', [
    _buildRow('外板', values['gOuterT']),
    _buildRow('上かまち', '${values['ukamW']}×${values['ukamT']}'),
    _buildRow('下かまち', '${values['sujiW']}×${values['sujiT']}'),
    _buildRow('支柱', '${values['shichuW']}×${values['shichuT']}'),
    _buildRow('はり受', '${values['hariukeW']}×${values['hariukeT']}（${values['hariukeEmbed'] ?? '未選択'}）'),
    _buildRow('そえ柱', '${values['soeW']}×${values['soeT']}'),
    _buildRow('胴さん', '${values['dosanW']}×${values['dosanT']}×${values['dosanN']}本'),
    _buildRow('つまさん', '${values['tsumaW']}×${values['tsumaT']}'),
    if (sokotsumaImage != null) ...[
      const SizedBox(height: 8),
      Image.memory(sokotsumaImage!, height: 150),
    ]
  ]);
}
