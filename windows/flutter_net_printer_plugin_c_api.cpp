#include "include/flutter_net_printer/flutter_net_printer_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_net_printer_plugin.h"

void FlutterNetPrinterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_net_printer::FlutterNetPrinterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
