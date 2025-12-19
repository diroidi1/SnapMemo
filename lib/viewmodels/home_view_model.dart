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
    if (_query.isEmpty) return _memos;
    final q = _query.toLowerCase();
    return _memos.where((m) => (m.note ?? '').toLowerCase().contains(q)).toList();
  }

  Future<void> init() async {
    setBusy(true);
    await _repo.purgeExpired();
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
