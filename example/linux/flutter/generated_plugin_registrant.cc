//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flexicapture/flexicapture_plugin.h>
#include <screen_capturer/screen_capturer_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) flexicapture_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlexicapturePlugin");
  flexicapture_plugin_register_with_registrar(flexicapture_registrar);
  g_autoptr(FlPluginRegistrar) screen_capturer_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ScreenCapturerPlugin");
  screen_capturer_plugin_register_with_registrar(screen_capturer_registrar);
}
