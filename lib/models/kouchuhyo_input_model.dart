import 'dart:typed_data';

class KouchuhyoInputModel {
  // 基本情報
  final String seiriBangou;
  final String shukkaDate;
  final String hakkoubi;
  final String koban;
  final String shimuke;
  final String hinmei;
  final String weight;
  final String amount;
  final String keishiki;
  final String structure;
  final String domestic;

  // 寸法
  final String uchinoriLength;
  final String uchinoriWidth;
  final String uchinoriHeight;
  final String sotonoriLength;
  final String sotonoriWidth;
  final String sotonoriHeight;

  // 側・ツマ部
  final String gOuterT;
  final String gUkamW;
  final String gUkamT;
  final String gSujiW;
  final String gSujiT;
  final String gShitaW;
  final String gShitaT;
  final String gShichuW;
  final String gShichuT;
  final String gDoW;
  final String gDoT;
  final String gDoN;
  final String gTsumaW;
  final String gTsumaT;
  final String gHariukeW;
  final String gHariukeT;
  final String gSoeW;
  final String gSoeT;

  // 腰下部
  final String kSubeW;
  final String kSubeT;
  final String kSubeN;
  final String kHeaderW;
  final String kHeaderT;
  final String kHeaderStop;
  final String kSuriType;
  final String kSuriW;
  final String kSuriT;
  final String kSuriN;
  final String kYukaT;
  final String kFukaW;
  final String kFukaT;
  final String kFukaN;
  final List<String> kNedomW;
  final List<String> kNedomT;
  final List<String> kNedomN;

  // 梱包材
  final String konHariW;
  final String konHariT;
  final String konOsaeW;
  final String konOsaeT;
  final String konTopL;
  final String konTopW;
  final String konTopT;
  final String konTopN;

  // 天井
  final String tenUeT;
  final String tenShitaT;

  // 追加部材
  final List<String> tsuikaName;
  final List<String> tsuikaL;
  final List<String> tsuikaW;
  final List<String> tsuikaT;
  final List<String> tsuikaN;

  // 手書き図（画像）
  final Uint8List? sketchImageBytes;

  KouchuhyoInputModel({
    required this.seiriBangou,
    required this.shukkaDate,
    required this.hakkoubi,
    required this.koban,
    required this.shimuke,
    required this.hinmei,
    required this.weight,
    required this.amount,
    required this.keishiki,
    required this.structure,
    required this.domestic,
    required this.uchinoriLength,
    required this.uchinoriWidth,
    required this.uchinoriHeight,
    required this.sotonoriLength,
    required this.sotonoriWidth,
    required this.sotonoriHeight,
    required this.gOuterT,
    required this.gUkamW,
    required this.gUkamT,
    required this.gSujiW,
    required this.gSujiT,
    required this.gShitaW,
    required this.gShitaT,
    required this.gShichuW,
    required this.gShichuT,
    required this.gDoW,
    required this.gDoT,
    required this.gDoN,
    required this.gTsumaW,
    required this.gTsumaT,
    required this.gHariukeW,
    required this.gHariukeT,
    required this.gSoeW,
    required this.gSoeT,
    required this.kSubeW,
    required this.kSubeT,
    required this.kSubeN,
    required this.kHeaderW,
    required this.kHeaderT,
    required this.kHeaderStop,
    required this.kSuriType,
    required this.kSuriW,
    required this.kSuriT,
    required this.kYukaT,
    required this.kFukaW,
    required this.kFukaT,
    required this.kFukaN,
    required this.kNedomW,
    required this.kNedomT,
    required this.kNedomN,
    required this.konHariW,
    required this.konHariT,
    required this.konOsaeW,
    required this.konOsaeT,
    required this.konTopL,
    required this.konTopW,
    required this.konTopT,
    required this.konTopN,
    required this.tenUeT,
    required this.tenShitaT,
    required this.tsuikaName,
    required this.tsuikaL,
    required this.tsuikaW,
    required this.tsuikaT,
    required this.tsuikaN,
    this.sketchImageBytes,
  });

