import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  bool _busy = false;

  bool get busy => _busy;

  void setBusy(bool value) {
    if (_busy != value) {
      _busy = value;
      notifyListeners();
    }
  }
}
