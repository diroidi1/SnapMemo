import 'dart:async';

import '../models/memo.dart';
import '../services/memo_repository.dart';
import 'base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  final MemoRepository _repo;
  HomeViewModel(this._repo);

  List<Memo> _memos = [];
  String _query = '';
  Timer? _purgeTimer;

  List<Memo> get memos => _memos;
  String get query => _query;

  List<Memo> get filteredMemos {
    List<Memo> result = _memos;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result.where((m) => (m.note ?? '').toLowerCase().contains(q)).toList();
    }
    // Sort by createdAt in descending order (newest first)
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> init() async {
    setBusy(true);
    await _repo.purgeExpired();
    // Remove memos with missing image files
    await _repo.removeMissingImageFiles();
    _memos = await _repo.loadMemos();
    setBusy(false);
    _purgeTimer?.cancel();
    // Periodic purge every hour
    _purgeTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      final removed = await _repo.purgeExpired();
      if (removed > 0) {
        _memos = await _repo.loadMemos();
        notifyListeners();
      }
    });
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> addMemo(Memo memo) async {
    _memos.add(memo);
    await _repo.saveMemos(_memos);
    notifyListeners();
  }

  Future<void> deleteMemo(String id) async {
    await _repo.deleteMemo(id);
    _memos.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> refresh() async {
    _memos = await _repo.loadMemos();
    notifyListeners();
  }

  @override
  void dispose() {
    _purgeTimer?.cancel();
    super.dispose();
  }
}
