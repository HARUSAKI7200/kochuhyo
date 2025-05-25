import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kouchuhyo_app/models/kouchuhyo_template.dart'; // kouchuhyo_app に戻す

class TemplateStorage {
  static const _key = 'kouchuhyo_templates';

  static Future<void> saveTemplate(KouchuhyoTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(template.toJson()));
    await prefs.setStringList(_key, list);
  }

  static Future<List<KouchuhyoTemplate>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => KouchuhyoTemplate.fromJson(jsonDecode(s))).toList();
  }
}