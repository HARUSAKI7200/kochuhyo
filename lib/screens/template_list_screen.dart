// lib/screens/template_list_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kouchuhyo_app/screens/template_files_screen.dart'; // 次に作る画面をインポート

class TemplateListScreen extends StatefulWidget {
  const TemplateListScreen({super.key});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  late Future<List<Directory>> _productFoldersFuture;

  @override
  void initState() {
    super.initState();
    _productFoldersFuture = _getProductFolders();
  }

  // 製品フォルダの一覧を取得する
  Future<List<Directory>> _getProductFolders() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<Directory> folders = [];
    
    final entities = directory.listSync();
    for (var entity in entities) {
      if (entity is Directory) {
        folders.add(entity);
      }
    }
    // 名前順に並び替え
    folders.sort((a, b) => a.path.compareTo(b.path));
    return folders;
  }

  // ★★★ ここからが今回の修正箇所です ★★★

  // フォルダを削除する処理
  Future<void> _deleteFolder(Directory folder) async {
    final folderName = _getFolderName(folder);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フォルダの削除'),
        content: Text('「$folderName」フォルダを削除しますか？\nフォルダ内のすべてのテンプレートも削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // フォルダと中身を再帰的に削除
        await folder.delete(recursive: true);
        setState(() {
          // フォルダリストを再取得してUIを更新
          _productFoldersFuture = _getProductFolders();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('「$folderName」フォルダを削除しました。'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('フォルダの削除に失敗しました: $e')),
          );
        }
      }
    }
  }
  // ★★★ ここまでが今回の修正箇所です ★★★

  // フォルダ名を分かりやすく整形する
  String _getFolderName(Directory folder) {
    return folder.path.split(Platform.pathSeparator).last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('製品を選択'),
      ),
      body: FutureBuilder<List<Directory>>(
        future: _productFoldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                '保存された製品フォルダがありません。\n入力画面からテンプレートを保存してください。',
                textAlign: TextAlign.center,
              ),
            );
          }
          
          final folders = snapshot.data!;
          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(_getFolderName(folder)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // フォルダ内のテンプレート一覧画面に遷移
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TemplateFilesScreen(folderPath: folder.path),
                      )
                    ).then((_) {
                      // 戻ってきたときにリストを更新する
                      setState(() {
                        _productFoldersFuture = _getProductFolders();
                      });
                    });
                  },
                  // ★★★ ここからが今回の修正箇所です ★★★
                  onLongPress: () {
                    _deleteFolder(folder);
                  },
                  // ★★★ ここまでが今回の修正箇所です ★★★
                ),
              );
            },
          );
        },
      ),
    );
  }
}