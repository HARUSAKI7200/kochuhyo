import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/pages/kouchuhyo_input_page.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/models/kouchuhyo_template.dart'; // kouchuhyo_app に戻す
import 'package:kouchuhyo_app/utils/template_storage.dart'; // kouchuhyo_app に戻す

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '工注票アプリ',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<KouchuhyoTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates = await TemplateStorage.loadTemplates();
    setState(() => _templates = templates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('工注票テンプレート選択')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_templates.isNotEmpty)
              DropdownButton<KouchuhyoTemplate>(
                hint: const Text('テンプレートを選択'),
                items: _templates.map((tpl) {
                  return DropdownMenuItem(
                    value: tpl,
                    child: Text(tpl.name),
                  );
                }).toList(),
                onChanged: (tpl) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KouchuhyoInputPage(preloadValues: tpl!.values),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('空白から入力'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KouchuhyoInputPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}