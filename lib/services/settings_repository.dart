import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/settings.dart';

class SettingsRepository {
  static const _fileName = 'settings.json';
  File? _file;

  Future<void> _ensureInit() async {
    if (_file != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/$_fileName');
    if (!await _file!.exists()) {
      await _file!.writeAsString(Settings(defaultTtl: const Duration(days: 14), showNoteInput: true).toJson());
    }
  }

  Future<Settings> load() async {
    await _ensureInit();
    final text = await _file!.readAsString();
    return Settings.fromJson(text);
  }

  Future<void> save(Settings settings) async {
    await _ensureInit();
    await _file!.writeAsString(settings.toJson());
  }
}
