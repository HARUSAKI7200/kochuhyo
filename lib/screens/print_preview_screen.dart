import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:kouchuhyo_app/screens/order_form_screen.dart';

class PrintPreviewScreen extends StatelessWidget {
  final KochuhyoData data;

  const PrintPreviewScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('印刷プレビュー (A4横)'),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(data),
        initialPageFormat: PdfPageFormat.a4.landscape,
        canChangePageFormat: true,
        canChangeOrientation: true,
      ),
    );
  }

  Future<Uint8List> _generatePdf(KochuhyoData data) async {
    final doc = pw.Document();

    final fontData = await rootBundle.load("fonts/NotoSansJP-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final fontBoldData = await rootBundle.load("fonts/NotoSansJP-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontBoldData);
    
    final baseTheme = pw.ThemeData.withFont(base: ttf, bold: ttfBold);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: baseTheme,
        margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        build: (pw.Context context) {
          return _buildA4LandscapeLayout(context, data, ttfBold, ttf);
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _buildA4LandscapeLayout(pw.Context context, KochuhyoData data, pw.Font ttfBold, pw.Font ttfRegular) {
    const double fontSizeXSmall = 5.5; // ★基本情報用にさらに小さいフォント
    const double fontSizeSmall = 6.5;  // ★通常項目のフォントサイズ
    const double fontSizeSectionTitle = 8.0; // ★セクションタイトルも調整
    const double paddingVal = 0.8; // ★パディングを詰める
    const double sectionSpacing = 2.0; // ★セクション間隔を詰める
    const double innerSectionSpacing = 1.5;
    const double drawingHeight = 85.0; // 図面の高さを少し調整

    pw.TextStyle xSmallStyle = pw.TextStyle(fontSize: fontSizeXSmall, font: ttfRegular);
    pw.TextStyle smallStyle = pw.TextStyle(fontSize: fontSizeSmall, font: ttfRegular);
    pw.TextStyle smallBoldStyle = pw.TextStyle(fontSize: fontSizeSmall, font: ttfBold);
    pw.TextStyle sectionTitleStyle = pw.TextStyle(font: ttfBold, fontSize: fontSizeSectionTitle);
    pw.TextStyle materialStyle = pw.TextStyle(font: ttfBold, fontSize: 12, color: PdfColors.red); // ★材質用スタイル

    // ヘッダー
    pw.Widget header = pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('工 注 票', style: pw.TextStyle(font: ttfBold, fontSize: 18)),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('整理番号: ${data.serialNumber}', style: smallStyle),
            pw.Text('発行日: ${data.issueDate}', style: smallStyle),
            pw.Text('出荷日: ${data.shippingDate}', style: smallStyle),
          ]
        )
      ]
    );
    
    // 基本情報セクション
    pw.Widget basicInfoSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text('基本情報', style: sectionTitleStyle),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          cellPadding: const pw.EdgeInsets.all(paddingVal),
          cellStyle: xSmallStyle,
          columnWidths: const {
            0: pw.FixedColumnWidth(30), 1: pw.FlexColumnWidth(2),
            2: pw.FixedColumnWidth(30), 3: pw.FlexColumnWidth(2),
            4: pw.FixedColumnWidth(30), 5: pw.FlexColumnWidth(1.5), // 材質用
          },
          data: <List<String>>[
            ['仕向先', data.shihomeisaki, '工番', data.kobango, '材質', ''], // 材質は後で上書き
            ['品名', data.hinmei, '重量', '${data.weight} KG', '', ''],
            ['数量', '${data.quantity} C/S','乾燥剤', data.desiccantAmount, '', ''],
            ['出荷形態', data.shippingType,'形状', data.packingForm, '', ''],
            ['形式', data.formType, '', '', '', ''],
          ],
          cellBuilder: { // 材質セルのみスタイルを変更
            pw.Point(4,0) : (dynamic data, pw.Point<int> point) => pw.Container(
                padding: const pw.EdgeInsets.all(paddingVal),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(this.data.material, style: materialStyle)
            ),
          }
        ),
      ]
    );

    // 寸法セクション
    pw.Widget dimensionsSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text('寸法 (mm)', style: sectionTitleStyle),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          cellPadding: const pw.EdgeInsets.all(paddingVal),
          cellStyle: xSmallStyle,
          headerStyle: pw.TextStyle(font: ttfBold, fontSize: fontSizeXSmall),
          headerAlignment: pw.Alignment.center,
          cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
          data: <List<String>>[
            ['', '長', '幅', '高'],
            // ★ 内寸のラベルを強調 (例: 太字)
            [ '内寸', data.innerLength, data.innerWidth, data.innerHeight],
          ],
          cellBuilder: { // 内寸ラベルのみスタイル変更
             pw.Point(0,1) : (dynamic data, pw.Point<int> point) => pw.Container(
                padding: const pw.EdgeInsets.all(paddingVal),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('内寸', style: pw.TextStyle(font: ttfBold, fontSize: fontSizeXSmall +1)) //少し大きく
            ),
          }
        ),
        pw.TableHelper.fromTextArray( // 外寸と容積は別テーブルで内寸の下に
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          cellPadding: const pw.EdgeInsets.all(paddingVal),
          cellStyle: xSmallStyle,
          headerStyle: pw.TextStyle(font: ttfBold, fontSize: fontSizeXSmall),
          headerAlignment: pw.Alignment.center,
          cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
          data: <List<String>>[
            ['外寸', data.outerLength, data.outerWidth, data.outerHeight],
            ['容積', data.packagingVolume, '(m³)', ''],
          ],
        ),
      ]
    );

    // 腰下セクション（根止め含む）
    final List<List<String>> koshitaDetails = [
      ['滑材', data.skid], ['H', '${data.h} (${data.hFixingMethod})'],
      [data.suriGetaType, data.suriGeta + (data.suriGetaType == 'ゲタ' ? ' x${data.getaQuantity}本' : '')],
      ['床板', data.floorBoard],
    ];
    final List<List<String>> rootStopDetails = List.generate(data.rootStops.length, (i) {
        final stopValue = data.rootStops[i].replaceAll('L x W x T・本', '').replaceAll(' x  x ・本', '').trim();
        return ['根止め ${i+1}', stopValue];
      }).where((list) => list[1].isNotEmpty).toList();
    
    pw.Widget koshitaSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('腰下・根止め', style: sectionTitleStyle),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          cellPadding: const pw.EdgeInsets.all(paddingVal), cellStyle: smallStyle,
          data: [...koshitaDetails, ...rootStopDetails], // ★根止めを腰下に統合
        ),
        if (data.koshitaImageBytes != null)
          pw.Container( height: drawingHeight, margin: const pw.EdgeInsets.only(top: innerSectionSpacing),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
            child: pw.Image(pw.MemoryImage(data.koshitaImageBytes!), fit: pw.BoxFit.contain),)
        else
          pw.Container(height: 20, margin: const pw.EdgeInsets.only(top: innerSectionSpacing), child: pw.Center(child: pw.Text('腰下図面なし', style: smallStyle))),
      ]
    );
    
    pw.Widget konpozaiSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('梱包材', style: sectionTitleStyle),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          cellPadding: const pw.EdgeInsets.all(paddingVal), cellStyle: smallStyle,
          data: <List<String>>[
            ['ハリ', data.hari],
            ['押さえ材', data.pressingMaterial + (data.pressingMaterialHasMolding ? ' (盛材有)' : '')],
            ['トップ材', data.topMaterial],
          ],
        ),
      ]
    );

    pw.Widget gawaTsumaSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('側・妻', style: sectionTitleStyle),
         pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            cellPadding: const pw.EdgeInsets.all(paddingVal), cellStyle: smallStyle,
            data: <List<String>>[
              ['外板', data.sideBoard],
              ['かまち種類', data.kamachiType],
              ['上かまち', data.upperKamachi],
              ['下かまち', data.lowerKamachi],
              ['支柱', data.pillar],
              // ★ そえ柱・はり受の表記修正
              ['はり受', data.beamReceiver + (data.beamReceiverEmbed ? ' (埋める)' : '')],
              ['そえ柱', data.bracePillar + (data.bracePillarShortEnds ? ' (両端短め)' : '')],
            ],
          ),
        if (data.gawaTsumaImageBytes != null)
          pw.Container( height: drawingHeight, margin: const pw.EdgeInsets.only(top: innerSectionSpacing),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
            child: pw.Image(pw.MemoryImage(data.gawaTsumaImageBytes!), fit: pw.BoxFit.contain),)
        else
          pw.Container(height: 20, margin: const pw.EdgeInsets.only(top: innerSectionSpacing), child: pw.Center(child: pw.Text('側・妻図面なし', style: smallStyle))),
      ]
    );

    pw.Widget tenjoSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('天井', style: sectionTitleStyle),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          cellPadding: const pw.EdgeInsets.all(paddingVal), cellStyle: smallStyle,
          data: [['上板', data.ceilingUpperBoard], ['下板', data.ceilingLowerBoard]],
        ),
      ]
    );
    
    final additionalPartsData = data.additionalParts
        .where((p) => p['name']!.isNotEmpty && p['dims']!.replaceAll(RegExp(r'[LMWT・x本]'), '').trim().isNotEmpty)
        .map((p) => [p['name']!, p['dims']!])
        .toList();
    
    pw.Widget additionalPartsSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('追加部材', style: sectionTitleStyle), // ★追加部材セクション表示
        if (additionalPartsData.isNotEmpty)
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            cellPadding: const pw.EdgeInsets.all(paddingVal), cellStyle: smallStyle,
            columnWidths: const {0: pw.FixedColumnWidth(50), 1: pw.FlexColumnWidth(3)},
            data: additionalPartsData,
          )
        else
          pw.Padding(padding: const pw.EdgeInsets.all(paddingVal), child: pw.Text('なし', style: smallStyle)),
      ]
    );
    
    pw.Widget kajuSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('荷重', style: sectionTitleStyle),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          cellPadding: const pw.EdgeInsets.all(paddingVal), cellStyle: smallStyle,
          data: <List<String>>[
            ['負荷床材', data.loadBearingMaterial],
            ['計算方法', data.loadCalculationMethod],
            if (data.loadCalculationMethod == '2点集中荷重')
              [' > 詳細', data.twoPointLoadDetails + '\n最終荷重: ${data.finalAllowableLoad}'],
            if (data.loadCalculationMethod != '2点集中荷重' && data.allowableLoadUniform.isNotEmpty && data.allowableLoadUniform != "計算不可")
              [' > 許容荷重', data.allowableLoadUniform],
          ],
        ),
      ]
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        header,
        pw.SizedBox(height: sectionSpacing),
        // 上段: 基本情報と寸法を横並び
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(flex: 7, child: basicInfoSection), // 基本情報を広めに
            pw.SizedBox(width: sectionSpacing * 1.5),
            pw.Expanded(flex: 3, child: dimensionsSection), // 寸法はコンパクトに
          ],
        ),
        pw.SizedBox(height: sectionSpacing),
        // 中段以降: 左右2列構成
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 左列
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    koshitaSection, // 腰下（根止め含む）と図面
                    pw.SizedBox(height: sectionSpacing),
                    konpozaiSection, // 梱包材
                    pw.Expanded(child: pw.Container()), // 可変スペース
                  ]
                ),
              ),
              pw.SizedBox(width: sectionSpacing * 1.5),
              // 右列
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    gawaTsumaSection, // 側・妻と図面
                    pw.SizedBox(height: sectionSpacing),
                    tenjoSection, // 天井
                    pw.SizedBox(height: sectionSpacing),
                    additionalPartsSection, // ★追加部材
                    pw.SizedBox(height: sectionSpacing),
                    kajuSection, // 荷重
                    pw.Expanded(child: pw.Container()), // 可変スペース
                  ]
                ),
              ),
            ],
          )
        ),
        pw.SizedBox(height: sectionSpacing / 2),
        pw.Container( height: 15, decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey600)),
            child: pw.Padding(padding: pw.EdgeInsets.only(left:2, top:1), child: pw.Text('備考欄:', style: smallBoldStyle))),
      ],
    );
  }
}