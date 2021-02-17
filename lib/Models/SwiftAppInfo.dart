import 'dart:typed_data';

class SwiftAppInfo {
  /// Complete package name (ie: com.example.app)
  final String package;

  /// User readable app name
  final String label;

  /// App icon
  Uint8List icon;

  bool isSwiftApp;

  setSwiftSettings(bool s) {
    isSwiftApp = s;
  }

  SwiftAppInfo(this.package, this.label, this.icon, {this.isSwiftApp = false});
}
