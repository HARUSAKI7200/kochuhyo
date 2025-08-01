// lib/screens/template_files_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/screens/order_form_screen.dart';

class TemplateFilesScreen extends StatefulWidget {
  final String folderPath;

  const TemplateFilesScreen({super.key, required this.folderPath});

  @override
  State<TemplateFilesScreen> createState() => _TemplateFilesScreenState();
}

class _TemplateFilesScreenState extends State<TemplateFilesScreen> {
  late Future<List<File>> _templateFilesFuture;

  @override
  void initState() {
    super.initState();
    _templateFilesFuture = _getTemplateFiles();
  }

  String get _folderName {
    return widget.folderPath.split(Platform.pathSeparator).last;
  }

  Future<List<File>> _getTemplateFiles() async {
    final directory = Directory(widget.folderPath);
    final List<File> files = [];
    
    if (await directory.exists()) {
      final entities = directory.listSync();
      for (var entity in entities) {
        if (entity is File && entity.path.endsWith('.json')) {
          files.add(entity);
        }
      }
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    }
    return files;
  }

  Future<void> _loadTemplateAndNavigate(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final kochuhyoData = KochuhyoData.fromJson(jsonData);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderFormScreen(templateData: kochuhyoData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('テンプレートの読み込みに失敗しました: $e')),
      );
    }
  }

  Future<void> _deleteTemplate(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${_getFileName(file)}」を本当に削除しますか？'),
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
        await file.delete();
        setState(() {
          _templateFilesFuture = _getTemplateFiles();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('テンプレートを削除しました。'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('削除に失敗しました: $e')),
        );
      }
    }
  }

  String _getFileName(File file) {
    return file.path.split(Platform.pathSeparator).last.replaceAll('.json', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_folderName のテンプレート'),
      ),
      body: FutureBuilder<List<File>>(
        future: _templateFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('この製品のテンプレートはありません。'));
          }
          
          final files = snapshot.data!;
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(_getFileName(file)),
                  subtitle: Text('更新日時: ${file.lastModifiedSync()}'),
                  onTap: () => _loadTemplateAndNavigate(file),
                  onLongPress: () => _deleteTemplate(file),
                ),
              );
            },
          );
        },
      ),
    );
  }
}