import 'package:flutter/foundation.dart';

class HideNavBar extends ChangeNotifier {
  bool hideNavBar = false;

  HideNavBar();

  void setHideNavBar(bool hide) {
    hideNavBar = hide;

    notifyListeners();
  }

  bool get isNavBarHidden => hideNavBar;
}
