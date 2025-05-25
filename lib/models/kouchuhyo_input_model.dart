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
  final String gel; // 追加

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
  final String gShichuW;
  final String gShichuT;
  final String gDoW;
  final String gDoT;
  final String gDoN;
  final String gTsumaW;
  final String gTsumaT;
  final String gHariukeW;
  final String gHariukeT;
  final String gHariukeEmbed; // 追加
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
  final List<String> kNedomL; // 追加
  final List<String> kNedomW;
  final List<String> kNedomT;
  final List<String> kNedomN;

  // 梱包材
  final String konHariW;
  final String konHariT;
  final String konHariN; // 追加
  final String konOsaeL; // 追加
  final String konOsaeW;
  final String konOsaeT;
  final String konOsaeN; // 追加
  final String konTopL;
  final String konTopW;
  final String konTopT;
  final String konTopN;

  // 天井
  final String tenUeT;
  final String tenShitaT;

  // 追加部材
  final List<List<String>> tsuikaBuzai; // List<String>からList<List<String>>に変更

  // 手書き図（画像）
  final Uint8List? koshitaSketchImageBytes; // 腰下の手書き画像
  final Uint8List? sokotsumaSketchImageBytes; // 側ツマの手書き画像

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
    required this.gel,
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
    required this.gShichuW,
    required this.gShichuT,
    required this.gDoW,
    required this.gDoT,
    required this.gDoN,
    required this.gTsumaW,
    required this.gTsumaT,
    required this.gHariukeW,
    required this.gHariukeT,
    required this.gHariukeEmbed,
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
    required this.kSuriN,
    required this.kYukaT,
    required this.kFukaW,
    required this.kFukaT,
    required this.kFukaN,
    required this.kNedomL,
    required this.kNedomW,
    required this.kNedomT,
    required this.kNedomN,
    required this.konHariW,
    required this.konHariT,
    required this.konHariN,
    required this.konOsaeL,
    required this.konOsaeW,
    required this.konOsaeT,
    required this.konOsaeN,
    required this.konTopL,
    required this.konTopW,
    required this.konTopT,
    required this.konTopN,
    required this.tenUeT,
    required this.tenShitaT,
    required this.tsuikaBuzai,
    this.koshitaSketchImageBytes,
    this.sokotsumaSketchImageBytes,
  });

  // 空のモデルを生成するファクトリコンストラクタ
  factory KouchuhyoInputModel.empty() {
    return KouchuhyoInputModel(
      seiriBangou: '',
      shukkaDate: '',
      hakkoubi: '',
      koban: '',
      shimuke: '',
      hinmei: '',
      weight: '',
      amount: '',
      keishiki: '',
      structure: '',
      domestic: '',
      gel: '',
      uchinoriLength: '',
      uchinoriWidth: '',
      uchinoriHeight: '',
      sotonoriLength: '',
      sotonoriWidth: '',
      sotonoriHeight: '',
      gOuterT: '', gUkamW: '', gUkamT: '', gSujiW: '', gSujiT: '',
      gShichuW: '', gShichuT: '', gDoW: '', gDoT: '', gDoN: '',
      gTsumaW: '', gTsumaT: '', gHariukeW: '', gHariukeT: '', gHariukeEmbed: '',
      gSoeW: '', gSoeT: '',
      kSubeW: '', kSubeT: '', kSubeN: '', kHeaderW: '', kHeaderT: '',
      kHeaderStop: '', kSuriType: '', kSuriW: '', kSuriT: '', kSuriN: '',
      kYukaT: '', kFukaW: '', kFukaT: '', kFukaN: '',
      kNedomL: List.filled(4, ''),
      kNedomW: List.filled(4, ''),
      kNedomT: List.filled(4, ''),
      kNedomN: List.filled(4, ''),
      konHariW: '', konHariT: '', konHariN: '', konOsaeL: '', konOsaeW: '',
      konOsaeT: '', konOsaeN: '', konTopL: '', konTopW: '', konTopT: '', konTopN: '',
      tenUeT: '', tenShitaT: '',
      tsuikaBuzai: List.generate(5, (_) => List.filled(5, '')),
      koshitaSketchImageBytes: null,
      sokotsumaSketchImageBytes: null,
    );
  }

  // --- プレビュー用 Getter ---
  String get kouzou => structure;
  String get kSube => '$kSubeW×$kSubeT×$kSubeN';
  String get hZai => '$kHeaderW×$kHeaderT';
  String get suri => '$kSuriW×$kSuriT×$kSuriN';
  String get geta => '$kHeaderW×$kHeaderT';
  String get yuka => kYukaT;
  String get fuka => '$kFukaW×$kFukaT×$kFukaN';

  String get gaiban => gOuterT;
  String get ukamachi => '$gUkamW×$gUkamT';
  String get sujikamachi => '$gSujiW×$gSujiT';
  String get shichu => '$gShichuW×$gShichuT';
  String get hariUke => '$gHariukeW×$gHariukeT (${gHariukeEmbed})';
  String get soeBashira => '$gSoeW×$gSoeT';
  String get dosan => '$gDoW×$gDoT×$gDoN';
  String get tsumasan => '$gTsumaW×$gTsumaT';

  String get ueita => tenUeT;
  String get shitaIta => tenShitaT;

  String get konHari => '$konHariW×$konHariT×$konHariN本';
  String get konOsae => '$konOsaeL×$konOsaeW×$konOsaeT×$konOsaeN本';
  String get konTop => '$konTopL×$konTopW×$konTopT×$konTopN本';


  // Mapに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'seiriBangou': seiriBangou,
      'shukkaDate': shukkaDate,
      'hakkoubi': hakkoubi,
      'koban': koban,
      'shimuke': shimuke,
      'hinmei': hinmei,
      'weight': weight,
      'amount': amount,
      'keishiki': keishiki,
      'structure': structure,
      'domestic': domestic,
      'gel': gel,
      'uchinoriLength': uchinoriLength,
      'uchinoriWidth': uchinoriWidth,
      'uchinoriHeight': uchinoriHeight,
      'sotonoriLength': sotonoriLength,
      'sotonoriWidth': sotonoriWidth,
      'sotonoriHeight': sotonoriHeight,
      'gOuterT': gOuterT,
      'gUkamW': gUkamW,
      'gUkamT': gUkamT,
      'gSujiW': gSujiW,
      'gSujiT': gSujiT,
      'gShichuW': gShichuW,
      'gShichuT': gShichuT,
      'gDoW': gDoW,
      'gDoT': gDoT,
      'gDoN': gDoN,
      'gTsumaW': gTsumaW,
      'gTsumaT': gTsumaT,
      'gHariukeW': gHariukeW,
      'gHariukeT': gHariukeT,
      'gHariukeEmbed': gHariukeEmbed,
      'gSoeW': gSoeW,
      'gSoeT': gSoeT,
      'kSubeW': kSubeW,
      'kSubeT': kSubeT,
      'kSubeN': kSubeN,
      'kHeaderW': kHeaderW,
      'kHeaderT': kHeaderT,
      'kHeaderStop': kHeaderStop,
      'kSuriType': kSuriType,
      'kSuriW': kSuriW,
      'kSuriT': kSuriT,
      'kSuriN': kSuriN,
      'kYukaT': kYukaT,
      'kFukaW': kFukaW,
      'kFukaT': kFukaT,
      'kFukaN': kFukaN,
      'kNedomL': kNedomL,
      'kNedomW': kNedomW,
      'kNedomT': kNedomT,
      'kNedomN': kNedomN,
      'konHariW': konHariW,
      'konHariT': konHariT,
      'konHariN': konHariN,
      'konOsaeL': konOsaeL,
      'konOsaeW': konOsaeW,
      'konOsaeT': konOsaeT,
      'konOsaeN': konOsaeN,
      'konTopL': konTopL,
      'konTopW': konTopW,
      'konTopT': konTopT,
      'konTopN': konTopN,
      'tenUeT': tenUeT,
      'tenShitaT': tenShitaT,
      'tsuikaBuzai': tsuikaBuzai,
      'koshitaSketchImageBytes': koshitaSketchImageBytes,
      'sokotsumaSketchImageBytes': sokotsumaSketchImageBytes,
    };
  }

  // Mapからインスタンスを生成するファクトリコンストラクタ
  factory KouchuhyoInputModel.fromMap(Map<String, dynamic> map) {
    return KouchuhyoInputModel(
      seiriBangou: map['seiriBangou'] ?? '',
      shukkaDate: map['shukkaDate'] ?? '',
      hakkoubi: map['hakkoubi'] ?? '',
      koban: map['koban'] ?? '',
      shimuke: map['shimuke'] ?? '',
      hinmei: map['hinmei'] ?? '',
      weight: map['weight'] ?? '',
      amount: map['amount'] ?? '',
      keishiki: map['keishiki'] ?? '',
      structure: map['structure'] ?? '',
      domestic: map['domestic'] ?? '',
      gel: map['gel'] ?? '',
      uchinoriLength: map['uchinoriLength'] ?? '',
      uchinoriWidth: map['uchinoriWidth'] ?? '',
      uchinoriHeight: map['uchinoriHeight'] ?? '',
      sotonoriLength: map['sotonoriLength'] ?? '',
      sotonoriWidth: map['sotonoriWidth'] ?? '',
      sotonoriHeight: map['sotonoriHeight'] ?? '',
      gOuterT: map['gOuterT'] ?? '',
      gUkamW: map['gUkamW'] ?? '',
      gUkamT: map['gUkamT'] ?? '',
      gSujiW: map['gSujiW'] ?? '',
      gSujiT: map['gSujiT'] ?? '',
      gShichuW: map['gShichuW'] ?? '',
      gShichuT: map['gShichuT'] ?? '',
      gDoW: map['gDoW'] ?? '',
      gDoT: map['gDoT'] ?? '',
      gDoN: map['gDoN'] ?? '',
      gTsumaW: map['gTsumaW'] ?? '',
      gTsumaT: map['gTsumaT'] ?? '',
      gHariukeW: map['gHariukeW'] ?? '',
      gHariukeT: map['gHariukeT'] ?? '',
      gHariukeEmbed: map['gHariukeEmbed'] ?? '',
      gSoeW: map['gSoeW'] ?? '',
      gSoeT: map['gSoeT'] ?? '',
      kSubeW: map['kSubeW'] ?? '',
      kSubeT: map['kSubeT'] ?? '',
      kSubeN: map['kSubeN'] ?? '',
      kHeaderW: map['kHeaderW'] ?? '',
      kHeaderT: map['kHeaderT'] ?? '',
      kHeaderStop: map['kHeaderStop'] ?? '',
      kSuriType: map['kSuriType'] ?? '',
      kSuriW: map['kSuriW'] ?? '',
      kSuriT: map['kSuriT'] ?? '',
      kSuriN: map['kSuriN'] ?? '',
      kYukaT: map['kYukaT'] ?? '',
      kFukaW: map['kFukaW'] ?? '',
      kFukaT: map['kFukaT'] ?? '',
      kFukaN: map['kFukaN'] ?? '',
      kNedomL: List<String>.from(map['kNedomL'] ?? List.filled(4, '')),
      kNedomW: List<String>.from(map['kNedomW'] ?? List.filled(4, '')),
      kNedomT: List<String>.from(map['kNedomT'] ?? List.filled(4, '')),
      kNedomN: List<String>.from(map['kNedomN'] ?? List.filled(4, '')),
      konHariW: map['konHariW'] ?? '',
      konHariT: map['konHariT'] ?? '',
      konHariN: map['konHariN'] ?? '',
      konOsaeL: map['konOsaeL'] ?? '',
      konOsaeW: map['konOsaeW'] ?? '',
      konOsaeT: map['konOsaeT'] ?? '',
      konOsaeN: map['konOsaeN'] ?? '',
      konTopL: map['konTopL'] ?? '',
      konTopW: map['konTopW'] ?? '',
      konTopT: map['konTopT'] ?? '',
      konTopN: map['konTopN'] ?? '',
      tenUeT: map['tenUeT'] ?? '',
      tenShitaT: map['tenShitaT'] ?? '',
      tsuikaBuzai: (map['tsuikaBuzai'] as List<dynamic>?)
              ?.map((row) => List<String>.from(row))
              .toList() ??
          List.generate(5, (_) => List.filled(5, '')),
      koshitaSketchImageBytes: map['koshitaSketchImageBytes'] != null
          ? Uint8List.fromList(List<int>.from(map['koshitaSketchImageBytes']))
          : null,
      sokotsumaSketchImageBytes: map['sokotsumaSketchImageBytes'] != null
          ? Uint8List.fromList(List<int>.from(map['sokotsumaSketchImageBytes']))
          : null,
    );
  }
}