  // --- プレビュー用 Getter 追加 ---
  String get kouzou => structure;
  String get kSube => '$kSubeW×$kSubeT×$kSubeN';
  String get hZai => '$kHeaderW×$kHeaderT';
  String get suri => '$kSuriW×$kSuriT×$kSuriN';
  String get geta => '$kHeaderW×$kHeaderT';
  String get yuka => kYukaT;
  String get fuka => '$kFukaW×$kFukaT×$kFukaN';

  String get gaiban => gOuterT;
  String get ukamachi => '$gUkamW×$gUkamT';
  String get sujikamachi => '$gSujiW×$gSujiT / $gShitaW×$gShitaT';
  String get shichu => '$gShichuW×$gShichuT';
  String get hariUke => '$gHariukeW×$gHariukeT';
  String get soeBashira => '$gSoeW×$gSoeT';
  String get dosan => '$gDoW×$gDoT';
  String get tsumasan => '$gTsumaW×$gTsumaT';

  String get ueita => tenUeT;
  String get shitaIta => tenShitaT;

  String get konHari => '$konHariW×$konHariT';
  String get konOsae => '$konOsaeW×$konOsaeT';
  String get konTop => '$konTopL×$konTopW×$konTopT×$konTopN';
}
Map<String, dynamic> toMap() => {
  '発送日': shukkaDate,
  '発行日': hakkoubi,
  '整理番号': seiriBangou,
  '工番': koban,
  '仕向先': shimuke,
  '品名': hinmei,
  '重量': weight,
  '数量': amount,
  '形式': keishiki,
  '構造': structure,
  '国内/輸出': domestic,
  // 必要に応じて他の項目も追加
};

static KouchuhyoInputModel fromMap(Map<String, dynamic> map) {
  return KouchuhyoInputModel(
    shukkaDate: map['発送日'] ?? '',
    hakkoubi: map['発行日'] ?? '',
    seiriBangou: map['整理番号'] ?? '',
    koban: map['工番'] ?? '',
    shimuke: map['仕向先'] ?? '',
    hinmei: map['品名'] ?? '',
    weight: map['重量'] ?? '',
    amount: map['数量'] ?? '',
    keishiki: map['形式'] ?? '',
    structure: map['構造'] ?? '',
    domestic: map['国内/輸出'] ?? '',
    // 他の項目も必要に応じて追記
    // リスト項目は空リストでもOKにしておく
    uchinoriLength: '',
    uchinoriWidth: '',
    uchinoriHeight: '',
    sotonoriLength: '',
    sotonoriWidth: '',
    sotonoriHeight: '',
    gOuterT: '', gUkamW: '', gUkamT: '', gSujiW: '', gSujiT: '',
    gShitaW: '', gShitaT: '', gShichuW: '', gShichuT: '',
    gDoW: '', gDoT: '', gDoN: '', gTsumaW: '', gTsumaT: '',
    gHariukeW: '', gHariukeT: '', gSoeW: '', gSoeT: '',
    kSubeW: '', kSubeT: '', kSubeN: '', kHeaderW: '', kHeaderT: '',
    kHeaderStop: '', kSuriType: '', kSuriW: '', kSuriT: '', kSuriN: '',
    kYukaT: '', kFukaW: '', kFukaT: '', kFukaN: '',
    kNedomW: List.filled(4, ''),
    kNedomT: List.filled(4, ''),
    kNedomN: List.filled(4, ''),
    konHariW: '', konHariT: '', konOsaeW: '', konOsaeT: '',
    konTopL: '', konTopW: '', konTopT: '', konTopN: '',
    tenUeT: '', tenShitaT: '',
    tsuikaName: List.filled(5, ''),
    tsuikaL: List.filled(5, ''),
    tsuikaW: List.filled(5, ''),
    tsuikaT: List.filled(5, ''),
    tsuikaN: List.filled(5, ''),
    sketchImageBytes: null,
  );
}
