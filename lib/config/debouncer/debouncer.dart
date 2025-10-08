import 'dart:async';
import 'dart:ui';

class Debouncer {

  static final Debouncer instance = Debouncer._internal();

    Debouncer._internal();

  Timer? _timer;
  int milliseconds = 500;

  void run(VoidCallback action, {int? delay}) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delay ?? milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void setDelay(int ms) {
    milliseconds = ms;
  }
}
