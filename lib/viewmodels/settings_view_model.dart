import '../models/settings.dart';
import '../services/memo_repository.dart';
import '../services/settings_repository.dart';
import 'base_view_model.dart';

class SettingsViewModel extends BaseViewModel {
  final SettingsRepository _settingsRepo;
  final MemoRepository _memoRepo;

  Settings _settings = const Settings(defaultTtl: Duration(days: 14), showNoteInput: true);
  int _storageBytes = 0;

  SettingsViewModel(this._settingsRepo, this._memoRepo);

  Settings get settings => _settings;
  int get storageBytes => _storageBytes;
  String get storageLabel => '${(storageBytes / (1024 * 1024)).toStringAsFixed(0)}MB';

  Future<void> init() async {
    setBusy(true);
    _settings = await _settingsRepo.load();
    _storageBytes = await _memoRepo.getStorageUsageBytes();
    setBusy(false);
  }

  Future<void> setDefaultTtl(Duration ttl) async {
    _settings = _settings.copyWith(defaultTtl: ttl);
    await _settingsRepo.save(_settings);
    notifyListeners();
  }

  Future<void> toggleShowNote(bool value) async {
    _settings = _settings.copyWith(showNoteInput: value);
    await _settingsRepo.save(_settings);
    notifyListeners();
  }

  Future<void> deleteAllMemos() async {
    setBusy(true);
    await _memoRepo.deleteAll();
    _storageBytes = await _memoRepo.getStorageUsageBytes();
    setBusy(false);
    notifyListeners();
  }
}
