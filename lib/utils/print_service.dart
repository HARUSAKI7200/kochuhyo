import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // google_fonts をインポート
import 'package:kouchuhyo_app/models/kouchuhyo_input_model.dart'; // kouchuhyo_app に戻す

// PDFにテキストを配置するためのヘルパー関数 (static修飾子を削除し、トップレベル関数にするか、createKouchuhyoPage内に移動)
// 今回はcreateKouchuhyoPage内に移動することで、スコープの問題を解決します。
// そのため、ここでは定義を削除し、createKouchuhyoPage内に同等のロジックを直接記述します。


/// 印刷プレビュー（A4にA5を2面配置）
Future<void> printKouchuhyoA5x2(KouchuhyoInputModel model) async {
  final pdf = pw.Document();
  // PdfGoogleFonts.notoSansJapanese() を使用
  final font = await PdfGoogleFonts.notoSansJapanese(); // 正しい日本語フォントのロード方法


  // 工注票1.jpg の背景画像をロード
  final ByteData imgData = await rootBundle.load('assets/images/kouchuhyo1.jpg');
  final Uint8List imgBytes = imgData.buffer.asUint8List();
  final pw.MemoryImage backgroundImage = pw.MemoryImage(imgBytes);

  // 腰下と側ツマの手書き画像
  final pw.MemoryImage? koshitaSketchImage = model.koshitaSketchImageBytes != null
      ? pw.MemoryImage(model.koshitaSketchImageBytes!)
      : null;
  final pw.MemoryImage? sokotsumaSketchImage = model.sokotsumaSketchImageBytes != null
      ? pw.MemoryImage(model.sokotsumaSketchImageBytes!)
      : null;

  // 各フィールドの座標とサイズ
  final pw.TextStyle cellTextStyle = pw.TextStyle(font: font, fontSize: 8);
  final pw.TextStyle titleTextStyle = pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold);

  pw.Page createKouchuhyoPage(KouchuhyoInputModel currentModel, pw.MemoryImage? koshitaImg, pw.MemoryImage? sokotsumaImg) {
    // PDFにテキストを配置するためのインナークラス/関数
    // _buildPdfText の内容をここに直接記述
    pw.Widget buildPdfText(String text, double x, double y, {double fontSize = 10, pw.TextAlign textAlign = pw.TextAlign.left}) {
      return pw.Positioned(
        left: x,
        top: y,
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: fontSize),
          textAlign: textAlign,
        ),
      );
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 0,
        marginBottom: 0,
        marginLeft: 0,
        marginRight: 0,
      ), // 余白なし
      build: (context) {
        return pw.Stack(
          children: [
            // 背景画像（工注票1.jpg）を配置
            pw.Positioned.fill(
              child: pw.Image(backgroundImage, fit: pw.BoxFit.fill),
            ),
            // --- 各入力項目の配置（工注票1.jpgのレイアウトに合わせて細かく調整が必要） ---
            // 例: 出荷日
            buildPdfText(currentModel.shukkaDate, 107, 69, fontSize: 9),
            // 発行日
            buildPdfText(currentModel.hakkoubi, 194, 69, fontSize: 9),
            // 整理番号
            buildPdfText(currentModel.seiriBangou, 400, 48, fontSize: 9),
            // 工番
            buildPdfText(currentModel.koban, 82, 105, fontSize: 9),
            // 仕向先
            buildPdfText(currentModel.shimuke, 220, 105, fontSize: 9),
            // 品名
            buildPdfText(currentModel.hinmei, 220, 126, fontSize: 9),
            // 重量
            buildPdfText(currentModel.weight, 400, 105, fontSize: 9),
            // 数量
            buildPdfText(currentModel.amount, 400, 126, fontSize: 9),
            // ゲル
            buildPdfText(currentModel.gel, 400, 147, fontSize: 9),
            // 形式
            buildPdfText(currentModel.keishiki, 400, 168, fontSize: 9),
            // 構造
            buildPdfText(currentModel.structure, 400, 189, fontSize: 9),
            // 出荷区分 (国内/輸出)
            buildPdfText(currentModel.domestic, 400, 210, fontSize: 9),

            // 内のり寸法
            buildPdfText(currentModel.uchinoriLength, 150, 203, fontSize: 9),
            buildPdfText(currentModel.uchinoriWidth, 230, 203, fontSize: 9),
            buildPdfText(currentModel.uchinoriHeight, 310, 203, fontSize: 9),

            // 滑材
            buildPdfText(currentModel.kSubeW, 100, 245, fontSize: 9),
            buildPdfText(currentModel.kSubeT, 155, 245, fontSize: 9),
            buildPdfText(currentModel.kSubeN, 210, 245, fontSize: 9),

            // すり材/ゲタ材 (Typeによって表示を変更)
            buildPdfText(currentModel.kSuriW, 100, 267, fontSize: 9),
            buildPdfText(currentModel.kSuriT, 155, 267, fontSize: 9),
            buildPdfText(currentModel.kSuriN, 210, 267, fontSize: 9),

            // 天井 - 上板
            buildPdfText(currentModel.tenUeT, 100, 310, fontSize: 9),
            // 天井 - 下板
            buildPdfText(currentModel.tenShitaT, 250, 310, fontSize: 9),

            // 胴さん
            buildPdfText(currentModel.dosanW, 100, 332, fontSize: 9),
            buildPdfText(currentModel.dosanT, 155, 332, fontSize: 9),
            buildPdfText(currentModel.dosanN, 210, 332, fontSize: 9),

            // つまさん
            buildPdfText(currentModel.tsumasan, 250, 332, fontSize: 9),


            // 梱包材 - はり (工注票1.jpgには「梱包材」欄がないため、部材の一番下に仮配置)
            buildPdfText(currentModel.konHari, 550, 275, fontSize: 9),
            // 梱包材 - 押さえ材
            buildPdfText(currentModel.konOsae, 550, 350, fontSize: 9), // 仮の位置
            // 梱包材 - トップ
            buildPdfText(currentModel.konTop, 550, 425, fontSize: 9), // 仮の位置


            // 側ツマ - 外板
            buildPdfText(currentModel.gOuterT, 250, 245, fontSize: 9),
            // 上かまち
            buildPdfText(currentModel.ukamachi, 290, 267, fontSize: 9),
            // 下かまち (すじかい/下かまち)
            buildPdfText(currentModel.sujikamachi, 290, 288, fontSize: 9),
            // 支柱
            buildPdfText(currentModel.shichu, 290, 310, fontSize: 9),
            // はり受
            buildPdfText(currentModel.hariUke, 550, 250, fontSize: 9), // 仮の位置
            // そえ柱
            buildPdfText(currentModel.soeBashira, 550, 300, fontSize: 9), // 仮の位置

            // 腰下図面
            if (koshitaSketchImage != null)
              pw.Positioned(
                left: 70, // X座標を調整
                top: 400, // Y座標を調整
                child: pw.SizedBox( // SizedBox で width と height を指定
                  width: 300, // 幅を調整
                  height: 150, // 高さを調整
                  child: pw.Image(koshitaSketchImage, fit: pw.BoxFit.contain),
                ),
              ),

            // 側ツマ図面
            if (sokotsumaSketchImage != null)
              pw.Positioned(
                left: 450, // X座標を調整
                top: 400, // Y座標を調整
                child: pw.SizedBox( // SizedBox で width と height を指定
                  width: 300, // 幅を調整
                  height: 150, // 高さを調整
                  child: pw.Image(sokotsumaSketchImage, fit: pw.BoxFit.contain),
                ),
              ),

            // 負荷材
            buildPdfText(currentModel.fuka, 550, 325, fontSize: 9), // 仮の位置
            // 根止め材 (各4本) - 工注票1.jpg には個別の欄がないため、一括表示
            buildPdfText('根止め材1: ${currentModel.kNedomL[0]}×${currentModel.kNedomW[0]}×${currentModel.kNedomT[0]}×${currentModel.kNedomN[0]}本', 550, 475, fontSize: 8),
            buildPdfText('根止め材2: ${currentModel.kNedomL[1]}×${currentModel.kNedomW[1]}×${currentModel.kNedomT[1]}×${currentModel.kNedomN[1]}本', 550, 485, fontSize: 8),
            buildPdfText('根止め材3: ${currentModel.kNedomL[2]}×${currentModel.kNedomW[2]}×${currentModel.kNedomT[2]}×${currentModel.kNedomN[2]}本', 550, 495, fontSize: 8),
            buildPdfText('根止め材4: ${currentModel.kNedomL[3]}×${currentModel.kNedomW[3]}×${currentModel.kNedomT[3]}×${currentModel.kNedomN[3]}本', 550, 505, fontSize: 8),

            // 追加部材 (工注票1.jpg には個別の欄がないため、一括表示)
            for (int i = 0; i < currentModel.tsuikaBuzai.length; i++)
              if (currentModel.tsuikaBuzai[i].any((e) => e.isNotEmpty))
                buildPdfText(
                  '追加部材${i + 1}: ${currentModel.tsuikaBuzai[i].join('×')}',
                  550, // X座標を調整
                  525 + (i * 10), // Y座標を調整
                  fontSize: 8,
                ),

          ],
        );
      },
    );
  }

  // A4縦向きにA5サイズ2面（工注票イメージ）を配置するPDF生成
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 0,
        marginBottom: 0,
        marginLeft: 0,
        marginRight: 0,
      ),
      build: (context) => [
        // 1ページ目 (A4の上半分)
        pw.SizedBox(
          width: PdfPageFormat.a4.width,
          height: PdfPageFormat.a4.height / 2, // A4の高さの半分
          child: pw.Transform.scale(
            scale: 0.95, // 必要に応じて調整して、A4の半分に収まるようにする
            child: createKouchuhyoPage(model, koshitaSketchImage, sokotsumaSketchImage),
          ),
        ),
        // 2ページ目 (A4の下半分) - 内容は1ページ目と同じ
        pw.SizedBox(
          width: PdfPageFormat.a4.width,
          height: PdfPageFormat.a4.height / 2, // A4の高さの半分
          child: pw.Transform.scale(
            scale: 0.95, // 必要に応じて調整して、A4の半分に収まるようにする
            child: createKouchuhyoPage(model, koshitaSketchImage, sokotsumaSketchImage),
          ),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

/// PDF保存用（印刷レイアウトと同じ構成）
Future<Uint8List> buildKouchuhyoA5x2Pdf(KouchuhyoInputModel model) async {
  final pdf = pw.Document();
  // PdfGoogleFonts.notoSansJapanese() を使用
  final font = await PdfGoogleFonts.notoSansJapanese(); // 正しい日本語フォントのロード方法

  // 工注票1.jpg の背景画像をロード
  final ByteData imgData = await rootBundle.load('assets/images/kouchuhyo1.jpg');
  final Uint8List imgBytes = imgData.buffer.asUint8List();
  final pw.MemoryImage backgroundImage = pw.MemoryImage(imgBytes);

  // 腰下と側ツマの手書き画像
  final pw.MemoryImage? koshitaSketchImage = model.koshitaSketchImageBytes != null
      ? pw.MemoryImage(model.koshitaSketchImageBytes!)
      : null;
  final pw.MemoryImage? sokotsumaSketchImage = model.sokotsumaSketchImageBytes != null
      ? pw.MemoryImage(model.sokotsumaSketchImageBytes!)
      : null;

  pw.Page createKouchuhyoPage(KouchuhyoInputModel currentModel, pw.MemoryImage? koshitaImg, pw.MemoryImage? sokotsumaImg) {
    // PDFにテキストを配置するためのインナークラス/関数
    // _buildPdfText の内容をここに直接記述
    pw.Widget buildPdfText(String text, double x, double y, {double fontSize = 10, pw.TextAlign textAlign = pw.TextAlign.left}) {
      return pw.Positioned(
        left: x,
        top: y,
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: fontSize),
          textAlign: textAlign,
        ),
      );
    }
    return pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 0,
        marginBottom: 0,
        marginLeft: 0,
        marginRight: 0,
      ), // 余白なし
      build: (context) {
        return pw.Stack(
          children: [
            // 背景画像（工注票1.jpg）を配置
            pw.Positioned.fill(
              child: pw.Image(backgroundImage, fit: pw.BoxFit.fill),
            ),
            // --- 各入力項目の配置（工注票1.jpgのレイアウトに合わせて細かく調整が必要） ---
            // 例: 出荷日
            buildPdfText(currentModel.shukkaDate, 107, 69, fontSize: 9),
            // 発行日
            buildPdfText(currentModel.hakkoubi, 194, 69, fontSize: 9),
            // 整理番号
            buildPdfText(currentModel.seiriBangou, 400, 48, fontSize: 9),
            // 工番
            buildPdfText(currentModel.koban, 82, 105, fontSize: 9),
            // 仕向先
            buildPdfText(currentModel.shimuke, 220, 105, fontSize: 9),
            // 品名
            buildPdfText(currentModel.hinmei, 220, 126, fontSize: 9),
            // 重量
            buildPdfText(currentModel.weight, 400, 105, fontSize: 9),
            // 数量
            buildPdfText(currentModel.amount, 400, 126, fontSize: 9),
            // ゲル
            buildPdfText(currentModel.gel, 400, 147, fontSize: 9),
            // 形式
            buildPdfText(currentModel.keishiki, 400, 168, fontSize: 9),
            // 構造
            buildPdfText(currentModel.structure, 400, 189, fontSize: 9),
            // 出荷区分 (国内/輸出)
            buildPdfText(currentModel.domestic, 400, 210, fontSize: 9),

            // 内のり寸法
            buildPdfText(currentModel.uchinoriLength, 150, 203, fontSize: 9),
            buildPdfText(currentModel.uchinoriWidth, 230, 203, fontSize: 9),
            buildPdfText(currentModel.uchinoriHeight, 310, 203, fontSize: 9),

            // 滑材
            buildPdfText(currentModel.kSubeW, 100, 245, fontSize: 9),
            buildPdfText(currentModel.kSubeT, 155, 245, fontSize: 9),
            buildPdfText(currentModel.kSubeN, 210, 245, fontSize: 9),

            // すり材/ゲタ材
            buildPdfText(currentModel.kSuriW, 100, 267, fontSize: 9),
            buildPdfText(currentModel.kSuriT, 155, 267, fontSize: 9),
            buildPdfText(currentModel.kSuriN, 210, 267, fontSize: 9),

            // 天井 - 上板
            buildPdfText(currentModel.tenUeT, 100, 310, fontSize: 9),
            // 天井 - 下板
            buildPdfText(currentModel.tenShitaT, 250, 310, fontSize: 9),

            // 胴さん
            buildPdfText(currentModel.dosanW, 100, 332, fontSize: 9),
            buildPdfText(currentModel.dosanT, 155, 332, fontSize: 9),
            buildPdfText(currentModel.dosanN, 210, 332, fontSize: 9),

            // つまさん
            buildPdfText(currentModel.tsumasan, 250, 332, fontSize: 9),


            // 梱包材 - はり
            buildPdfText(currentModel.konHari, 550, 275, fontSize: 9),
            // 梱包材 - 押さえ材
            buildPdfText(currentModel.konOsae, 550, 350, fontSize: 9), // 仮の位置
            // 梱包材 - トップ
            buildPdfText(currentModel.konTop, 550, 425, fontSize: 9), // 仮の位置


            // 側ツマ - 外板
            buildPdfText(currentModel.gOuterT, 250, 245, fontSize: 9),
            // 上かまち
            buildPdfText(currentModel.ukamachi, 290, 267, fontSize: 9),
            // 下かまち (すじかい/下かまち)
            buildPdfText(currentModel.sujikamachi, 290, 288, fontSize: 9),
            // 支柱
            buildPdfText(currentModel.shichu, 290, 310, fontSize: 9),
            // はり受
            buildPdfText(currentModel.hariUke, 550, 250, fontSize: 9), // 仮の位置
            // そえ柱
            buildPdfText(currentModel.soeBashira, 550, 300, fontSize: 9), // 仮の位置

            // 腰下図面
            if (koshitaSketchImage != null)
              pw.Positioned(
                left: 70, // X座標を調整
                top: 400, // Y座標を調整
                child: pw.SizedBox( // SizedBox で width と height を指定
                  width: 300, // 幅を調整
                  height: 150, // 高さを調整
                  child: pw.Image(koshitaSketchImage, fit: pw.BoxFit.contain),
                ),
              ),

            // 側ツマ図面
            if (sokotsumaSketchImage != null)
              pw.Positioned(
                left: 450, // X座標を調整
                top: 400, // Y座標を調整
                child: pw.SizedBox( // SizedBox で width と height を指定
                  width: 300, // 幅を調整
                  height: 150, // 高さを調整
                  child: pw.Image(sokotsumaSketchImage, fit: pw.BoxFit.contain),
                ),
              ),

            // 負荷材
            buildPdfText(currentModel.fuka, 550, 325, fontSize: 9), // 仮の位置
            // 根止め材 (各4本)
            buildPdfText('根止め材1: ${currentModel.kNedomL[0]}×${currentModel.kNedomW[0]}×${currentModel.kNedomT[0]}×${currentModel.kNedomN[0]}本', 550, 475, fontSize: 8),
            buildPdfText('根止め材2: ${currentModel.kNedomL[1]}×${currentModel.kNedomW[1]}×${currentModel.kNedomT[1]}×${currentModel.kNedomN[1]}本', 550, 485, fontSize: 8),
            buildPdfText('根止め材3: ${currentModel.kNedomL[2]}×${currentModel.kNedomW[2]}×${currentModel.kNedomT[2]}×${currentModel.kNedomN[2]}本', 550, 495, fontSize: 8),
            buildPdfText('根止め材4: ${currentModel.kNedomL[3]}×${currentModel.kNedomW[3]}×${currentModel.kNedomT[3]}×${currentModel.kNedomN[3]}本', 550, 505, fontSize: 8),

            // 追加部材
            for (int i = 0; i < model.tsuikaBuzai.length; i++)
              if (model.tsuikaBuzai[i].any((e) => e.isNotEmpty))
                buildPdfText(
                  '追加部材${i + 1}: ${model.tsuikaBuzai[i].join('×')}',
                  550, // X座標を調整
                  525 + (i * 10), // Y座標を調整
                  fontSize: 8,
                ),
          ],
        );
      },
    );
  }


  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 0,
        marginBottom: 0,
        marginLeft: 0,
        marginRight: 0,
      ),
      build: (context) => [
        // 1ページ目 (A4の上半分)
        pw.SizedBox(
          width: PdfPageFormat.a4.width,
          height: PdfPageFormat.a4.height / 2, // A4の高さの半分
          child: pw.Transform.scale(
            scale: 0.95, // 必要に応じて調整して、A4の半分に収まるようにする
            child: createKouchuhyoPage(model, koshitaSketchImage, sokotsumaSketchImage),
          ),
        ),
        // 2ページ目 (A4の下半分) - 内容は1ページ目と同じ
        pw.SizedBox(
          width: PdfPageFormat.a4.width,
          height: PdfPageFormat.a4.height / 2, // A4の高さの半分
          child: pw.Transform.scale(
            scale: 0.95, // 必要に応じて調整して、A4の半分に収まるようにする
            child: createKouchuhyoPage(model, koshitaSketchImage, sokotsumaSketchImage),
          ),
        ),
      ],
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