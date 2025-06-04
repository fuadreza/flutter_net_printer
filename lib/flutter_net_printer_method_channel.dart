import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_net_printer_platform_interface.dart';

/// An implementation of [FlutterNetPrinterPlatform] that uses method channels.
class MethodChannelFlutterNetPrinter extends FlutterNetPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_net_printer');
}
