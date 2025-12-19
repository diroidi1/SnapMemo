import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../models/memo.dart';
import '../services/memo_repository.dart';
import 'base_view_model.dart';

class MemoDetailViewModel extends BaseViewModel {
  final MemoRepository _repo;
  Memo _memo;

  MemoDetailViewModel(this._repo, this._memo);

  Memo get memo => _memo;

  Future<void> share() async {
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(_memo.filePath)], text: _memo.note ?? '');
  }

  Future<void> export() async {
    // Save image to device gallery where all apps can access it
    await Gal.putImage(_memo.filePath);
  }

  Future<void> extendBy(Duration by) async {
    _memo = _memo.copyWith(expiresAt: _memo.expiresAt.add(by));
    final memos = await _repo.loadMemos();
    final idx = memos.indexWhere((m) => m.id == _memo.id);
    if (idx != -1) {
      memos[idx] = _memo;
      await _repo.saveMemos(memos);
      notifyListeners();
    }
  }

  Future<void> delete() async {
    await _repo.deleteMemo(_memo.id);
  }
}
