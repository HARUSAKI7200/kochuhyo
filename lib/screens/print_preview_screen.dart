import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:kouchuhyo_app/screens/order_form_screen.dart';

// DimensionParser クラス (変更なし)
class DimensionParser {
  final String rawString;
  String l = '';
  String w = '';
  String t = '';
  String qty = '';

  DimensionParser(this.rawString) {
    _parse();
  }

  void _parse() {
    if (rawString.isEmpty) return;

    String remainingString = rawString;

    final qtyMatch = RegExp(r'[xXх×・]\s*(\d+)\s*本$').firstMatch(remainingString);
    if (qtyMatch != null) {
      qty = qtyMatch.group(1)!;
      remainingString = remainingString.substring(0, qtyMatch.start).trim();
    } else {
      final qtyOnlyMatch = RegExp(r'^(\d+)\s*本$').firstMatch(remainingString);
        if (qtyOnlyMatch != null) {
            qty = qtyOnlyMatch.group(1)!;
            remainingString = "";
        }
    }

    final lMatch = RegExp(r'[lL]\s*(\d+(?:\.\d+)?)').firstMatch(remainingString);
    if (lMatch != null) {
      l = lMatch.group(1)!;
      remainingString = remainingString.replaceFirst(lMatch.group(0)!, '').trim();
    }

    final wMatch = RegExp(r'[wW]\s*(\d+(?:\.\d+)?)').firstMatch(remainingString);
    if (wMatch != null) {
      w = wMatch.group(1)!;
      remainingString = remainingString.replaceFirst(wMatch.group(0)!, '').trim();
    }

    final tMatch = RegExp(r'[tT]\s*(\d+(?:\.\d+)?)').firstMatch(remainingString);
    if (tMatch != null) {
      t = tMatch.group(1)!;
      remainingString = remainingString.replaceFirst(tMatch.group(0)!, '').trim();
    }

    remainingString = remainingString.replaceAll(RegExp(r'\s*[xXх×]\s*'), ' ').trim();
    final remainingParts = remainingString.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();

    if (l.isEmpty && remainingParts.isNotEmpty) {
      l = RegExp(r'^\d+(?:\.\d+)?$').hasMatch(remainingParts[0]) ? remainingParts.removeAt(0) : '';
    }
    if (w.isEmpty && remainingParts.isNotEmpty) {
      w = RegExp(r'^\d+(?:\.\d+)?$').hasMatch(remainingParts[0]) ? remainingParts.removeAt(0) : '';
    }
    if (t.isEmpty && remainingParts.isNotEmpty) {
      t = RegExp(r'^\d+(?:\.\d+)?$').hasMatch(remainingParts[0]) ? remainingParts.removeAt(0) : '';
    }
    if (l.isEmpty && w.isEmpty && t.isEmpty && qty.isEmpty) {
        final tOnlyMatch = RegExp(r'^(\d+(?:\.\d+)?)\s*t$').firstMatch(rawString.toLowerCase());
        if (tOnlyMatch != null) {
            t = tOnlyMatch.group(1)!;
        }
    }
  }
}

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
        title: const Text('印刷プレビュー (A4縦に2セット)'),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(data),
        initialPageFormat: PdfPageFormat.a4,
        canChangePageFormat: true,
        canChangeOrientation: true,
        dynamicLayout: true,
      ),
    );
  }

  Future<Uint8List> _generatePdf(KochuhyoData data) async {
    final doc = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/NotoSansJP-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final fontBoldData = await rootBundle.load("assets/fonts/NotoSansJP-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontBoldData);

    final baseTheme = pw.ThemeData.withFont(base: ttf, bold: ttfBold);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: baseTheme,
        margin: const pw.EdgeInsets.all(0.5 * PdfPageFormat.cm),
        build: (pw.Context context) {
          final singleSetContent = _buildSingleSetContentArea(context, data, ttfBold, ttf);

          final availableHeightForTwoSets = PdfPageFormat.a4.height - (1.0 * PdfPageFormat.cm) ;
          final singleSetHeight = availableHeightForTwoSets / 2;

          return pw.Column(
            children: [
              pw.Container(
                width: PdfPageFormat.a4.width - (1.0 * PdfPageFormat.cm),
                height: singleSetHeight,
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300, width: 0.5)),
                padding: const pw.EdgeInsets.all(0.2 * PdfPageFormat.cm),
                child: singleSetContent,
              ),
              pw.Container(
                width: PdfPageFormat.a4.width - (1.0 * PdfPageFormat.cm),
                height: singleSetHeight,
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300, width: 0.5)),
                padding: const pw.EdgeInsets.all(0.2 * PdfPageFormat.cm),
                child: singleSetContent,
              ),
            ]
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _buildSingleSetContentArea(pw.Context context, KochuhyoData data, pw.Font ttfBold, pw.Font ttfRegular) {
    const double oneCm = 1 * PdfPageFormat.cm;
    final baseFontSize = oneCm * 0.28;
    final mainTextStyle = pw.TextStyle(fontSize: baseFontSize, font: ttfRegular);
    final boldTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize);
    final headerTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 1.2);
    final titleTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 2.0);
    final materialStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 1.1, color: PdfColors.red);
    const double tableCellPadding = 1.0;
    const double sectionSpacing = 0.5 * PdfPageFormat.mm;
    const double drawingHeight = 2.8 * PdfPageFormat.cm;

    final smallTextStyle = mainTextStyle.copyWith(fontSize: baseFontSize * 0.85);
    final smallBoldTextStyle = boldTextStyle.copyWith(fontSize: baseFontSize * 0.95);

    final shippingDateTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 1.8);
    final issueDateTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 1.2);
    final serialNumberTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 1.8);

    // 腰下セクション専用のスタイル
    final koshitaContentTextStyle = mainTextStyle.copyWith(fontSize: baseFontSize * 1.2);
    final koshitaContentBoldStyle = boldTextStyle.copyWith(fontSize: baseFontSize * 1.2);

    // 梱包材セクション専用のスタイル
    final konpozaiContentTextStyle = mainTextStyle.copyWith(fontSize: baseFontSize * 1.2); // 入力数値も太字にするためboldStyleと同じfontSizeに調整
    final konpozaiContentBoldStyle = boldTextStyle.copyWith(fontSize: baseFontSize * 1.2);

    pw.Widget _buildDrawing(Uint8List? imageBytes, String placeholder) {
      return pw.Container(
          height: drawingHeight,
          width: double.infinity,
          margin: pw.EdgeInsets.only(bottom: sectionSpacing),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
          child: imageBytes != null
              ? pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.contain)
              : pw.Center(child: pw.Text(placeholder, style: mainTextStyle)),
        );
    }

    pw.Widget _buildBasicInfoRow(List<pw.Widget> children) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children.map((e) => pw.Expanded(child: pw.Padding(
            padding: pw.EdgeInsets.only(right: oneCm * 0.1),
            child: e
        ))).toList(),
      );
    }

    pw.Widget _buildBasicInfoItem(
      String label,
      String value, {
      pw.TextStyle? valueStyle,
      bool isMaterial = false,
      double labelWidth = 40,
    }) {
      return pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: labelWidth,
              child: pw.Text('$label: ', style: mainTextStyle.copyWith(color: PdfColors.grey700, fontSize: baseFontSize * 0.9), softWrap: false, overflow: pw.TextOverflow.clip)
            ),
            pw.Expanded(
              child: pw.Text(value, style: isMaterial ? materialStyle : (valueStyle ?? boldTextStyle), softWrap: true)
            ),
          ],
        );
    }

    pw.Widget dimensionsTable = pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.2), 1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1), 3: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('内寸', style: boldTextStyle.copyWith(fontSize: baseFontSize * 1.5))),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.innerLength, style: boldTextStyle.copyWith(fontSize: baseFontSize * 1.5))),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.innerWidth, style: boldTextStyle.copyWith(fontSize: baseFontSize * 1.5))),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.innerHeight, style: boldTextStyle.copyWith(fontSize: baseFontSize * 1.5))),
          ]
        ),
        pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('外寸', style: boldTextStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.outerLength, style: boldTextStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.outerWidth, style: boldTextStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.outerHeight, style: boldTextStyle)),
          ]
        ),
        pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('立米', style: boldTextStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.packagingVolume, style: boldTextStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('m³', style: boldTextStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('', style: boldTextStyle)),
          ]
        ),
      ]
    );

    List<pw.Widget> _buildCombinedDimensionItems(KochuhyoData data, pw.TextStyle textStyle, pw.TextStyle boldStyle) {
      final List<pw.Widget> widgets = [];

      // 1. 滑材とHを同じ行に
      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '滑材: ', style: boldStyle),
                    pw.TextSpan(text: '${data.skidWidth} × ${data.skidThickness}・${data.skidQuantity}本', style: textStyle),
                  ]
                )
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: 'H(${data.hFixingMethod}): ', style: boldStyle),
                    pw.TextSpan(text: '${data.hWidth} × ${data.hThickness}', style: textStyle),
                  ]
                )
              ),
            ),
          ],
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      // 2. すり材orゲタと床板を同じ行に
      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '${data.suriGetaType}: ', style: boldStyle),
                    pw.TextSpan(
                      text: '${data.suriGetaWidth} × ${data.suriGetaThickness}' +
                          (data.suriGetaType == 'ゲタ' ? ' ×${data.getaQuantity}本' : ''),
                      style: textStyle
                    ),
                  ]
                )
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '床板: ', style: boldStyle),
                    pw.TextSpan(text: '${data.floorBoardThickness}', style: textStyle),
                  ]
                )
              ),
            ),
          ],
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      // 3. 負荷床材を1行で表示
      widgets.add(
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: '負荷床材: ', style: boldStyle),
              pw.TextSpan(text: '${data.loadBearingMaterialWidth} × ${data.loadBearingMaterialThickness}・${data.loadBearingMaterialQuantity}本', style: textStyle),
            ]
          )
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      // 根止めを1行に2項目ずつ表示
      List<pw.Widget> rootStopRows = [];
      for (int i = 0; i < data.rootStops.length; i += 2) {
        pw.Widget rootStop1Widget;
        pw.Widget rootStop2Widget;

        if (i < data.rootStops.length) {
          final rawVal1 = data.rootStops[i];
          final parsedRootStop1 = DimensionParser(rawVal1);
          rootStop1Widget = pw.Expanded(
            flex: 1,
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: '根止め: ', style: boldStyle),
                  pw.TextSpan(text: '${parsedRootStop1.l} × ${parsedRootStop1.w} × ${parsedRootStop1.t}・${parsedRootStop1.qty}本', style: textStyle),
                ]
              )
            ),
          );
        } else {
          rootStop1Widget = pw.Expanded(flex: 1, child: pw.Container()); // 空のスペース
        }

        if (i + 1 < data.rootStops.length) {
          final rawVal2 = data.rootStops[i + 1];
          final parsedRootStop2 = DimensionParser(rawVal2);
          rootStop2Widget = pw.Expanded(
            flex: 1,
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: '根止め: ', style: boldStyle),
                  pw.TextSpan(text: '${parsedRootStop2.l} × ${parsedRootStop2.w} × ${parsedRootStop2.t}・${parsedRootStop2.qty}本', style: textStyle),
                ]
              )
            ),
          );
        } else {
          rootStop2Widget = pw.Expanded(flex: 1, child: pw.Container()); // 空のスペース
        }

        rootStopRows.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              rootStop1Widget,
              pw.SizedBox(width: sectionSpacing * 4), // 根止め間のスペース
              rootStop2Widget,
            ],
          )
        );
        rootStopRows.add(pw.SizedBox(height: sectionSpacing));
      }
      widgets.addAll(rootStopRows);

      return widgets;
    }

    // 梱包材の表示 (同様に個別の項目を RichText で表示)
    List<pw.Widget> _buildKonpozaiItems(KochuhyoData data, pw.TextStyle textStyle, pw.TextStyle boldStyle) {
      final List<pw.Widget> widgets = [];

      widgets.add(
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: 'ハリ: ', style: boldStyle),
                pw.TextSpan(text: '${data.hariWidth} × ${data.hariThickness}・${data.hariQuantity}本', style: textStyle),
              ]
            )
          ),
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      widgets.add(
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: '押さえ材${data.pressingMaterialHasMolding ? " (盛材有)" : ""}: ', style: boldStyle),
                pw.TextSpan(text: '${data.pressingMaterialLength} × ${data.pressingMaterialWidth} × ${data.pressingMaterialThickness}・${data.pressingMaterialQuantity}本', style: textStyle),
              ]
            )
          ),
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      widgets.add(
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: 'トップ材: ', style: boldStyle),
                pw.TextSpan(text: '${data.topMaterialLength} × ${data.topMaterialWidth} × ${data.topMaterialThickness}・${data.topMaterialQuantity}本', style: textStyle),
              ]
            )
          ),
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      return widgets;
    }

    // 側・妻の表示 (同様に個別の項目を RichText で表示)
    List<pw.Widget> _buildGawaTsumaItems(KochuhyoData data, pw.TextStyle textStyle, pw.TextStyle boldStyle) {
      final List<pw.Widget> widgets = [];

      widgets.add(
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: '外板: ', style: boldStyle),
              pw.TextSpan(text: '${data.sideBoardThickness}', style: textStyle),
            ]
          )
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      widgets.add(
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: '上かまち: ', style: boldStyle),
              pw.TextSpan(text: '${data.upperKamachiWidth} × ${data.upperKamachiThickness}', style: textStyle),
            ]
          )
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      widgets.add(
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: '下かまち: ', style: boldStyle),
              pw.TextSpan(text: '${data.lowerKamachiWidth} × ${data.lowerKamachiThickness}', style: textStyle),
            ]
          )
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      widgets.add(
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: '支柱: ', style: boldStyle),
              pw.TextSpan(text: '${data.pillarWidth} × ${data.pillarThickness}', style: textStyle),
            ]
          )
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      widgets.add(
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: 'はり受${data.beamReceiverEmbed ? " (埋める)" : ""}: ', style: boldStyle),
              pw.TextSpan(text: '${data.beamReceiverWidth} × ${data.beamReceiverThickness}', style: textStyle),
            ]
          )
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      widgets.add(
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: 'そえ柱${data.bracePillarShortEnds ? " (両端短め)" : ""}: ', style: boldStyle),
              pw.TextSpan(text: '${data.bracePillarWidth} × ${data.bracePillarThickness}', style: textStyle),
            ]
          )
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      return widgets;
    }

    // 天井の表示
    List<pw.Widget> _buildTenjoItems(KochuhyoData data, pw.TextStyle textStyle, pw.TextStyle boldStyle) {
      final List<pw.Widget> widgets = [];

      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '上板: ', style: boldStyle),
                    pw.TextSpan(text: '${data.ceilingUpperBoardThickness}', style: textStyle),
                  ]
                )
              ),
            ),
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '下板: ', style: boldStyle),
                    pw.TextSpan(text: '${data.ceilingLowerBoardThickness}', style: textStyle),
                  ]
                )
              ),
            ),
          ],
        )
      );
      widgets.add(pw.SizedBox(height: sectionSpacing));

      return widgets;
    }

    // 追加部材の表示 (以前のループを踏襲)
    List<pw.Widget> _buildAdditionalPartsItems(KochuhyoData data, pw.TextStyle textStyle, pw.TextStyle boldStyle) {
      final List<pw.Widget> widgets = [];

      for (int i = 0; i < data.additionalParts.length; i++) {
        final part = data.additionalParts[i];
        if (part['name']!.isNotEmpty && (DimensionParser(part['dims']!).l.isNotEmpty || DimensionParser(part['dims']!).w.isNotEmpty || DimensionParser(part['dims']!).t.isNotEmpty || DimensionParser(part['dims']!).qty.isNotEmpty)) {
          final parsedPart = DimensionParser(part['dims']!);
          widgets.add(
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: '${part['name']!}: ', style: boldStyle),
                  pw.TextSpan(text: '${parsedPart.l} × ${parsedPart.w} × ${parsedPart.t}・${parsedPart.qty}本', style: textStyle),
                ]
              )
            )
          );
          widgets.add(pw.SizedBox(height: sectionSpacing));
        }
      }
      return widgets;
    }


    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Stack(
          children: [
            // 工注票タイトル
            pw.Center(child: pw.Text('工   注   票', style: titleTextStyle.copyWith(fontWeight: pw.FontWeight.bold))),

            // 出荷日 (ヘッダーの左とタイトルの間の中心)
            pw.Align(
              alignment: pw.Alignment.topLeft,
              child: pw.SizedBox(
                width: PdfPageFormat.a4.width / 2 - (1.0 * PdfPageFormat.cm) / 2, // ページ幅の半分からマージンを引いた範囲
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text('出荷日: ${data.shippingDate}', style: shippingDateTextStyle),
                ),
              ),
            ),

            // 発行日 (タイトルと整理番号の間の中心)
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: pw.Padding(
                padding: pw.EdgeInsets.only(right: (PdfPageFormat.a4.width / 2 - (1.0 * PdfPageFormat.cm)) / 2 ), // 整理番号との中央
                child: pw.Text('発行日: ${data.issueDate}', style: issueDateTextStyle),
              ),
            ),

            // 整理番号 (ヘッダーの右上詰め)
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: pw.Text('整理番号: ${data.serialNumber}', style: serialNumberTextStyle),
            )
          ]
        ),
        pw.SizedBox(height: sectionSpacing * 2),
        _buildBasicInfoRow([
          _buildBasicInfoItem('工番', data.kobango, labelWidth: 15 * PdfPageFormat.mm),
          _buildBasicInfoItem('仕向先', data.shihomeisaki, labelWidth: 18 * PdfPageFormat.mm),
          _buildBasicInfoItem('品名', data.hinmei, labelWidth: 15 * PdfPageFormat.mm),
          _buildBasicInfoItem('重量', '${data.weight} KG', labelWidth: 15 * PdfPageFormat.mm),
        ]),
         _buildBasicInfoRow([
          _buildBasicInfoItem('出荷形態', data.shippingType, labelWidth: 20 * PdfPageFormat.mm),
          _buildBasicInfoItem('形式', data.formType, labelWidth: 15 * PdfPageFormat.mm),
          _buildBasicInfoItem('形状', data.packingForm, labelWidth: 15 * PdfPageFormat.mm),
          _buildBasicInfoItem('材質', data.material, isMaterial: true, labelWidth: 15 * PdfPageFormat.mm),
        ]),
        _buildBasicInfoRow([
          _buildBasicInfoItem('乾燥剤', data.desiccantAmount, labelWidth: 18 * PdfPageFormat.mm),
          _buildBasicInfoItem('数量', '${data.quantity} C/S', labelWidth: 15 * PdfPageFormat.mm),
          pw.Expanded(child: pw.Container()),
          pw.Expanded(child: pw.Container()),
        ]),
        pw.Divider(height: sectionSpacing * 2, thickness: 0.5),

        pw.Flexible(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.ListView(
                  children: [
                    dimensionsTable,
                    pw.SizedBox(height: sectionSpacing * 2),
                    _buildDrawing(data.koshitaImageBytes, '腰下図面なし'),
                    // 腰下・負荷床材・根止め
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('腰下・負荷床材・根止め', style: headerTextStyle),
                        pw.SizedBox(height: sectionSpacing),
                        ..._buildCombinedDimensionItems(data, koshitaContentTextStyle, koshitaContentBoldStyle),
                      ]
                    ),
                    pw.SizedBox(height: sectionSpacing * 2),
                    // 梱包材
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('梱包材', style: headerTextStyle),
                        pw.SizedBox(height: sectionSpacing),
                        ..._buildKonpozaiItems(data, konpozaiContentTextStyle, konpozaiContentBoldStyle),
                      ]
                    ),
                  ]
                ),
              ),
              pw.SizedBox(width: sectionSpacing * 4),
              pw.Expanded(
                child: pw.ListView(
                  children: [
                    _buildDrawing(data.gawaTsumaImageBytes, '側・妻図面なし'),
                    // 側・妻
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('側・妻', style: headerTextStyle),
                        pw.SizedBox(height: sectionSpacing),
                        ..._buildGawaTsumaItems(data, smallTextStyle, smallBoldTextStyle),
                      ]
                    ),
                    // 天井
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('天井', style: headerTextStyle),
                        pw.SizedBox(height: sectionSpacing),
                        ..._buildTenjoItems(data, smallTextStyle, smallBoldTextStyle),
                      ]
                    ),
                    // 追加部材
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('追加部材', style: headerTextStyle),
                        pw.SizedBox(height: sectionSpacing),
                        ..._buildAdditionalPartsItems(data, smallTextStyle, smallBoldTextStyle),
                      ]
                    ),
                  ]
                ),
              ),
            ],
          )
        ),
      ],
    );
  }
}