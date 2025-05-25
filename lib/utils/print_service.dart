import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

/// 印刷プレビュー（A4にA5を2面配置）
Future<void> printKouchuhyoA5x2(Uint8List bytes) async {
  final pdf = pw.Document();
  final image = pw.MemoryImage(bytes);

  final a5 = PdfPageFormat.a5.landscape;
  final imgWidth = a5.width;
  final imgHeight = a5.height * 0.96; // 高さ4%縮小

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 0,
        marginBottom: 0,
        marginLeft: 10,
        marginRight: 0,
      ),
      build: (context) {
        return pw.Column(
          children: [
            pw.SizedBox(height: 10),
            pw.Container(
              width: imgWidth,
              height: imgHeight,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              width: imgWidth,
              height: imgHeight,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

/// PDF保存用（印刷レイアウトと同じ構成）
Future<Uint8List> buildKouchuhyoA5x2Pdf(Uint8List bytes) async {
  final pdf = pw.Document();
  final image = pw.MemoryImage(bytes);

  final a5 = PdfPageFormat.a5.landscape;
  final imgWidth = a5.width;
  final imgHeight = a5.height * 0.96;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 0,
        marginBottom: 0,
        marginLeft: 10,
        marginRight: 0,
      ),
      build: (context) {
        return pw.Column(
          children: [
            pw.SizedBox(height: 10),
            pw.Container(
              width: imgWidth,
              height: imgHeight,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              width: imgWidth,
              height: imgHeight,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

/// ファイル名を指定してPDF保存（DCIM/工注票 に保存）
Future<String?> savePdfWithName(Uint8List pdfBytes, String fileName) async {
  try {
    // 権限確認（荷札OCRと同じ方式）
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      print('[ERROR] ストレージ権限なし');
      return null;
    }

    // 保存先ディレクトリ（Excelと同じ構造）
    final externalDir = Directory('/storage/emulated/0/DCIM/工注票');
    if (!await externalDir.exists()) {
      await externalDir.create(recursive: true);
    }

    final file = File('${externalDir.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);
    print('[DEBUG] PDF保存成功: ${file.path}');
    return file.path;
  } catch (e) {
    print('[ERROR] PDF保存失敗: $e');
    return null;
  }
}

/// Androidネイティブに保存要求を出す（ファイル名とPDFデータを送る）
Future<bool> savePdfWithAndroidPicker(Uint8List pdfBytes, String fileName) async {
  const platform = MethodChannel('save_pdf_channel');
  try {
    final result = await platform.invokeMethod('savePdfToUri', {
      'fileName': '$fileName.pdf',
      'pdfBytes': pdfBytes,
    });
    if (result == true) {
      print('[DEBUG] PDF保存成功');
    } else {
      print('[ERROR] PDF保存キャンセルまたは失敗');
    }
    return result == true;
  } on PlatformException catch (e) {
    print('[ERROR] PlatformException: $e');
    return false;
  }
}