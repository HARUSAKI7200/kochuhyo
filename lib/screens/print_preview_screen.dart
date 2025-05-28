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
  
  // ★★★★★ ここからが修正後のレイアウトコードです ★★★★★
  pw.Widget _buildSingleSetContentArea(pw.Context context, KochuhyoData data, pw.Font ttfBold, pw.Font ttfRegular) {
    const double oneCm = 1 * PdfPageFormat.cm; 
    final baseFontSize = oneCm * 0.28; 
    final mainTextStyle = pw.TextStyle(fontSize: baseFontSize, font: ttfRegular);
    final boldTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize);
    final headerTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 1.1); 
    final titleTextStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 2.0); 
    final materialStyle = pw.TextStyle(font: ttfBold, fontSize: baseFontSize * 1.1, color: PdfColors.red);
    const double tableCellPadding = 1.0; 
    const double sectionSpacing = 0.5 * PdfPageFormat.mm; 
    const double drawingHeight = 2.8 * PdfPageFormat.cm;

    final smallTextStyle = mainTextStyle.copyWith(fontSize: baseFontSize * 0.85);
    final smallBoldTextStyle = boldTextStyle.copyWith(fontSize: baseFontSize * 0.95);


    List<Map<String, String>> _createTableItems(List<Map<String, String?>> items) {
      return items.map((item) {
        final parsed = DimensionParser(item['value'] ?? '');
        return {
          '項目名': item['name'] ?? '',
          '長さ': parsed.l,
          '幅': parsed.w,
          '厚さ': parsed.t,
          '本数': parsed.qty,
        };
      }).toList();
    }
    
    pw.Widget _buildDimensionTable(
      String title, 
      List<Map<String, String>> items, {
      bool isCompact = false, 
      bool thicknessOnly = false,
      pw.TextStyle? overrideTextStyle,
      pw.TextStyle? overrideBoldTextStyle,
    }) {
      if (items.isEmpty) return pw.Container();
      
      final textStyle = overrideTextStyle ?? mainTextStyle;
      final boldStyle = overrideBoldTextStyle ?? boldTextStyle;
      final headerStyle = overrideBoldTextStyle?.copyWith(fontSize: (overrideBoldTextStyle.fontSize ?? baseFontSize) * 1.1) ?? headerTextStyle;

      List<pw.Widget> headerCells = [
        pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('項目名', style: boldStyle)),
      ];
      if (!thicknessOnly) {
        headerCells.addAll([
          pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('長さ', style: boldStyle)),
          pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('幅', style: boldStyle)),
        ]);
      }
      headerCells.add(pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('厚さ', style: boldStyle)));
      if (!thicknessOnly) {
        headerCells.add(pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('数', style: boldStyle)));
      }

      Map<int, pw.TableColumnWidth> columnWidths = {
        0: pw.FlexColumnWidth(isCompact ? 1.8 : 2.2), 
      };
      if (!thicknessOnly) {
        columnWidths.addAll({
          1: const pw.FlexColumnWidth(0.8), 
          2: const pw.FlexColumnWidth(0.8), 
          3: const pw.FlexColumnWidth(0.8), 
          4: const pw.FlexColumnWidth(0.8),
        });
      } else {
         columnWidths[0] = const pw.FlexColumnWidth(2.5); 
         columnWidths.addAll({1: const pw.FlexColumnWidth(1.0)});
      }

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min, 
        children: [
          pw.Text(title, style: headerStyle),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            columnWidths: columnWidths,
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: headerCells
              ),
              ...items.map((item) {
                List<pw.Widget> itemCells = [
                  pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(item['項目名']!, style: textStyle)),
                ];
                if(!thicknessOnly) {
                  itemCells.addAll([
                    pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(item['長さ']!, style: textStyle)),
                    pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(item['幅']!, style: textStyle)),
                  ]);
                }
                itemCells.add(pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(item['厚さ']!, style: textStyle)));
                if(!thicknessOnly) {
                  itemCells.add(pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(item['本数']!, style: textStyle)));
                }
                return pw.TableRow(children: itemCells);
              }),
            ],
          ),
          pw.SizedBox(height: sectionSpacing),
        ]
      );
    }
    
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
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text('内寸', style: boldTextStyle.copyWith(fontSize: baseFontSize * 1.1))),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.innerLength, style: boldTextStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.innerWidth, style: boldTextStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(tableCellPadding), child: pw.Text(data.innerHeight, style: boldTextStyle)),
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
    
    List<Map<String, String?>> koshitaCombinedSourceItems = [
        {'name': '滑材', 'value': data.skid},
        {'name': 'H (${data.hFixingMethod})', 'value': data.h},
        {'name': data.suriGetaType, 'value': data.suriGeta + (data.suriGetaType == 'ゲタ' ? ' x${data.getaQuantity}本' : '')},
        {'name': '床板', 'value': data.floorBoard},
        {'name': '負荷床材', 'value': data.loadBearingMaterial},
    ];
    for (int i = 0; i < data.rootStops.length; i++) {
      final rawVal = data.rootStops[i];
      if (rawVal.replaceAll(RegExp(r'[LMWT・x本a-zA-Z\s]'),'').isNotEmpty) {
        koshitaCombinedSourceItems.add({'name': '根止め ${i + 1}', 'value': rawVal});
      }
    }
    List<Map<String, String?>> konpozaiSourceItems = [
          {'name': 'ハリ', 'value': data.hari},
          {'name': '押さえ材${data.pressingMaterialHasMolding ? " (盛材有)" : ""}', 'value': data.pressingMaterial},
          {'name': 'トップ材', 'value': data.topMaterial},
    ];
    List<Map<String, String?>> gawaTsumaSourceItems = [
        {'name': '外板', 'value': data.sideBoard},
        {'name': '上かまち', 'value': data.upperKamachi},
        {'name': '下かまち', 'value': data.lowerKamachi},
        {'name': '支柱', 'value': data.pillar},
        {'name': 'はり受${data.beamReceiverEmbed ? " (埋める)" : ""}', 'value': data.beamReceiver},
        {'name': 'そえ柱${data.bracePillarShortEnds ? " (両端短め)" : ""}', 'value': data.bracePillar},
    ];
    List<Map<String, String?>> tenjoSourceItems = [
        {'name': '上板', 'value': data.ceilingUpperBoard.replaceAll('t', '')+'t'},
        {'name': '下板', 'value': data.ceilingLowerBoard.replaceAll('t', '')+'t'},
    ];
    List<Map<String, String?>> additionalPartsSourceItems = data.additionalParts
          .where((p) => p['name']!.isNotEmpty && p['dims']!.replaceAll(RegExp(r'[LMWT・x本a-zA-Z\s]'),'').isNotEmpty)
          .map<Map<String, String?>>((p) => {'name': p['name'], 'value': p['dims']})
          .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Stack(
          children: [
            pw.Center(child: pw.Text('工   注   票', style: titleTextStyle.copyWith(fontWeight: pw.FontWeight.bold))),
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('出荷日: ${data.shippingDate}', style: mainTextStyle),
                  pw.Text('発行日: ${data.issueDate}', style: mainTextStyle),
                  pw.Text('整理番号: ${data.serialNumber}', style: mainTextStyle),
                ]
              )
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
                    _buildDimensionTable('腰下・負荷床材・根止め', _createTableItems(koshitaCombinedSourceItems), isCompact: true),
                    _buildDimensionTable('梱包材', _createTableItems(konpozaiSourceItems), isCompact: true),
                  ]
                ),
              ),
              pw.SizedBox(width: sectionSpacing * 4),
              pw.Expanded(
                child: pw.ListView(
                  children: [
                    _buildDrawing(data.gawaTsumaImageBytes, '側・妻図面なし'),
                    // ★★★ 修正点: 側・妻の表にも、小さい文字スタイルを適用 ★★★
                    _buildDimensionTable(
                      '側・妻', 
                      _createTableItems(gawaTsumaSourceItems), 
                      isCompact: true,
                      overrideTextStyle: smallTextStyle,
                      overrideBoldTextStyle: smallBoldTextStyle
                    ),
                    _buildDimensionTable(
                      '天井', 
                      _createTableItems(tenjoSourceItems), 
                      thicknessOnly: true, 
                      isCompact: true,
                      overrideTextStyle: smallTextStyle,
                      overrideBoldTextStyle: smallBoldTextStyle
                    ),
                    _buildDimensionTable(
                      '追加部材', 
                      _createTableItems(additionalPartsSourceItems), 
                      isCompact: true,
                      overrideTextStyle: smallTextStyle,
                      overrideBoldTextStyle: smallBoldTextStyle
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