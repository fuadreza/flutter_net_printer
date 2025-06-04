import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_net_printer_method_channel.dart';

abstract class FlutterNetPrinterPlatform extends PlatformInterface {
  /// Constructs a FlutterNetPrinterPlatform.
  FlutterNetPrinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNetPrinterPlatform _instance = MethodChannelFlutterNetPrinter();

  /// The default instance of [FlutterNetPrinterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNetPrinter].
  static FlutterNetPrinterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNetPrinterPlatform] when
  /// they register themselves.
  static set instance(FlutterNetPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
