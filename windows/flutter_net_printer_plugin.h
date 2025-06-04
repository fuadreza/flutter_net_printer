#ifndef FLUTTER_PLUGIN_FLUTTER_NET_PRINTER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_NET_PRINTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_net_printer {

class FlutterNetPrinterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterNetPrinterPlugin();

  virtual ~FlutterNetPrinterPlugin();

  // Disallow copy and assign.
  FlutterNetPrinterPlugin(const FlutterNetPrinterPlugin&) = delete;
  FlutterNetPrinterPlugin& operator=(const FlutterNetPrinterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_net_printer

#endif  // FLUTTER_PLUGIN_FLUTTER_NET_PRINTER_PLUGIN_H_
