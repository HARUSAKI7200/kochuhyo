// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/screens/order_form_screen.dart';
import 'package:kouchuhyo_app/screens/template_list_screen.dart'; // ★★★ 1. 新しい画面をインポート ★★★

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 工注票作成ボタン
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('工注票作成'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  // ★★★ 2. データを渡さずに画面遷移（新規作成） ★★★
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrderFormScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // テンプレート呼び出しボタン
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('テンプレート呼び出し'),
                 style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  // ★★★ 3. テンプレート一覧画面へ遷移 ★★★
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TemplateListScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}