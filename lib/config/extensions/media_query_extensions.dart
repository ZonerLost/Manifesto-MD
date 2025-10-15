import 'package:flutter/widgets.dart';

extension Buillddd on BuildContext {

  Size get size => MediaQuery.sizeOf(this);

  double get screenHeight => size.height;
  double get screenWidth => size.width;

}