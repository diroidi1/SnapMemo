import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/memo.dart';

class MemoRepository {
  static const _metadataFileName = 'memos.json';
  static const _imagesDirName = 'images';
  final _uuid = const Uuid();

  Directory? _appDir;
  File? _metadataFile;
  Directory? _imagesDir;

  Future<void> _ensureInit() async {
    if (_appDir != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _appDir = dir;
    _imagesDir = Directory('${dir.path}/$_imagesDirName');
    if (!await _imagesDir!.exists()) {
      await _imagesDir!.create(recursive: true);
    }
    _metadataFile = File('${dir.path}/$_metadataFileName');
    if (!await _metadataFile!.exists()) {
      await _metadataFile!.writeAsString(jsonEncode(<Map<String, dynamic>>[]));
    }
  }

  Future<List<Memo>> loadMemos() async {
    await _ensureInit();
    final text = await _metadataFile!.readAsString();
    final list = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
    return list.map(Memo.fromMap).toList();
  }

  Future<int> getStorageUsageBytes() async {
    await _ensureInit();
    int total = 0;
    if (_imagesDir != null && await _imagesDir!.exists()) {
      await for (final f in _imagesDir!.list(recursive: true)) {
        if (f is File) {
          total += await f.length();
        }
      }
    }
    return total;
  }

  Future<void> saveMemos(List<Memo> memos) async {
    await _ensureInit();
    final list = memos.map((m) => m.toMap()).toList();
    await _metadataFile!.writeAsString(jsonEncode(list));
  }

  Future<Memo> addMemo({required File imageFile, String? note, Duration ttl = const Duration(days: 14)}) async {
    await _ensureInit();
    final id = _uuid.v4();
    final created = DateTime.now();
    final expires = created.add(ttl);
    final ext = imageFile.path.split('.').last;
    final target = File('${_imagesDir!.path}/$id.$ext');
    await imageFile.copy(target.path);
    final memo = Memo(id: id, filePath: target.path, note: note, createdAt: created, expiresAt: expires);
    final memos = await loadMemos();
    memos.add(memo);
    await saveMemos(memos);
    return memo;
  }

  Future<void> deleteMemo(String id) async {
    await _ensureInit();
    final memos = await loadMemos();
    final memo = memos.firstWhere((m) => m.id == id, orElse: () => throw StateError('Memo not found'));
    final file = File(memo.filePath);
    if (await file.exists()) {
      await file.delete();
    }
    final updated = memos.where((m) => m.id != id).toList();
    await saveMemos(updated);
  }

  Future<void> deleteAll() async {
    await _ensureInit();
    // Delete all images
    if (_imagesDir != null && await _imagesDir!.exists()) {
      await for (final f in _imagesDir!.list(recursive: true)) {
        if (f is File) {
          await f.delete();
        }
      }
    }
    // Clear metadata
    await _metadataFile!.writeAsString(jsonEncode(<Map<String, dynamic>>[]));
  }

  Future<int> purgeExpired() async {
    await _ensureInit();
    final memos = await loadMemos();
    int removed = 0;
    for (final memo in memos.where((m) => m.isExpired).toList()) {
      final file = File(memo.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      memos.removeWhere((m) => m.id == memo.id);
      removed++;
    }
    await saveMemos(memos);
    return removed;
  }
}
