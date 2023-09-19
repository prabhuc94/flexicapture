//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flexicapture/flexicapture_plugin_c_api.h>
#include <screen_capturer/screen_capturer_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlexicapturePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlexicapturePluginCApi"));
  ScreenCapturerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenCapturerPlugin"));
}
