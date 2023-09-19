#include "include/flexicapture/flexicapture_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flexicapture_plugin.h"

void FlexicapturePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flexicapture::FlexicapturePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
